# SkillLoop Database Specification & Schema Architecture

## 1. Relational Integrity Rules
1. **Third Normal Form (3NF)**: All non-key attributes are fully functionally dependent directly and solely on the primary key.
2. **Referential Integrity**: All foreign keys strictly enforce relational consistency (`ON DELETE CASCADE` or `ON DELETE RESTRICT` deliberately chosen per entity).
3. **No Unstructured Strings for Discrete States**: All status workflows (e.g., `REQUESTED`, `SCHEDULED`, `COMPLETED`, `ACCEPTED`, `REJECTED`) are strictly validated with `CHECK` constraints.
4. **Ledger Immutability**: `credit_transactions` and `audit_logs` are insert-only audit trails. No direct `UPDATE` operations are permitted on transaction rows.
5. **No Negative Balances**: Credit accounts enforce `balance >= 0.0` via database constraints.

---

## 2. Table Catalog Overview

### 2.1 Identity & Access Management
- `users`: ID, username (UNIQUE), email (UNIQUE), password_hash, full_name, bio, avatar_url, institution, department, year, github_url, linkedin_url, reputation_score, created_at, updated_at
- `roles`: ID, name (`STUDENT`, `TEAM_LEADER`, `MODERATOR`, `ADMIN`), description
- `user_roles`: Composite PK `(user_id, role_id)`
- `user_privacy_settings`: user_id (PK), show_email, show_institution, profile_visibility

### 2.2 Skill Taxonomy & Graph
- `skill_categories`: ID, name (UNIQUE), slug (UNIQUE), description, icon
- `skills`: ID, category_id (FK), name (UNIQUE), slug (UNIQUE), description, popularity_count
- `skill_relationships`: ID, source_skill_id (FK), target_skill_id (FK), relationship_type (`PREREQUISITE_OF`, `RELATED_TO`, `SPECIALIZATION_OF`, `COMMONLY_USED_WITH`), UNIQUE `(source_skill_id, target_skill_id, relationship_type)`
- `user_skills`: Composite PK `(user_id, skill_id)`, proficiency (`BEGINNER`, `ELEMENTARY`, `INTERMEDIATE`, `ADVANCED`, `EXPERT`), evidence_url, verification_status (`UNVERIFIED`, `PEER_VERIFIED`, `CHALLENGE_VERIFIED`), verified_at, updated_at
- `user_availability`: ID, user_id (FK), day_of_week (0-6), start_time (HH:MM), end_time (HH:MM), timezone
- `learning_goals`: ID, user_id (FK), skill_id (FK), title, target_date, progress_percent (0-100), status (`ACTIVE`, `COMPLETED`, `ABANDONED`)

### 2.3 Knowledge Hub
- `resources`: ID, uploader_id (FK), skill_id (FK), title, description, resource_type (`NOTE`, `PDF`, `CHEAT_SHEET`, `CODE_REPOSITORY`, `ARTICLE`, `YOUTUBE_VIDEO`, `YOUTUBE_PLAYLIST`, `COURSE`, `DOCUMENTATION`), content_url, author_name, difficulty (`BEGINNER`, `INTERMEDIATE`, `ADVANCED`), view_count, completion_count, rating_avg, rating_count, created_at, updated_at
- `resource_ratings`: Composite PK `(resource_id, user_id)`, rating (1 to 5), review_text, created_at
- `resource_completions`: Composite PK `(resource_id, user_id)`, completed_at
- `resource_bookmarks`: Composite PK `(resource_id, user_id)`, created_at

### 2.4 Social Discussions & Feed
- `posts`: ID, author_id (FK), title, content, post_type (`GENERAL`, `QUESTION`, `RESOURCE_SHARE`, `PROJECT_UPDATE`, `ACHIEVEMENT`, `OPPORTUNITY`, `DISCUSSION`), related_skill_id (FK, nullable), accepted_answer_id, view_count, comment_count, reaction_count, created_at, updated_at
- `post_comments`: ID, post_id (FK), author_id (FK), parent_comment_id (FK, nullable), content, is_accepted_answer (BOOLEAN), created_at, updated_at
- `post_reactions`: Composite PK `(post_id, user_id)`, reaction_type (`LIKE`, `INSIGHTFUL`, `CELEBRATE`, `HELPFUL`), created_at

