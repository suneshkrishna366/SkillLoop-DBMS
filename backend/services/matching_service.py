from typing import List, Dict, Any, Optional
from backend.database import get_db

class MatchingService:
    @staticmethod
    def match_mentors_for_user(learner_id: int, target_skill_id: int) -> List[Dict[str, Any]]:
        """
        Transparent deterministic matching engine:
        - Skill verification & proficiency score (40%)
        - Availability overlap on common days/hours (25%)
        - Teaching reputation score (20%)
        - Historical completed sessions & reliability (15%)
        Includes clear, explainable match rationale.
        """
        with get_db() as conn:
            cursor = conn.cursor()

            # Get target skill name
            cursor.execute("SELECT name FROM skills WHERE id = ?", (target_skill_id,))
            skill_row = cursor.fetchone()
            if not skill_row:
                return []
            skill_name = skill_row["name"]

            # Get learner availability days
            cursor.execute("SELECT day_of_week, start_time, end_time FROM user_availability WHERE user_id = ?", (learner_id,))
            learner_slots = [dict(r) for r in cursor.fetchall()]
            learner_days = {slot["day_of_week"] for slot in learner_slots}

            # Find active teaching offers for this skill
            cursor.execute("""
                SELECT 
                    u.id AS teacher_id,
                    u.username,
                    u.full_name,
                    u.avatar_url,
                    u.institution,
                    u.reputation_score,
                    us.proficiency,
                    us.verification_status,
                    offer.id AS offer_id,
                    offer.session_format,
                    offer.session_duration_minutes,
                    offer.credit_cost,
                    offer.language,
                    offer.description AS offer_description,
                    (SELECT COUNT(*) FROM learning_sessions WHERE teacher_id = u.id AND status = 'COMPLETED') AS completed_sessions
                FROM teaching_offers offer
                JOIN users u ON offer.user_id = u.id
                JOIN user_skills us ON u.id = us.user_id AND us.skill_id = offer.skill_id
                WHERE offer.skill_id = ? AND offer.is_active = 1 AND u.id != ? AND u.is_active = 1
            """, (target_skill_id, learner_id))

            candidates = [dict(r) for r in cursor.fetchall()]
            results = []

            for cand in candidates:
                teacher_id = cand["teacher_id"]

                # Check teacher availability
                cursor.execute("SELECT day_of_week, start_time, end_time FROM user_availability WHERE user_id = ?", (teacher_id,))
                teacher_slots = [dict(r) for r in cursor.fetchall()]
                teacher_days = {slot["day_of_week"] for slot in teacher_slots}

                overlap_days = learner_days.intersection(teacher_days)
                has_overlap = len(overlap_days) > 0

                # Score calculation
                # 1. Proficiency & verification weight (max 40)
                prof_weights = {"EXPERT": 40, "ADVANCED": 35, "INTERMEDIATE": 25, "ELEMENTARY": 15, "BEGINNER": 10}
                prof_score = prof_weights.get(cand["proficiency"], 20)
                if cand["verification_status"] in ("PEER_VERIFIED", "CHALLENGE_VERIFIED"):
                    prof_score = min(40, prof_score + 5)

                # 2. Availability score (max 25)
                avail_score = 25 if has_overlap else 5

                # 3. Reputation score (max 20)
                rep_score = round((cand["reputation_score"] / 5.0) * 20, 1)

                # 4. Experience & activity (max 15)
                exp_score = min(15, cand["completed_sessions"] * 3 + 5)

                total_score = round(prof_score + avail_score + rep_score + exp_score, 1)

                # Build explainable rationale
                reasons = []
                reasons.append(f"Holds {cand['proficiency']} proficiency in {skill_name}")
                if cand["verification_status"] != "UNVERIFIED":
                    reasons.append("Skill is verified on the platform")
                if has_overlap:
                    day_names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    common_day_strs = [day_names[d] for d in sorted(overlap_days)]
                    reasons.append(f"Matching availability on {', '.join(common_day_strs)}")
                else:
                    reasons.append("Flexible scheduling available")
                reasons.append(f"Strong teaching reputation ({cand['reputation_score']}/5.0)")

                cand["match_score"] = total_score
                cand["has_availability_overlap"] = has_overlap
                cand["match_reasons"] = reasons
                cand["teacher_slots"] = teacher_slots
                results.append(cand)

            results.sort(key=lambda x: x["match_score"], reverse=True)
            return results

    @staticmethod
    def get_skill_prerequisites(skill_id: int) -> Dict[str, Any]:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, name, slug, description FROM skills WHERE id = ?", (skill_id,))
            skill = cursor.fetchone()
            if not skill:
                return {}

            # Direct prerequisites
            cursor.execute("""
                SELECT s.id, s.name, s.slug, sr.relationship_type
                FROM skill_relationships sr
                JOIN skills s ON sr.source_skill_id = s.id
                WHERE sr.target_skill_id = ?
            """, (skill_id,))
            prerequisites = [dict(r) for r in cursor.fetchall()]

            # Dependents (skills that require this)
            cursor.execute("""
                SELECT s.id, s.name, s.slug, sr.relationship_type
                FROM skill_relationships sr
                JOIN skills s ON sr.target_skill_id = s.id
                WHERE sr.source_skill_id = ?
            """, (skill_id,))
            dependents = [dict(r) for r in cursor.fetchall()]

            return {
                "skill": dict(skill),
                "prerequisites": prerequisites,
                "unlocks": dependents
            }
