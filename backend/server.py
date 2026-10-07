import http.server
import socketserver
import json
import urllib.parse
import os
import sys
import mimetypes
import re
import traceback
from typing import Dict, Any, Optional

# Ensure project root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend.database import get_db, init_db
from backend.auth import hash_password, verify_password, create_session, get_current_user, invalidate_session
from backend.services.credit_service import CreditService
from backend.services.matching_service import MatchingService
from backend.services.team_service import TeamService

PORT = 8000
FRONTEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "frontend"))

class SkillLoopAPIHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def send_json(self, status_code: int, data: Any):
        response_bytes = json.dumps(data, default=str).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.end_headers()
        self.wfile.write(response_bytes)

    def send_error_json(self, status_code: int, code: str, message: str, details: Optional[Dict] = None):
        self.send_json(status_code, {
            "error": {
                "code": code,
                "message": message,
                "details": details or {}
            }
        })

    def get_auth_user(self) -> Optional[Dict[str, Any]]:
        auth_header = self.headers.get("Authorization", "")
        if auth_header.startswith("Bearer "):
            token = auth_header[7:].strip()
            return get_current_user(token)
        return None

    def read_json_body(self) -> Dict[str, Any]:
        content_length = int(self.headers.get("Content-Length", 0))
        if content_length > 0:
            raw_body = self.rfile.read(content_length).decode("utf-8")
            try:
                return json.loads(raw_body)
            except json.JSONDecodeError:
                return {}
        return {}

    # =========================================================================
    # ROUTE DISPATCHER
    # =========================================================================
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query_params = urllib.parse.parse_qs(parsed.query)

        try:
            # API Endpoints
            if path.startswith("/api/"):
                return self.handle_api_get(path, query_params)

            # Static Frontend Serving
            self.handle_static_file(path)
        except Exception as e:
            traceback.print_exc()
            self.send_error_json(500, "INTERNAL_ERROR", str(e))

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        body = self.read_json_body()

        try:
            if path.startswith("/api/"):
                return self.handle_api_post(path, body)
            self.send_error_json(404, "NOT_FOUND", "Endpoint not found.")
        except Exception as e:
            traceback.print_exc()
            self.send_error_json(500, "INTERNAL_ERROR", str(e))

    def do_PATCH(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        body = self.read_json_body()

        try:
            if path.startswith("/api/"):
                return self.handle_api_patch(path, body)
            self.send_error_json(404, "NOT_FOUND", "Endpoint not found.")
        except Exception as e:
            traceback.print_exc()
            self.send_error_json(500, "INTERNAL_ERROR", str(e))

    def do_DELETE(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        try:
            if path.startswith("/api/"):
                return self.handle_api_delete(path)
            self.send_error_json(404, "NOT_FOUND", "Endpoint not found.")
        except Exception as e:
            traceback.print_exc()
            self.send_error_json(500, "INTERNAL_ERROR", str(e))

    # =========================================================================
    # STATIC FILE HANDLER
    # =========================================================================
    def handle_static_file(self, path: str):
        if path == "/" or path == "":
            rel_path = "index.html"
        else:
            rel_path = path.lstrip("/")

        file_path = os.path.join(FRONTEND_DIR, rel_path)
        if not os.path.exists(file_path) or os.path.isdir(file_path):
            file_path = os.path.join(FRONTEND_DIR, "index.html")

        if os.path.exists(file_path) and os.path.isfile(file_path):
            mime_type, _ = mimetypes.guess_type(file_path)
            mime_type = mime_type or "application/octet-stream"
            with open(file_path, "rb") as f:
                content = f.read()
            self.send_response(200)
            self.send_header("Content-Type", f"{mime_type}; charset=utf-8" if "text" in mime_type or "javascript" in mime_type else mime_type)
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        else:
            self.send_error(404, "File Not Found")

    # =========================================================================
    # GET API HANDLERS
    # =========================================================================
    def handle_api_get(self, path: str, query: Dict[str, list]):
        # Auth me
        if path == "/api/auth/me":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            return self.send_json(200, {"user": user})

        # Skills categories
        if path == "/api/skills/categories":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT id, name, slug, description, icon FROM skill_categories ORDER BY id ASC;")
                return self.send_json(200, {"categories": [dict(r) for r in cursor.fetchall()]})

        # Skills master list
        if path == "/api/skills":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT s.id, s.category_id, sc.name AS category_name, s.name, s.slug, s.description, s.popularity_count
                    FROM skills s
                    JOIN skill_categories sc ON s.category_id = sc.id
                    ORDER BY s.popularity_count DESC, s.name ASC;
                """)
                return self.send_json(200, {"skills": [dict(r) for r in cursor.fetchall()]})

        # Skill graph / prerequisites: /api/skills/{id}/prerequisites
        match_prereq = re.match(r"^/api/skills/(\d+)/prerequisites$", path)
        if match_prereq:
            skill_id = int(match_prereq.group(1))
            res = MatchingService.get_skill_prerequisites(skill_id)
            return self.send_json(200, res)

        # Current user skills
        if path == "/api/users/me/skills":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT us.skill_id, s.name AS skill_name, s.slug, sc.name AS category_name, 
                           us.proficiency, us.years_experience, us.evidence_url, us.verification_status, us.verified_at
                    FROM user_skills us
                    JOIN skills s ON us.skill_id = s.id
                    JOIN skill_categories sc ON s.category_id = sc.id
                    WHERE us.user_id = ?
                    ORDER BY us.proficiency DESC;
                """, (user["id"],))
                return self.send_json(200, {"skills": [dict(r) for r in cursor.fetchall()]})

        # Current user learning goals
        if path == "/api/users/me/goals":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT lg.id, lg.skill_id, s.name AS skill_name, lg.title, lg.target_date, lg.progress_percent, lg.status
                    FROM learning_goals lg
                    JOIN skills s ON lg.skill_id = s.id
                    WHERE lg.user_id = ?
                    ORDER BY lg.created_at DESC;
                """, (user["id"],))
                return self.send_json(200, {"goals": [dict(r) for r in cursor.fetchall()]})

        # Public User profile: /api/users/{id}
        match_user = re.match(r"^/api/users/(\d+)$", path)
        if match_user:
            target_id = int(match_user.group(1))
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, username, full_name, bio, avatar_url, institution, department, year_of_study, 
                           github_url, linkedin_url, reputation_score, created_at
                    FROM users WHERE id = ? AND is_active = 1
                """, (target_id,))
                user_row = cursor.fetchone()
                if not user_row:
                    return self.send_error_json(404, "NOT_FOUND", "User not found.")
                
                profile = dict(user_row)
                cursor.execute("""
                    SELECT us.skill_id, s.name AS skill_name, us.proficiency, us.verification_status
                    FROM user_skills us
                    JOIN skills s ON us.skill_id = s.id
                    WHERE us.user_id = ?
                """, (target_id,))
                profile["skills"] = [dict(r) for r in cursor.fetchall()]

                cursor.execute("""
                    SELECT id, day_of_week, start_time, end_time FROM user_availability WHERE user_id = ?
                """, (target_id,))
                profile["availability"] = [dict(r) for r in cursor.fetchall()]
                return self.send_json(200, {"profile": profile})

        # Knowledge Hub Resources list
        if path == "/api/resources":
            skill_filter = query.get("skill", [None])[0]
            type_filter = query.get("type", [None])[0]
            search_query = query.get("q", [None])[0]

            sql = """
                SELECT r.id, r.uploader_id, u.username AS uploader_name, u.avatar_url AS uploader_avatar,
                       r.skill_id, s.name AS skill_name, r.title, r.description, r.resource_type,
                       r.content_url, r.author_name, r.difficulty, r.view_count, r.completion_count,
                       r.rating_avg, r.rating_count, r.created_at
                FROM resources r
                JOIN users u ON r.uploader_id = u.id
                JOIN skills s ON r.skill_id = s.id
                WHERE 1=1
            """
            params = []
            if skill_filter:
                sql += " AND (s.slug = ? OR s.id = ?)"
                params.extend([skill_filter, skill_filter])
            if type_filter:
                sql += " AND r.resource_type = ?"
                params.append(type_filter)
            if search_query:
                sql += " AND (r.title LIKE ? OR r.description LIKE ?)"
                like_term = f"%{search_query}%"
                params.extend([like_term, like_term])
            
            sql += " ORDER BY r.created_at DESC;"
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute(sql, params)
                return self.send_json(200, {"resources": [dict(r) for r in cursor.fetchall()]})

        # Social Feed Posts
        if path == "/api/posts":
            post_type = query.get("type", [None])[0]
            sql = """
                SELECT p.id, p.author_id, u.username AS author_name, u.full_name AS author_fullname, 
                       u.avatar_url AS author_avatar, p.title, p.content, p.post_type, 
                       p.related_skill_id, s.name AS skill_name, p.view_count, p.comment_count, 
                       p.reaction_count, p.created_at
                FROM posts p
                JOIN users u ON p.author_id = u.id
                LEFT JOIN skills s ON p.related_skill_id = s.id
                WHERE 1=1
            """
            params = []
            if post_type:
                sql += " AND p.post_type = ?"
                params.append(post_type)
            sql += " ORDER BY p.created_at DESC;"

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute(sql, params)
                return self.send_json(200, {"posts": [dict(r) for r in cursor.fetchall()]})

        # Single Post with Comments & Reactions: /api/posts/{id}
        match_post = re.match(r"^/api/posts/(\d+)$", path)
        if match_post:
            post_id = int(match_post.group(1))
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT p.id, p.author_id, u.username AS author_name, u.full_name AS author_fullname,
                           u.avatar_url AS author_avatar, p.title, p.content, p.post_type, 
                           p.related_skill_id, s.name AS skill_name, p.view_count, p.comment_count, 
                           p.reaction_count, p.created_at
                    FROM posts p
                    JOIN users u ON p.author_id = u.id
                    LEFT JOIN skills s ON p.related_skill_id = s.id
                    WHERE p.id = ?
                """, (post_id,))
                post = cursor.fetchone()
                if not post:
                    return self.send_error_json(404, "NOT_FOUND", "Post not found.")

                post_dict = dict(post)
                cursor.execute("""
                    SELECT pc.id, pc.author_id, u.username AS author_name, u.avatar_url AS author_avatar,
                           pc.content, pc.is_accepted_answer, pc.created_at
                    FROM post_comments pc
                    JOIN users u ON pc.author_id = u.id
                    WHERE pc.post_id = ?
                    ORDER BY pc.created_at ASC;
                """, (post_id,))
                post_dict["comments"] = [dict(r) for r in cursor.fetchall()]

                cursor.execute("""
                    SELECT reaction_type, COUNT(*) AS count 
                    FROM post_reactions WHERE post_id = ?
                    GROUP BY reaction_type
                """, (post_id,))
                post_dict["reactions"] = [dict(r) for r in cursor.fetchall()]
                return self.send_json(200, {"post": post_dict})

        # Skill Exchange: Teaching Offers
        if path == "/api/exchange/offers":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT o.id, o.user_id, u.username, u.full_name, u.avatar_url, u.reputation_score,
                           o.skill_id, s.name AS skill_name, s.slug AS skill_slug,
                           o.min_learner_level, o.max_learner_level, o.session_format,
                           o.session_duration_minutes, o.credit_cost, o.language, o.description
                    FROM teaching_offers o
                    JOIN users u ON o.user_id = u.id
                    JOIN skills s ON o.skill_id = s.id
                    WHERE o.is_active = 1
                    ORDER BY u.reputation_score DESC;
                """)
                return self.send_json(200, {"offers": [dict(r) for r in cursor.fetchall()]})

        # Skill Exchange: User Sessions
        if path == "/api/exchange/sessions":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT ls.id, ls.teacher_id, ut.username AS teacher_name, ut.avatar_url AS teacher_avatar,
                           ls.learner_id, ul.username AS learner_name, ul.avatar_url AS learner_avatar,
                           ls.skill_id, s.name AS skill_name, ls.scheduled_start, ls.scheduled_end,
                           ls.duration_minutes, ls.status, ls.meeting_url, ls.notes, ls.credit_settled, ls.created_at
                    FROM learning_sessions ls
                    JOIN users ut ON ls.teacher_id = ut.id
                    JOIN users ul ON ls.learner_id = ul.id
                    JOIN skills s ON ls.skill_id = s.id
                    WHERE ls.teacher_id = ? OR ls.learner_id = ?
                    ORDER BY ls.scheduled_start DESC;
                """, (user["id"], user["id"]))
                return self.send_json(200, {"sessions": [dict(r) for r in cursor.fetchall()]})

        # Skill Credits Ledger History
        if path == "/api/exchange/credits":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT balance, total_earned, total_spent, updated_at
                    FROM credit_accounts WHERE user_id = ?
                """, (user["id"],))
                acc = cursor.fetchone()

                cursor.execute("""
                    SELECT id, amount, transaction_type, session_id, balance_after, description, created_at
                    FROM credit_transactions
                    WHERE account_id = ?
                    ORDER BY created_at DESC;
                """, (user["id"],))
                return self.send_json(200, {
                    "account": dict(acc) if acc else {"balance": 0.0, "total_earned": 0.0, "total_spent": 0.0},
                    "transactions": [dict(r) for r in cursor.fetchall()]
                })

        # Competitions & Hackathons
        if path == "/api/competitions":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT c.id, c.title, c.organizer, c.competition_type, c.description, c.eligibility,
                           c.registration_deadline, c.event_start, c.event_end, c.website_url, c.banner_url, c.status,
                           (SELECT COUNT(*) FROM teams WHERE competition_id = c.id) AS team_count
                    FROM competitions c
                    ORDER BY c.registration_deadline ASC;
                """)
                return self.send_json(200, {"competitions": [dict(r) for r in cursor.fetchall()]})

        # Teams with openings
        if path == "/api/teams":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT t.id, t.competition_id, c.title AS competition_title, t.name, t.leader_id,
                           u.username AS leader_username, t.description, t.max_members, t.current_member_count, t.status,
                           (SELECT COUNT(*) FROM team_openings WHERE team_id = t.id AND status = 'OPEN') AS open_roles_count
                    FROM teams t
                    JOIN users u ON t.leader_id = u.id
                    LEFT JOIN competitions c ON t.competition_id = c.id
                    ORDER BY t.created_at DESC;
                """)
                teams_list = [dict(r) for r in cursor.fetchall()]
                for team in teams_list:
                    cursor.execute("""
                        SELECT tro.id, tro.role_title, s.name AS skill_name, tro.min_proficiency, tro.slots_available, tro.slots_filled, tro.status
                        FROM team_openings tro
                        JOIN skills s ON tro.skill_id = s.id
                        WHERE tro.team_id = ?
                    """, (team["id"],))
                    team["openings"] = [dict(r) for r in cursor.fetchall()]
                return self.send_json(200, {"teams": teams_list})

        # Opportunities
        if path == "/api/opportunities":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT o.id, o.creator_id, u.username AS creator_name, u.avatar_url AS creator_avatar,
                           o.title, o.opportunity_type, o.description, o.required_skill_id, s.name AS skill_name,
                           o.slots_total, o.slots_filled, o.deadline, o.status, o.created_at
                    FROM opportunities o
                    JOIN users u ON o.creator_id = u.id
                    LEFT JOIN skills s ON o.required_skill_id = s.id
                    ORDER BY o.created_at DESC;
                """)
                return self.send_json(200, {"opportunities": [dict(r) for r in cursor.fetchall()]})

        # Projects
        if path == "/api/projects":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT p.id, p.owner_id, u.username AS owner_name, p.title, p.tagline, 
                           p.problem_statement, p.solution_description, p.github_url, p.demo_url, 
                           c.title AS competition_title, p.status, p.created_at,
                           (SELECT COUNT(*) FROM project_tasks WHERE project_id = p.id AND status = 'DONE') AS completed_tasks,
                           (SELECT COUNT(*) FROM project_tasks WHERE project_id = p.id) AS total_tasks
                    FROM projects p
                    JOIN users u ON p.owner_id = u.id
                    LEFT JOIN competitions c ON p.competition_id = c.id
                    ORDER BY p.created_at DESC;
                """)
                return self.send_json(200, {"projects": [dict(r) for r in cursor.fetchall()]})

        # Single Project Details & Kanban tasks: /api/projects/{id}
        match_proj = re.match(r"^/api/projects/(\d+)$", path)
        if match_proj:
            proj_id = int(match_proj.group(1))
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT p.id, p.owner_id, u.username AS owner_name, p.title, p.tagline, 
                           p.problem_statement, p.solution_description, p.github_url, p.demo_url, 
                           p.competition_id, c.title AS competition_title, p.status, p.created_at
                    FROM projects p
                    JOIN users u ON p.owner_id = u.id
                    LEFT JOIN competitions c ON p.competition_id = c.id
                    WHERE p.id = ?
                """, (proj_id,))
                proj = cursor.fetchone()
                if not proj:
                    return self.send_error_json(404, "NOT_FOUND", "Project not found.")

                proj_dict = dict(proj)
                # Fetch members
                cursor.execute("""
                    SELECT pm.user_id, u.username, u.full_name, u.avatar_url, pm.role_title
                    FROM project_members pm
                    JOIN users u ON pm.user_id = u.id
                    WHERE pm.project_id = ?
                """, (proj_id,))
                proj_dict["members"] = [dict(r) for r in cursor.fetchall()]

                # Fetch tasks
                cursor.execute("""
                    SELECT pt.id, pt.title, pt.description, pt.assignee_id, u.username AS assignee_name, 
                           pt.status, pt.priority, pt.due_date
                    FROM project_tasks pt
                    LEFT JOIN users u ON pt.assignee_id = u.id
                    WHERE pt.project_id = ?
                    ORDER BY pt.id ASC;
                """, (proj_id,))
                proj_dict["tasks"] = [dict(r) for r in cursor.fetchall()]

                return self.send_json(200, {"project": proj_dict})

        # Challenges
        if path == "/api/challenges":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT c.id, c.title, c.description, c.skill_id, s.name AS skill_name,
                           c.difficulty, c.xp_reward, c.time_limit_minutes, c.sample_code, c.created_at,
                           (SELECT COUNT(*) FROM challenge_submissions WHERE challenge_id = c.id AND status = 'PASSED') AS completions
                    FROM challenges c
                    JOIN skills s ON c.skill_id = s.id
                    ORDER BY c.id ASC;
                """)
                return self.send_json(200, {"challenges": [dict(r) for r in cursor.fetchall()]})

        # Notifications
        if path == "/api/notifications":
            user = self.get_auth_user()
            if not user:
                return self.send_error_json(401, "UNAUTHORIZED", "Not authenticated.")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, type, title, message, entity_type, entity_id, is_read, created_at
                    FROM notifications
                    WHERE user_id = ?
                    ORDER BY created_at DESC
                    LIMIT 20;
                """, (user["id"],))
                return self.send_json(200, {"notifications": [dict(r) for r in cursor.fetchall()]})

        # Analytics KPIs
        if path == "/api/analytics/summary":
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM users;")
                user_count = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM skills;")
                skill_count = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM resources;")
                resource_count = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM learning_sessions WHERE status = 'COMPLETED';")
                sessions_completed = cursor.fetchone()[0]

                cursor.execute("SELECT COALESCE(SUM(amount), 0) FROM credit_transactions WHERE transaction_type = 'EARNED_TEACHING';")
                credits_exchanged = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM teams;")
                team_count = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM projects;")
                project_count = cursor.fetchone()[0]

                cursor.execute("SELECT * FROM v_user_reputation ORDER BY reputation_score DESC LIMIT 5;")
                top_reputation = [dict(r) for r in cursor.fetchall()]

                cursor.execute("SELECT * FROM v_mutual_skill_matches LIMIT 5;")
                mutual_matches = [dict(r) for r in cursor.fetchall()]

                return self.send_json(200, {
                    "summary": {
                        "user_count": user_count,
                        "skill_count": skill_count,
                        "resource_count": resource_count,
                        "sessions_completed": sessions_completed,
                        "credits_exchanged": credits_exchanged,
                        "team_count": team_count,
                        "project_count": project_count
                    },
                    "top_reputation": top_reputation,
                    "mutual_matches": mutual_matches
                })

        # Demonstration DBMS Queries list
        if path == "/api/analytics/queries":
            queries_path = os.path.join(os.path.dirname(__file__), "..", "database", "queries.sql")
            with open(queries_path, "r", encoding="utf-8") as f:
                raw_sql = f.read()
            return self.send_json(200, {"sql_file": raw_sql})

        return self.send_error_json(404, "NOT_FOUND", "Endpoint not found.")

    # =========================================================================
    # POST API HANDLERS
    # =========================================================================
    def handle_api_post(self, path: str, body: Dict[str, Any]):
        # 1. Register
        if path == "/api/auth/register":
            username = body.get("username", "").strip()
            email = body.get("email", "").strip().lower()
            password = body.get("password", "")
            full_name = body.get("full_name", "").strip()
            institution = body.get("institution", "").strip()
            department = body.get("department", "").strip()
            year = body.get("year_of_study", 1)

            if not username or not email or not password or not full_name:
                return self.send_error_json(422, "VALIDATION_ERROR", "Username, email, password, and full name are required.")

            with get_db() as conn:
                try:
                    cursor = conn.cursor()
                    hashed = hash_password(password)
                    cursor.execute("""
                        INSERT INTO users (username, email, password_hash, full_name, institution, department, year_of_study)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    """, (username, email, hashed, full_name, institution, department, year))
                    user_id = cursor.lastrowid

                    # Assign student role (id=1)
                    cursor.execute("INSERT INTO user_roles (user_id, role_id) VALUES (?, 1);", (user_id,))
                    conn.commit()

                    token = create_session(user_id)
                    user_obj = get_current_user(token)
                    return self.send_json(201, {"token": token, "user": user_obj})
                except sqlite3.IntegrityError as ie:
                    return self.send_error_json(409, "CONFLICT", f"Username or email already exists: {str(ie)}")

        # 2. Login
        if path == "/api/auth/login":
            username_or_email = body.get("username_or_email", "").strip().lower()
            password = body.get("password", "")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT id, password_hash FROM users 
                    WHERE (LOWER(username) = ? OR LOWER(email) = ?) AND is_active = 1
                """, (username_or_email, username_or_email))
                row = cursor.fetchone()

                if not row or not verify_password(password, row["password_hash"]):
                    return self.send_error_json(401, "INVALID_CREDENTIALS", "Invalid username/email or password.")

                user_id = row["id"]
                token = create_session(user_id)
                user_obj = get_current_user(token)
                return self.send_json(200, {"token": token, "user": user_obj})

        # 3. Logout
        if path == "/api/auth/logout":
            auth_header = self.headers.get("Authorization", "")
            if auth_header.startswith("Bearer "):
                invalidate_session(auth_header[7:].strip())
            return self.send_json(200, {"message": "Logged out successfully."})

        # User must be authenticated for following actions
        user = self.get_auth_user()
        if not user:
            return self.send_error_json(401, "UNAUTHORIZED", "Authentication required.")

        # Add/Update user skill
        if path == "/api/users/me/skills":
            skill_id = body.get("skill_id")
            proficiency = body.get("proficiency", "BEGINNER")
            years = body.get("years_experience", 0.0)
            evidence = body.get("evidence_url", "")

            if not skill_id or proficiency not in ('BEGINNER', 'ELEMENTARY', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'):
                return self.send_error_json(422, "VALIDATION_ERROR", "Valid skill_id and proficiency level required.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO user_skills (user_id, skill_id, proficiency, years_experience, evidence_url, updated_at)
                    VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                    ON CONFLICT(user_id, skill_id) DO UPDATE SET
                        proficiency = excluded.proficiency,
                        years_experience = excluded.years_experience,
                        evidence_url = excluded.evidence_url,
                        updated_at = CURRENT_TIMESTAMP;
                """, (user["id"], skill_id, proficiency, years, evidence))
                conn.commit()
                return self.send_json(200, {"message": "Skill updated successfully."})

        # Add learning goal
        if path == "/api/users/me/goals":
            skill_id = body.get("skill_id")
            title = body.get("title", "")
            target_date = body.get("target_date")

            if not skill_id or not title:
                return self.send_error_json(422, "VALIDATION_ERROR", "skill_id and goal title are required.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO learning_goals (user_id, skill_id, title, target_date)
                    VALUES (?, ?, ?, ?)
                """, (user["id"], skill_id, title, target_date))
                conn.commit()
                return self.send_json(201, {"message": "Learning goal added."})

        # Publish Resource / Tutorial
        if path == "/api/resources":
            skill_id = body.get("skill_id")
            title = body.get("title", "").strip()
            description = body.get("description", "").strip()
            resource_type = body.get("resource_type", "NOTE")
            content_url = body.get("content_url", "").strip()
            author_name = body.get("author_name", user["full_name"])
            difficulty = body.get("difficulty", "INTERMEDIATE")

            if not skill_id or not title or not content_url:
                return self.send_error_json(422, "VALIDATION_ERROR", "skill_id, title, and content_url are required.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO resources (uploader_id, skill_id, title, description, resource_type, content_url, author_name, difficulty)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (user["id"], skill_id, title, description, resource_type, content_url, author_name, difficulty))
                res_id = cursor.lastrowid
                conn.commit()
                return self.send_json(201, {"id": res_id, "message": "Resource published."})

        # Rate Resource: /api/resources/{id}/ratings
        match_rate = re.match(r"^/api/resources/(\d+)/ratings$", path)
        if match_rate:
            resource_id = int(match_rate.group(1))
            rating = int(body.get("rating", 5))
            review_text = body.get("review_text", "")
            if rating < 1 or rating > 5:
                return self.send_error_json(422, "VALIDATION_ERROR", "Rating must be between 1 and 5.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO resource_ratings (resource_id, user_id, rating, review_text)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT(resource_id, user_id) DO UPDATE SET
                        rating = excluded.rating,
                        review_text = excluded.review_text;
                """, (resource_id, user["id"], rating, review_text))
                conn.commit()
                return self.send_json(200, {"message": "Rating saved."})

        # Create Social Post
        if path == "/api/posts":
            title = body.get("title", "").strip()
            content = body.get("content", "").strip()
            post_type = body.get("post_type", "DISCUSSION")
            related_skill_id = body.get("related_skill_id")

            if not title or not content:
                return self.send_error_json(422, "VALIDATION_ERROR", "Title and content are required.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO posts (author_id, title, content, post_type, related_skill_id)
                    VALUES (?, ?, ?, ?, ?)
                """, (user["id"], title, content, post_type, related_skill_id))
                post_id = cursor.lastrowid
                conn.commit()
                return self.send_json(201, {"id": post_id, "message": "Post published."})

        # Comment on Post: /api/posts/{id}/comments
        match_comment = re.match(r"^/api/posts/(\d+)/comments$", path)
        if match_comment:
            post_id = int(match_comment.group(1))
            content = body.get("content", "").strip()
            if not content:
                return self.send_error_json(422, "VALIDATION_ERROR", "Comment content required.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO post_comments (post_id, author_id, content)
                    VALUES (?, ?, ?)
                """, (post_id, user["id"], content))
                conn.commit()
                return self.send_json(201, {"message": "Comment added."})

        # React to Post: /api/posts/{id}/reactions
        match_react = re.match(r"^/api/posts/(\d+)/reactions$", path)
        if match_react:
            post_id = int(match_react.group(1))
            reaction_type = body.get("reaction_type", "LIKE")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO post_reactions (post_id, user_id, reaction_type)
                    VALUES (?, ?, ?)
                    ON CONFLICT(post_id, user_id) DO UPDATE SET reaction_type = excluded.reaction_type;
                """, (post_id, user["id"], reaction_type))
                cursor.execute("""
                    UPDATE posts 
                    SET reaction_count = (SELECT COUNT(*) FROM post_reactions WHERE post_id = ?)
                    WHERE id = ?;
                """, (post_id, post_id))
                conn.commit()
                return self.send_json(200, {"message": "Reaction recorded."})

        # Match Mentors: /api/exchange/match
        if path == "/api/exchange/match":
            target_skill_id = body.get("skill_id")
            if not target_skill_id:
                return self.send_error_json(422, "VALIDATION_ERROR", "skill_id required for mentor matching.")
            matches = MatchingService.match_mentors_for_user(user["id"], int(target_skill_id))
            return self.send_json(200, {"matches": matches})

        # Publish Teaching Offer
        if path == "/api/exchange/offers":
            skill_id = body.get("skill_id")
            duration = int(body.get("session_duration_minutes", 60))
            credit_cost = float(body.get("credit_cost", 1.0))
            format_type = body.get("session_format", "ONLINE")
            language = body.get("language", "English")
            desc = body.get("description", "")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO teaching_offers (user_id, skill_id, session_duration_minutes, credit_cost, session_format, language, description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (user["id"], skill_id, duration, credit_cost, format_type, language, desc))
                conn.commit()
                return self.send_json(201, {"message": "Teaching offer published."})

        # Request Learning Session
        if path == "/api/exchange/sessions":
            teacher_id = body.get("teacher_id")
            skill_id = body.get("skill_id")
            scheduled_start = body.get("scheduled_start")
            scheduled_end = body.get("scheduled_end")
            notes = body.get("notes", "")

            if not teacher_id or not skill_id or not scheduled_start or not scheduled_end:
                return self.send_error_json(422, "VALIDATION_ERROR", "teacher_id, skill_id, scheduled_start, and scheduled_end required.")

            if teacher_id == user["id"]:
                return self.send_error_json(400, "BAD_REQUEST", "You cannot request a learning session with yourself.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO learning_sessions (teacher_id, learner_id, skill_id, scheduled_start, scheduled_end, notes, status)
                    VALUES (?, ?, ?, ?, ?, ?, 'REQUESTED')
                """, (teacher_id, user["id"], skill_id, scheduled_start, scheduled_end, notes))
                session_id = cursor.lastrowid

                # Notify teacher
                cursor.execute("""
                    INSERT INTO notifications (user_id, type, title, message, entity_type, entity_id)
                    VALUES (?, 'SESSION_REQUEST', 'New Session Request', ?, 'LEARNING_SESSION', ?)
                """, (teacher_id, f"{user['username']} requested a session with you.", session_id))
                conn.commit()
                return self.send_json(201, {"id": session_id, "message": "Session request sent."})

        # Accept Session: /api/exchange/sessions/{id}/accept
        match_sess_acc = re.match(r"^/api/exchange/sessions/(\d+)/accept$", path)
        if match_sess_acc:
            session_id = int(match_sess_acc.group(1))
            meeting_url = body.get("meeting_url", f"https://meet.skillloop.edu/session-{session_id}")
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE learning_sessions
                    SET status = 'ACCEPTED', meeting_url = ?, updated_at = CURRENT_TIMESTAMP
                    WHERE id = ? AND teacher_id = ?
                """, (meeting_url, session_id, user["id"]))
                if cursor.rowcount == 0:
                    return self.send_error_json(403, "FORBIDDEN", "Unauthorized or session not found.")
                conn.commit()
                return self.send_json(200, {"message": "Session accepted."})

        # Complete Session & Settle Credits: /api/exchange/sessions/{id}/complete
        match_sess_comp = re.match(r"^/api/exchange/sessions/(\d+)/complete$", path)
        if match_sess_comp:
            session_id = int(match_sess_comp.group(1))
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE learning_sessions
                    SET status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP
                    WHERE id = ? AND (teacher_id = ? OR learner_id = ?)
                """, (session_id, user["id"], user["id"]))
                conn.commit()

            # Execute transactional settlement
            success, msg = CreditService.settle_session(session_id, user["id"])
            if not success:
                return self.send_error_json(400, "SETTLEMENT_FAILED", msg)
            return self.send_json(200, {"message": msg})

        # Review Session: /api/exchange/sessions/{id}/review
        match_sess_rev = re.match(r"^/api/exchange/sessions/(\d+)/review$", path)
        if match_sess_rev:
            session_id = int(match_sess_rev.group(1))
            rating = int(body.get("rating", 5))
            clarity = int(body.get("teaching_clarity", 5))
            punctuality = int(body.get("punctuality", 5))
            comments = body.get("comments", "")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT teacher_id, learner_id, status FROM learning_sessions WHERE id = ?", (session_id,))
                session = cursor.fetchone()
                if not session or session["status"] != "COMPLETED":
                    return self.send_error_json(400, "INVALID_STATE", "Only completed sessions can be reviewed.")

                reviewee_id = session["teacher_id"] if user["id"] == session["learner_id"] else session["learner_id"]
                cursor.execute("""
                    INSERT INTO session_reviews (session_id, reviewer_id, reviewee_id, rating, teaching_clarity, punctuality, comments)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(session_id, reviewer_id) DO UPDATE SET
                        rating = excluded.rating,
                        teaching_clarity = excluded.teaching_clarity,
                        punctuality = excluded.punctuality,
                        comments = excluded.comments;
                """, (session_id, user["id"], reviewee_id, rating, clarity, punctuality, comments))
                conn.commit()
                return self.send_json(200, {"message": "Review submitted."})

        # Create Team
        if path == "/api/teams":
            name = body.get("name", "").strip()
            competition_id = body.get("competition_id")
            description = body.get("description", "")
            max_members = int(body.get("max_members", 4))

            if not name:
                return self.send_error_json(422, "VALIDATION_ERROR", "Team name required.")

            with get_db() as conn:
                conn.execute("BEGIN TRANSACTION;")
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO teams (name, leader_id, competition_id, description, max_members, current_member_count)
                    VALUES (?, ?, ?, ?, ?, 1)
                """, (name, user["id"], competition_id, description, max_members))
                team_id = cursor.lastrowid

                # Add leader as first member
                cursor.execute("""
                    INSERT INTO team_members (team_id, user_id, role_title)
                    VALUES (?, ?, 'Team Leader')
                """, (team_id, user["id"]))

                conn.commit()
                return self.send_json(201, {"id": team_id, "message": "Team created."})

        # Post Team Opening: /api/teams/{id}/openings
        match_open = re.match(r"^/api/teams/(\d+)/openings$", path)
        if match_open:
            team_id = int(match_open.group(1))
            role_title = body.get("role_title", "").strip()
            skill_id = body.get("skill_id")
            min_proficiency = body.get("min_proficiency", "INTERMEDIATE")
            slots = int(body.get("slots_available", 1))

            with get_db() as conn:
                cursor = conn.cursor()
                # Verify leader
                cursor.execute("SELECT leader_id FROM teams WHERE id = ?", (team_id,))
                team = cursor.fetchone()
                if not team or team["leader_id"] != user["id"]:
                    return self.send_error_json(403, "FORBIDDEN", "Only team leader can post openings.")

                cursor.execute("""
                    INSERT INTO team_openings (team_id, role_title, skill_id, min_proficiency, slots_available)
                    VALUES (?, ?, ?, ?, ?)
                """, (team_id, role_title, skill_id, min_proficiency, slots))
                conn.commit()
                return self.send_json(201, {"message": "Team opening posted."})

        # Apply for Team Opening: /api/teams/openings/{id}/apply
        match_apply = re.match(r"^/api/teams/openings/(\d+)/apply$", path)
        if match_apply:
            opening_id = int(match_apply.group(1))
            pitch = body.get("pitch_message", "")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT team_id FROM team_openings WHERE id = ?", (opening_id,))
                opening = cursor.fetchone()
                if not opening:
                    return self.send_error_json(404, "NOT_FOUND", "Opening not found.")

                team_id = opening["team_id"]
                try:
                    cursor.execute("""
                        INSERT INTO team_applications (opening_id, team_id, applicant_id, pitch_message)
                        VALUES (?, ?, ?, ?)
                    """, (opening_id, team_id, user["id"], pitch))
                    conn.commit()
                    return self.send_json(201, {"message": "Application submitted."})
                except sqlite3.IntegrityError:
                    return self.send_error_json(409, "CONFLICT", "You have already applied for this opening.")

        # Accept Team Applicant: /api/teams/applications/{id}/review
        match_rev_app = re.match(r"^/api/teams/applications/(\d+)/review$", path)
        if match_rev_app:
            app_id = int(match_rev_app.group(1))
            action = body.get("action", "ACCEPT")

            if action == "ACCEPT":
                success, msg = TeamService.accept_applicant(app_id, user["id"])
                if not success:
                    return self.send_error_json(400, "ACCEPT_FAILED", msg)
                return self.send_json(200, {"message": msg})
            else:
                with get_db() as conn:
                    cursor = conn.cursor()
                    cursor.execute("UPDATE team_applications SET status = 'REJECTED', reviewed_at = CURRENT_TIMESTAMP WHERE id = ?", (app_id,))
                    conn.commit()
                    return self.send_json(200, {"message": "Application rejected."})

        # Create Project
        if path == "/api/projects":
            title = body.get("title", "").strip()
            tagline = body.get("tagline", "")
            problem = body.get("problem_statement", "")
            solution = body.get("solution_description", "")
            github_url = body.get("github_url", "")
            demo_url = body.get("demo_url", "")
            competition_id = body.get("competition_id")

            with get_db() as conn:
                conn.execute("BEGIN TRANSACTION;")
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO projects (owner_id, title, tagline, problem_statement, solution_description, github_url, demo_url, competition_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (user["id"], title, tagline, problem, solution, github_url, demo_url, competition_id))
                proj_id = cursor.lastrowid

                # Add owner to project members
                cursor.execute("""
                    INSERT INTO project_members (project_id, user_id, role_title)
                    VALUES (?, ?, 'Project Lead')
                """, (proj_id, user["id"]))

                conn.commit()
                return self.send_json(201, {"id": proj_id, "message": "Project created."})

        # Add Task to Project: /api/projects/{id}/tasks
        match_task = re.match(r"^/api/projects/(\d+)/tasks$", path)
        if match_task:
            proj_id = int(match_task.group(1))
            title = body.get("title", "").strip()
            desc = body.get("description", "")
            priority = body.get("priority", "MEDIUM")
            due_date = body.get("due_date")
            assignee_id = body.get("assignee_id")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO project_tasks (project_id, title, description, priority, due_date, assignee_id)
                    VALUES (?, ?, ?, ?, ?, ?)
                """, (proj_id, title, desc, priority, due_date, assignee_id))
                task_id = cursor.lastrowid
                conn.commit()
                return self.send_json(201, {"id": task_id, "message": "Task created."})

        # Submit Challenge: /api/challenges/{id}/submit
        match_chal = re.match(r"^/api/challenges/(\d+)/submit$", path)
        if match_chal:
            chal_id = int(match_chal.group(1))
            code = body.get("code_submission", "").strip()

            with get_db() as conn:
                conn.execute("BEGIN TRANSACTION;")
                cursor = conn.cursor()
                cursor.execute("SELECT xp_reward FROM challenges WHERE id = ?", (chal_id,))
                chal = cursor.fetchone()
                if not chal:
                    conn.rollback()
                    return self.send_error_json(404, "NOT_FOUND", "Challenge not found.")

                xp = chal["xp_reward"]
                cursor.execute("""
                    INSERT INTO challenge_submissions (challenge_id, user_id, code_submission, status, score, xp_awarded)
                    VALUES (?, ?, ?, 'PASSED', 100, ?)
                """, (chal_id, user["id"], code, xp))

                # Update user reputation / verification
                cursor.execute("""
                    UPDATE users SET reputation_score = MIN(5.00, reputation_score + 0.05) WHERE id = ?
                """, (user["id"],))

                cursor.execute("""
                    INSERT INTO notifications (user_id, type, title, message)
                    VALUES (?, 'CHALLENGE_PASSED', 'Challenge Solved!', ?)
                """, (user["id"], f"You solved challenge #{chal_id} and earned +{xp} XP!"))

                conn.commit()
                return self.send_json(200, {"message": f"Solution accepted! You earned +{xp} XP."})

        return self.send_error_json(404, "NOT_FOUND", "POST Endpoint not found.")

    # =========================================================================
    # PATCH API HANDLERS
    # =========================================================================
    def handle_api_patch(self, path: str, body: Dict[str, Any]):
        user = self.get_auth_user()
        if not user:
            return self.send_error_json(401, "UNAUTHORIZED", "Authentication required.")

        # Update Current User Profile
        if path == "/api/users/me":
            full_name = body.get("full_name", user["full_name"])
            bio = body.get("bio", user["bio"])
            institution = body.get("institution", user["institution"])
            department = body.get("department", user["department"])
            year = body.get("year_of_study", user["year_of_study"])
            github = body.get("github_url", user["github_url"])
            linkedin = body.get("linkedin_url", user["linkedin_url"])

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE users 
                    SET full_name = ?, bio = ?, institution = ?, department = ?, year_of_study = ?,
                        github_url = ?, linkedin_url = ?, updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (full_name, bio, institution, department, year, github, linkedin, user["id"]))
                conn.commit()
                return self.send_json(200, {"message": "Profile updated."})

        # Update Project Task Status: /api/projects/tasks/{id}
        match_task_stat = re.match(r"^/api/projects/tasks/(\d+)$", path)
        if match_task_stat:
            task_id = int(match_task_stat.group(1))
            status = body.get("status", "TODO")
            if status not in ('TODO', 'IN_PROGRESS', 'BLOCKED', 'DONE'):
                return self.send_error_json(422, "VALIDATION_ERROR", "Invalid task status.")

            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    UPDATE project_tasks
                    SET status = ?, updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (status, task_id))
                conn.commit()
                return self.send_json(200, {"message": "Task status updated."})

        return self.send_error_json(404, "NOT_FOUND", "PATCH Endpoint not found.")

    # =========================================================================
    # DELETE API HANDLERS
    # =========================================================================
    def handle_api_delete(self, path: str):
        user = self.get_auth_user()
        if not user:
            return self.send_error_json(401, "UNAUTHORIZED", "Authentication required.")

        # Remove skill from profile: /api/users/me/skills/{skillId}
        match_del_skill = re.match(r"^/api/users/me/skills/(\d+)$", path)
        if match_del_skill:
            skill_id = int(match_del_skill.group(1))
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM user_skills WHERE user_id = ? AND skill_id = ?", (user["id"], skill_id))
                conn.commit()
                return self.send_json(200, {"message": "Skill removed from profile."})

        return self.send_error_json(404, "NOT_FOUND", "DELETE Endpoint not found.")

def run_server():
    init_db()
    with socketserver.ThreadingTCPServer(("", PORT), SkillLoopAPIHandler) as httpd:
        print(f"============================================================")
        print(f"  SkillLoop Full-Stack DBMS Platform")
        print(f"  Server running live at: http://localhost:{PORT}")
        print(f"============================================================")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down SkillLoop server...")
            httpd.server_close()

if __name__ == "__main__":
    run_server()