### 2.5 Skill Exchange Engine
- `teaching_offers`: ID, user_id (FK), skill_id (FK), min_learner_level, max_learner_level, session_format (`ONLINE`, `IN_PERSON`, `HYBRID`), session_duration_minutes (30, 60, 90), credit_cost, language, description, is_active, created_at
- `learning_sessions`: ID, teacher_id (FK), learner_id (FK), skill_id (FK), scheduled_start, scheduled_end, duration_minutes, status (`REQUESTED`, `ACCEPTED`, `SCHEDULED`, `COMPLETED`, `DECLINED`, `CANCELLED`, `NO_SHOW`, `DISPUTED`), meeting_url, notes, credit_settled (BOOLEAN), created_at, updated_at
- `session_reviews`: Composite PK `(session_id, reviewer_id)`, reviewee_id (FK), rating (1 to 5), teaching_clarity (1 to 5), punctuality (1 to 5), comments, created_at
- `credit_accounts`: user_id (PK), balance (DECIMAL >= 0.0), total_earned (DECIMAL), total_spent (DECIMAL), updated_at
- `credit_transactions`: ID, account_id (FK), amount (DECIMAL), transaction_type (`EARNED_TEACHING`, `SPENT_LEARNING`, `BONUS_ONBOARDING`, `CHALLENGE_REWARD`, `REFUND`), session_id (FK, nullable), balance_after (DECIMAL), idempotency_key (UNIQUE), description, created_at

### 2.6 Hackathons, Teams & Opportunities
- `competitions`: ID, title, organizer, competition_type (`HACKATHON`, `CODING_CONTEST`, `DESIGN_SPRINT`, `RESEARCH_CHALLENGE`), description, eligibility, registration_deadline, event_start, event_end, website_url, banner_url, status (`UPCOMING`, `OPEN`, `IN_PROGRESS`, `COMPLETED`), created_at
- `competition_skills`: Composite PK `(competition_id, skill_id)`
- `teams`: ID, competition_id (FK, nullable), name, leader_id (FK), description, max_members, current_member_count, status (`RECRUITING`, `FULL`, `CLOSED`, `COMPLETED`), created_at, updated_at
- `team_members`: Composite PK `(team_id, user_id)`, role_title, joined_at
- `team_openings`: ID, team_id (FK), role_title, skill_id (FK), min_proficiency, slots_available, slots_filled, status (`OPEN`, `FILLED`, `CANCELLED`), created_at
- `team_applications`: ID, opening_id (FK), team_id (FK), applicant_id (FK), pitch_message, status (`SUBMITTED`, `UNDER_REVIEW`, `ACCEPTED`, `REJECTED`, `WITHDRAWN`), reviewed_at, created_at
- `opportunities`: ID, creator_id (FK), title, opportunity_type (`HACKATHON_TEAM`, `PROJECT_COLLABORATION`, `STUDY_PARTNER`, `MENTOR_REQUEST`, `RESEARCH_PARTNER`, `EVENT_SPEAKER`), description, required_skill_id (FK, nullable), slots_total, slots_filled, deadline, status (`OPEN`, `CLOSED`, `ARCHIVED`), created_at

### 2.7 Projects & Challenges
- `projects`: ID, owner_id (FK), title, tagline, problem_statement, solution_description, github_url, demo_url, competition_id (FK, nullable), status (`PLANNING`, `ACTIVE`, `COMPLETED`, `ARCHIVED`), created_at, updated_at
- `project_members`: Composite PK `(project_id, user_id)`, role_title, joined_at
- `project_skills`: Composite PK `(project_id, skill_id)`
- `project_tasks`: ID, project_id (FK), title, description, assignee_id (FK, nullable), status (`TODO`, `IN_PROGRESS`, `BLOCKED`, `DONE`), priority (`LOW`, `MEDIUM`, `HIGH`, `URGENT`), due_date, created_at, updated_at
- `project_milestones`: ID, project_id (FK), title, description, target_date, is_completed, completed_at
- `challenges`: ID, title, description, skill_id (FK), difficulty (`EASY`, `MEDIUM`, `HARD`), xp_reward, time_limit_minutes, test_cases_json, created_at
- `challenge_submissions`: ID, challenge_id (FK), user_id (FK), code_submission, status (`SUBMITTED`, `EVALUATING`, `PASSED`, `FAILED`), score, xp_awarded, created_at

### 2.8 Notifications & Audit
- `notifications`: ID, user_id (FK), type, title, message, entity_type, entity_id, is_read, created_at
- `reports`: ID, reporter_id (FK), target_type (`POST`, `COMMENT`, `RESOURCE`, `USER`, `TEAM`), target_id, reason, details, status (`OPEN`, `UNDER_REVIEW`, `RESOLVED`, `DISMISSED`), created_at
- `audit_logs`: ID, actor_id (FK, nullable), action, target_type, target_id, details_json, ip_address, created_at

---

## 3. Database Views
1. `v_user_skill_summary`: Aggregates each user's declared and verified skills with categories.
2. `v_team_openings`: Aggregates available roles with remaining vacant slots.
3. `v_resource_quality`: Computes rating averages, total reviews, completions, and bookmarks.
4. `v_user_reputation`: Combines teaching ratings, reliability rates, sessions completed, and challenge XP into multi-dimensional reputation scores.
5. `v_mutual_skill_matches`: Relational join identifying user pairs where User A teaches what User B seeks to learn and vice versa.
