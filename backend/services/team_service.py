import sqlite3
from typing import Tuple, Dict, Any
from backend.database import get_db

class TeamService:
    @staticmethod
    def accept_applicant(application_id: int, actor_user_id: int) -> Tuple[bool, str]:
        """
        Accepts a candidate for a team opening with transactional concurrency guard.
        Prevents race conditions from exceeding max_members or slots_available.
        """
        with get_db() as conn:
            try:
                conn.execute("BEGIN TRANSACTION;")
                cursor = conn.cursor()

                # 1. Fetch application and team details
                cursor.execute("""
                    SELECT 
                        ta.id AS app_id, ta.opening_id, ta.team_id, ta.applicant_id, ta.status AS app_status,
                        tro.slots_available, tro.slots_filled, tro.status AS opening_status, tro.role_title,
                        t.leader_id, t.max_members, t.current_member_count, t.name AS team_name
                    FROM team_applications ta
                    JOIN team_openings tro ON ta.opening_id = tro.id
                    JOIN teams t ON ta.team_id = t.id
                    WHERE ta.id = ?
                """, (application_id,))
                data = cursor.fetchone()

                if not data:
                    conn.rollback()
                    return False, "Application not found."

                # Verify authorization (only team leader can accept)
                if data["leader_id"] != actor_user_id:
                    conn.rollback()
                    return False, "Unauthorized: Only the team leader can accept applicants."

                if data["app_status"] == "ACCEPTED":
                    conn.rollback()
                    return False, "Applicant has already been accepted."

                # Check opening slot availability
                if data["slots_filled"] >= data["slots_available"] or data["opening_status"] != "OPEN":
                    conn.rollback()
                    return False, "This role opening has already been filled."

                # Check total team capacity limit
                if data["current_member_count"] >= data["max_members"]:
                    conn.rollback()
                    return False, f"Team capacity limit reached ({data['current_member_count']}/{data['max_members']})."

                # Check if applicant is already a member
                cursor.execute("""
                    SELECT 1 FROM team_members WHERE team_id = ? AND user_id = ?
                """, (data["team_id"], data["applicant_id"]))
                if cursor.fetchone():
                    conn.rollback()
                    return False, "User is already a member of this team."

                # 2. Add to team members
                cursor.execute("""
                    INSERT INTO team_members (team_id, user_id, role_title)
                    VALUES (?, ?, ?)
                """, (data["team_id"], data["applicant_id"], data["role_title"]))

                # 3. Increment team current_member_count
                cursor.execute("""
                    UPDATE teams 
                    SET current_member_count = current_member_count + 1,
                        status = CASE WHEN current_member_count + 1 >= max_members THEN 'FULL' ELSE status END,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (data["team_id"],))

                # 4. Increment opening slots_filled and close if full
                cursor.execute("""
                    UPDATE team_openings
                    SET slots_filled = slots_filled + 1,
                        status = CASE WHEN slots_filled + 1 >= slots_available THEN 'FILLED' ELSE status END
                    WHERE id = ?
                """, (data["opening_id"],))

                # 5. Update application status
                cursor.execute("""
                    UPDATE team_applications
                    SET status = 'ACCEPTED', reviewed_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (application_id,))

                # 6. Notify applicant
                cursor.execute("""
                    INSERT INTO notifications (user_id, type, title, message, entity_type, entity_id)
                    VALUES (?, 'TEAM_ACCEPTED', 'Team Application Accepted!', ?, 'TEAM', ?)
                """, (data["applicant_id"], f"Congratulations! You were accepted into team '{data['team_name']}' as {data['role_title']}.", data["team_id"]))

                conn.commit()
                return True, f"Successfully accepted applicant into {data['team_name']}."

            except sqlite3.IntegrityError as ie:
                conn.rollback()
                return False, f"Integrity constraint violation: {str(ie)}"
            except Exception as e:
                conn.rollback()
                return False, f"Error accepting applicant: {str(e)}"
