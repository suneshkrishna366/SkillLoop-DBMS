-- ============================================================================
-- SkillLoop Database Triggers (Audit Trail & Integrity Automation)
-- ============================================================================

-- 1. Automatically create credit account and privacy settings upon user registration
CREATE TRIGGER IF NOT EXISTS trg_after_user_insert
AFTER INSERT ON users
BEGIN
    INSERT INTO credit_accounts (user_id, balance, total_earned, total_spent)
    VALUES (NEW.id, 5.00, 5.00, 0.00);

    INSERT INTO user_privacy_settings (user_id, show_email, show_institution, profile_visibility)
    VALUES (NEW.id, 0, 1, 'PUBLIC');

    INSERT INTO audit_logs (actor_id, action, target_type, target_id, details_json)
    VALUES (NEW.id, 'USER_REGISTERED', 'USER', NEW.id, '{"username": "' || NEW.username || '"}');
END;

-- 2. Audit Trail on Role Assignment
CREATE TRIGGER IF NOT EXISTS trg_after_role_assigned
AFTER INSERT ON user_roles
BEGIN
    INSERT INTO audit_logs (actor_id, action, target_type, target_id, details_json)
    VALUES (NEW.user_id, 'ROLE_ASSIGNED', 'ROLE', NEW.role_id, '{"user_id": ' || NEW.user_id || '}');
END;

-- 3. Update Resource Aggregated Rating on New Rating Insert
CREATE TRIGGER IF NOT EXISTS trg_after_resource_rating_insert
AFTER INSERT ON resource_ratings
BEGIN
    UPDATE resources
    SET rating_count = (SELECT COUNT(*) FROM resource_ratings WHERE resource_id = NEW.resource_id),
        rating_avg = (SELECT ROUND(AVG(rating), 2) FROM resource_ratings WHERE resource_id = NEW.resource_id)
    WHERE id = NEW.resource_id;
END;

-- 4. Audit Trail on Moderation Report Status Change
CREATE TRIGGER IF NOT EXISTS trg_after_report_status_update
AFTER UPDATE OF status ON reports
BEGIN
    INSERT INTO audit_logs (actor_id, action, target_type, target_id, details_json)
    VALUES (NULL, 'REPORT_STATUS_CHANGED', 'REPORT', NEW.id, '{"old_status": "' || OLD.status || '", "new_status": "' || NEW.status || '"}');
END;

-- 5. Auto increment comment_count on posts
CREATE TRIGGER IF NOT EXISTS trg_after_post_comment_insert
AFTER INSERT ON post_comments
BEGIN
    UPDATE posts
    SET comment_count = (SELECT COUNT(*) FROM post_comments WHERE post_id = NEW.post_id)
    WHERE id = NEW.post_id;
END;
