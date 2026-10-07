-- ============================================================================
-- SkillLoop Complex DBMS Demonstration Queries
-- Suitable for Academic Evaluation, Performance Analysis, and System Features
-- ============================================================================

-- Query 1: Multi-Criteria Mentor Matching Engine
-- Finds verified teachers matching a learner's target skill with overlapping weekend availability and high reputation
SELECT 
    t.id AS teacher_id,
    t.username,
    t.full_name,
    t.reputation_score,
    us.proficiency AS teacher_proficiency,
    us.verification_status,
    offer.credit_cost,
    ua.day_of_week,
    ua.start_time,
    ua.end_time
FROM users t
JOIN user_skills us ON t.id = us.user_id
JOIN skills s ON us.skill_id = s.id
JOIN teaching_offers offer ON t.id = offer.user_id AND offer.skill_id = s.id
JOIN user_availability ua ON t.id = ua.user_id
WHERE s.slug = 'sql-rdbms'
  AND offer.is_active = 1
  AND us.proficiency IN ('ADVANCED', 'EXPERT')
  AND ua.day_of_week IN (0, 6) -- Weekend availability
ORDER BY t.reputation_score DESC, offer.credit_cost ASC;

-- Query 2: Team Member Recruitment Matcher
-- Finds candidates who have ALL required skills for a team opening with remaining slots
SELECT 
    u.id AS candidate_id,
    u.username,
    u.full_name,
    u.reputation_score,
    t.name AS team_name,
    tro.role_title,
    s.name AS required_skill,
    us.proficiency
FROM team_openings tro
JOIN teams t ON tro.team_id = t.id
JOIN skills s ON tro.skill_id = s.id
JOIN user_skills us ON s.id = us.skill_id
JOIN users u ON us.user_id = u.id
WHERE tro.status = 'OPEN'
  AND (tro.slots_available - tro.slots_filled) > 0
  AND u.id NOT IN (SELECT user_id FROM team_members WHERE team_id = t.id)
ORDER BY u.reputation_score DESC;

-- Query 3: Mutual Learning & Teaching Compatibility (Pair Matching)
-- Identifies student pairs where User A teaches what User B wants to learn, AND User B teaches what User A wants to learn
SELECT * FROM v_mutual_skill_matches;

-- Query 4: Resource Quality & Engagement Metric with Weighted Scoring
SELECT 
    r.id,
    r.title,
    r.resource_type,
    s.name AS skill,
    r.view_count,
    r.rating_avg,
    r.rating_count,
    (r.rating_avg * 0.4 + (r.completion_count * 1.0 / NULLIF(r.view_count, 0)) * 50 * 0.3 + (r.rating_count * 0.3)) AS composite_quality_score
FROM resources r
JOIN skills s ON r.skill_id = s.id
WHERE r.rating_count > 0
ORDER BY composite_quality_score DESC;

-- Query 5: Double-Entry Credit Ledger Balance Verification & Reconciliation
-- Checks whether calculated transaction sum matches current account balance
SELECT 
    ca.user_id,
    u.username,
    ca.balance AS stored_balance,
    COALESCE(SUM(ct.amount), 0.0) AS computed_ledger_sum,
    (ca.balance - COALESCE(SUM(ct.amount), 0.0)) AS balance_discrepancy
FROM credit_accounts ca
JOIN users u ON ca.user_id = u.id
LEFT JOIN credit_transactions ct ON ca.user_id = ct.account_id
GROUP BY ca.user_id, u.username, ca.balance;

-- Query 6: Prerequisite Dependency Chain Traverser for a Target Skill
SELECT 
    prereq.id AS prerequisite_id,
    prereq.name AS prerequisite_skill,
    target.name AS target_skill,
    sr.relationship_type
FROM skill_relationships sr
JOIN skills prereq ON sr.source_skill_id = prereq.id
JOIN skills target ON sr.target_skill_id = target.id
WHERE target.slug = 'react';

-- Query 7: Active Hackathons with Available Team Openings Closing Soon
SELECT 
    c.id AS competition_id,
    c.title,
    c.registration_deadline,
    COUNT(DISTINCT t.id) AS total_teams,
    COUNT(DISTINCT tro.id) AS open_vacancies
FROM competitions c
LEFT JOIN teams t ON c.id = t.competition_id
LEFT JOIN team_openings tro ON t.id = tro.team_id AND tro.status = 'OPEN'
WHERE c.status = 'OPEN'
GROUP BY c.id, c.title, c.registration_deadline
ORDER BY c.registration_deadline ASC;

-- Query 8: User Multi-Dimensional Contribution Summary
SELECT * FROM v_user_reputation ORDER BY total_xp DESC, reputation_score DESC;

-- Query 9: Project Task Progress & Milestone Completion Percentage
SELECT 
    p.id AS project_id,
    p.title AS project_title,
    COUNT(pt.id) AS total_tasks,
    SUM(CASE WHEN pt.status = 'DONE' THEN 1 ELSE 0 END) AS completed_tasks,
    ROUND(SUM(CASE WHEN pt.status = 'DONE' THEN 1.0 ELSE 0.0 END) * 100 / NULLIF(COUNT(pt.id), 0), 1) AS task_progress_pct
FROM projects p
LEFT JOIN project_tasks pt ON p.id = pt.project_id
GROUP BY p.id, p.title;

-- Query 10: High-Performing Students Without Verified Skills (Anti-Gap Query)
-- Finds students who completed sessions or challenges but haven't formally submitted peer verifications
SELECT 
    u.id,
    u.username,
    u.full_name,
    COUNT(DISTINCT ls.id) AS completed_sessions
FROM users u
JOIN learning_sessions ls ON u.id = ls.teacher_id AND ls.status = 'COMPLETED'
WHERE u.id NOT IN (SELECT user_id FROM user_skills WHERE verification_status = 'PEER_VERIFIED')
GROUP BY u.id, u.username, u.full_name;
