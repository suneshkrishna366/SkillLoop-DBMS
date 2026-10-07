-- ============================================================================
-- SkillLoop Database Views (Analytical & Domain Reporting)
-- ============================================================================

-- 1. User Skill Summary View (Shows user skills with categories and verification)
CREATE VIEW IF NOT EXISTS v_user_skill_summary AS
SELECT 
    u.id AS user_id,
    u.username,
    u.full_name,
    u.institution,
    s.id AS skill_id,
    s.name AS skill_name,
    sc.name AS category_name,
    us.proficiency,
    us.verification_status,
    us.years_experience
FROM users u
JOIN user_skills us ON u.id = us.user_id
JOIN skills s ON us.skill_id = s.id
JOIN skill_categories sc ON s.category_id = sc.id;

-- 2. Open Team Vacancies View
CREATE VIEW IF NOT EXISTS v_team_openings AS
SELECT 
    t.id AS team_id,
    t.name AS team_name,
    c.title AS competition_title,
    u.username AS leader_username,
    t.current_member_count,
    t.max_members,
    tro.id AS opening_id,
    tro.role_title,
    s.name AS required_skill,
    tro.min_proficiency,
    (tro.slots_available - tro.slots_filled) AS remaining_slots
FROM team_openings tro
JOIN teams t ON tro.team_id = t.id
JOIN skills s ON tro.skill_id = s.id
JOIN users u ON t.leader_id = u.id
LEFT JOIN competitions c ON t.competition_id = c.id
WHERE tro.status = 'OPEN' AND (tro.slots_available - tro.slots_filled) > 0;

-- 3. Resource Quality & Engagement Metric View
CREATE VIEW IF NOT EXISTS v_resource_quality AS
SELECT 
    r.id AS resource_id,
    r.title,
    r.resource_type,
    s.name AS skill_name,
    u.username AS uploader,
    r.difficulty,
    r.view_count,
    COUNT(DISTINCT rr.user_id) AS total_ratings,
    COALESCE(AVG(rr.rating), 0.0) AS calculated_avg_rating,
    COUNT(DISTINCT rc.user_id) AS total_completions,
    COUNT(DISTINCT rb.user_id) AS total_bookmarks
FROM resources r
JOIN skills s ON r.skill_id = s.id
JOIN users u ON r.uploader_id = u.id
LEFT JOIN resource_ratings rr ON r.id = rr.resource_id
LEFT JOIN resource_completions rc ON r.id = rc.resource_id
LEFT JOIN resource_bookmarks rb ON r.id = rb.resource_id
GROUP BY r.id, r.title, r.resource_type, s.name, u.username, r.difficulty, r.view_count;

-- 4. User Multi-Dimensional Reputation View
CREATE VIEW IF NOT EXISTS v_user_reputation AS
SELECT 
    u.id AS user_id,
    u.username,
    u.full_name,
    u.reputation_score,
    ca.balance AS credit_balance,
    COUNT(DISTINCT ls.id) AS sessions_taught,
    COALESCE(AVG(sr.rating), 5.0) AS avg_teaching_rating,
    COUNT(DISTINCT p.id) AS projects_owned,
    COUNT(DISTINCT cs.id) AS challenges_completed,
    COALESCE(SUM(cs.xp_awarded), 0) AS total_xp
FROM users u
LEFT JOIN credit_accounts ca ON u.id = ca.user_id
LEFT JOIN learning_sessions ls ON u.id = ls.teacher_id AND ls.status = 'COMPLETED'
LEFT JOIN session_reviews sr ON u.id = sr.reviewee_id
LEFT JOIN projects p ON u.id = p.owner_id
LEFT JOIN challenge_submissions cs ON u.id = cs.user_id AND cs.status = 'PASSED'
GROUP BY u.id, u.username, u.full_name, u.reputation_score, ca.balance;

-- 5. Mutual Mentor-Learner Compatibility Match View
CREATE VIEW IF NOT EXISTS v_mutual_skill_matches AS
SELECT 
    user_a.id AS user_a_id,
    user_a.username AS user_a_name,
    user_b.id AS user_b_id,
    user_b.username AS user_b_name,
    skill_a_teaches.name AS a_teaches_b,
    skill_b_teaches.name AS b_teaches_a
FROM users user_a
-- User A teaches skill X which User B has as a learning goal
JOIN teaching_offers offer_a ON user_a.id = offer_a.user_id AND offer_a.is_active = 1
JOIN learning_goals goal_b ON offer_a.skill_id = goal_b.skill_id AND goal_b.status = 'ACTIVE'
JOIN users user_b ON goal_b.user_id = user_b.id AND user_a.id != user_b.id
-- User B teaches skill Y which User A has as a learning goal
JOIN teaching_offers offer_b ON user_b.id = offer_b.user_id AND offer_b.is_active = 1
JOIN learning_goals goal_a ON offer_b.skill_id = goal_a.skill_id AND goal_a.status = 'ACTIVE' AND goal_a.user_id = user_a.id
JOIN skills skill_a_teaches ON offer_a.skill_id = skill_a_teaches.id
JOIN skills skill_b_teaches ON offer_b.skill_id = skill_b_teaches.id
WHERE user_a.id < user_b.id;
