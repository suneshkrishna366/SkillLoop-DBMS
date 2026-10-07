-- ============================================================================
-- SkillLoop Database Schema (3NF Relational Core)
-- Supports SQLite and standard SQL relational engines
-- ============================================================================

-- 1. ROLES & PERMISSIONS
CREATE TABLE IF NOT EXISTS roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 2. USERS (STUDENTS, MENTORS, ADMINS)
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    institution VARCHAR(150),
    department VARCHAR(100),
    year_of_study INTEGER CHECK (year_of_study IS NULL OR (year_of_study >= 1 AND year_of_study <= 6)),
    github_url VARCHAR(255),
    linkedin_url VARCHAR(255),
    reputation_score DECIMAL(4, 2) DEFAULT 5.00 CHECK (reputation_score >= 0.00 AND reputation_score <= 5.00),
    is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. USER ROLES (MANY-TO-MANY)
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 4. USER PRIVACY SETTINGS (1-TO-1)
CREATE TABLE IF NOT EXISTS user_privacy_settings (
    user_id INTEGER PRIMARY KEY,
    show_email INTEGER DEFAULT 0 CHECK (show_email IN (0, 1)),
    show_institution INTEGER DEFAULT 1 CHECK (show_institution IN (0, 1)),
    profile_visibility VARCHAR(20) DEFAULT 'PUBLIC' CHECK (profile_visibility IN ('PUBLIC', 'COMMUNITY_ONLY', 'CONNECTIONS_ONLY', 'PRIVATE')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. SKILL CATEGORIES
CREATE TABLE IF NOT EXISTS skill_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50) DEFAULT 'code'
);

-- 6. SKILLS TAXONOMY
CREATE TABLE IF NOT EXISTS skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    popularity_count INTEGER DEFAULT 0 CHECK (popularity_count >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES skill_categories(id) ON DELETE RESTRICT
);

-- 7. SKILL RELATIONSHIPS (GRAPH DIRECTED EDGES)
CREATE TABLE IF NOT EXISTS skill_relationships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_skill_id INTEGER NOT NULL,
    target_skill_id INTEGER NOT NULL,
    relationship_type VARCHAR(30) NOT NULL CHECK (relationship_type IN ('PREREQUISITE_OF', 'RELATED_TO', 'SPECIALIZATION_OF', 'COMMONLY_USED_WITH')),
    FOREIGN KEY (source_skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    FOREIGN KEY (target_skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    UNIQUE(source_skill_id, target_skill_id, relationship_type),
    CHECK (source_skill_id != target_skill_id)
);

-- 8. USER SKILLS & PROFICIENCY
CREATE TABLE IF NOT EXISTS user_skills (
    user_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    proficiency VARCHAR(20) NOT NULL CHECK (proficiency IN ('BEGINNER', 'ELEMENTARY', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    years_experience DECIMAL(3, 1) DEFAULT 0.0 CHECK (years_experience >= 0.0),
    evidence_url TEXT,
    verification_status VARCHAR(30) DEFAULT 'UNVERIFIED' CHECK (verification_status IN ('UNVERIFIED', 'PEER_VERIFIED', 'CHALLENGE_VERIFIED')),
    verified_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, skill_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

-- 9. USER AVAILABILITY SLOTS
CREATE TABLE IF NOT EXISTS user_availability (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
    start_time VARCHAR(5) NOT NULL, -- Format HH:MM
    end_time VARCHAR(5) NOT NULL,   -- Format HH:MM
    timezone VARCHAR(50) DEFAULT 'UTC',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (end_time > start_time)
);

-- 10. LEARNING GOALS
CREATE TABLE IF NOT EXISTS learning_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    target_date DATE,
    progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ABANDONED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 11. KNOWLEDGE HUB: RESOURCES & TUTORIALS
CREATE TABLE IF NOT EXISTS resources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uploader_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    resource_type VARCHAR(30) NOT NULL CHECK (resource_type IN ('NOTE', 'PDF', 'CHEAT_SHEET', 'CODE_REPOSITORY', 'ARTICLE', 'YOUTUBE_VIDEO', 'YOUTUBE_PLAYLIST', 'COURSE', 'DOCUMENTATION')),
    content_url TEXT NOT NULL,
    author_name VARCHAR(100),
    difficulty VARCHAR(20) DEFAULT 'INTERMEDIATE' CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    completion_count INTEGER DEFAULT 0 CHECK (completion_count >= 0),
    rating_avg DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating_avg >= 0.00 AND rating_avg <= 5.00),
    rating_count INTEGER DEFAULT 0 CHECK (rating_count >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 12. RESOURCE RATINGS & REVIEWS
CREATE TABLE IF NOT EXISTS resource_ratings (
    resource_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resource_id, user_id),
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 13. RESOURCE COMPLETIONS
CREATE TABLE IF NOT EXISTS resource_completions (
    resource_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resource_id, user_id),
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 14. RESOURCE BOOKMARKS
CREATE TABLE IF NOT EXISTS resource_bookmarks (
    resource_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resource_id, user_id),
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 15. SOCIAL FEED POSTS
CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    post_type VARCHAR(30) NOT NULL CHECK (post_type IN ('GENERAL', 'QUESTION', 'RESOURCE_SHARE', 'PROJECT_UPDATE', 'ACHIEVEMENT', 'OPPORTUNITY', 'DISCUSSION')),
    related_skill_id INTEGER,
    accepted_answer_id INTEGER,
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    comment_count INTEGER DEFAULT 0 CHECK (comment_count >= 0),
    reaction_count INTEGER DEFAULT 0 CHECK (reaction_count >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_skill_id) REFERENCES skills(id) ON DELETE SET NULL
);

-- 16. POST COMMENTS
CREATE TABLE IF NOT EXISTS post_comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    parent_comment_id INTEGER,
    content TEXT NOT NULL,
    is_accepted_answer INTEGER DEFAULT 0 CHECK (is_accepted_answer IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES post_comments(id) ON DELETE CASCADE
);

-- 17. POST REACTIONS
CREATE TABLE IF NOT EXISTS post_reactions (
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    reaction_type VARCHAR(20) NOT NULL CHECK (reaction_type IN ('LIKE', 'INSIGHTFUL', 'CELEBRATE', 'HELPFUL')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 18. SKILL EXCHANGE: TEACHING OFFERS
CREATE TABLE IF NOT EXISTS teaching_offers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    min_learner_level VARCHAR(20) DEFAULT 'BEGINNER',
    max_learner_level VARCHAR(20) DEFAULT 'ADVANCED',
    session_format VARCHAR(20) DEFAULT 'ONLINE' CHECK (session_format IN ('ONLINE', 'IN_PERSON', 'HYBRID')),
    session_duration_minutes INTEGER DEFAULT 60 CHECK (session_duration_minutes IN (30, 60, 90)),
    credit_cost DECIMAL(3, 1) DEFAULT 1.0 CHECK (credit_cost >= 0.0),
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 19. LEARNING SESSIONS
CREATE TABLE IF NOT EXISTS learning_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    teacher_id INTEGER NOT NULL,
    learner_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    status VARCHAR(20) DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'ACCEPTED', 'SCHEDULED', 'COMPLETED', 'DECLINED', 'CANCELLED', 'NO_SHOW', 'DISPUTED')),
    meeting_url TEXT,
    notes TEXT,
    credit_settled INTEGER DEFAULT 0 CHECK (credit_settled IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (learner_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT,
    CHECK (teacher_id != learner_id),
    CHECK (scheduled_end > scheduled_start)
);

-- 20. SESSION REVIEWS
CREATE TABLE IF NOT EXISTS session_reviews (
    session_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    teaching_clarity INTEGER CHECK (teaching_clarity IS NULL OR (teaching_clarity >= 1 AND teaching_clarity <= 5)),
    punctuality INTEGER CHECK (punctuality IS NULL OR (punctuality >= 1 AND punctuality <= 5)),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id, reviewer_id),
    FOREIGN KEY (session_id) REFERENCES learning_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE RESTRICT,
    CHECK (reviewer_id != reviewee_id)
);

-- 21. SKILL CREDITS: USER ACCOUNT
CREATE TABLE IF NOT EXISTS credit_accounts (
    user_id INTEGER PRIMARY KEY,
    balance DECIMAL(8, 2) DEFAULT 5.00 CHECK (balance >= 0.00),
    total_earned DECIMAL(8, 2) DEFAULT 5.00 CHECK (total_earned >= 0.00),
    total_spent DECIMAL(8, 2) DEFAULT 0.00 CHECK (total_spent >= 0.00),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 22. SKILL CREDITS: IMMUTABLE TRANSACTION LEDGER
CREATE TABLE IF NOT EXISTS credit_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    amount DECIMAL(8, 2) NOT NULL, -- Positive for credit, negative for debit
    transaction_type VARCHAR(30) NOT NULL CHECK (transaction_type IN ('EARNED_TEACHING', 'SPENT_LEARNING', 'BONUS_ONBOARDING', 'CHALLENGE_REWARD', 'REFUND')),
    session_id INTEGER,
    balance_after DECIMAL(8, 2) NOT NULL CHECK (balance_after >= 0.00),
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES credit_accounts(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (session_id) REFERENCES learning_sessions(id) ON DELETE SET NULL
);

-- 23. COMPETITIONS & HACKATHONS
CREATE TABLE IF NOT EXISTS competitions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(150) NOT NULL,
    organizer VARCHAR(100) NOT NULL,
    competition_type VARCHAR(30) DEFAULT 'HACKATHON' CHECK (competition_type IN ('HACKATHON', 'CODING_CONTEST', 'DESIGN_SPRINT', 'RESEARCH_CHALLENGE')),
    description TEXT NOT NULL,
    eligibility TEXT,
    registration_deadline TIMESTAMP NOT NULL,
    event_start TIMESTAMP NOT NULL,
    event_end TIMESTAMP NOT NULL,
    website_url VARCHAR(255),
    banner_url VARCHAR(255),
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('UPCOMING', 'OPEN', 'IN_PROGRESS', 'COMPLETED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (event_end >= event_start)
);

-- 24. COMPETITION SKILLS
CREATE TABLE IF NOT EXISTS competition_skills (
    competition_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    PRIMARY KEY (competition_id, skill_id),
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 25. TEAMS
CREATE TABLE IF NOT EXISTS teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    competition_id INTEGER,
    name VARCHAR(100) NOT NULL,
    leader_id INTEGER NOT NULL,
    description TEXT,
    max_members INTEGER DEFAULT 4 CHECK (max_members >= 1 AND max_members <= 10),
    current_member_count INTEGER DEFAULT 1 CHECK (current_member_count >= 1 AND current_member_count <= max_members),
    status VARCHAR(20) DEFAULT 'RECRUITING' CHECK (status IN ('RECRUITING', 'FULL', 'CLOSED', 'COMPLETED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE SET NULL,
    FOREIGN KEY (leader_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 26. TEAM MEMBERS
CREATE TABLE IF NOT EXISTS team_members (
    team_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    role_title VARCHAR(50) DEFAULT 'Member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (team_id, user_id),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 27. TEAM OPENINGS
CREATE TABLE IF NOT EXISTS team_openings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    role_title VARCHAR(100) NOT NULL,
    skill_id INTEGER NOT NULL,
    min_proficiency VARCHAR(20) DEFAULT 'INTERMEDIATE',
    slots_available INTEGER DEFAULT 1 CHECK (slots_available >= 1),
    slots_filled INTEGER DEFAULT 0 CHECK (slots_filled >= 0 AND slots_filled <= slots_available),
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'FILLED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 28. TEAM APPLICATIONS
CREATE TABLE IF NOT EXISTS team_applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    opening_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    applicant_id INTEGER NOT NULL,
    pitch_message TEXT,
    status VARCHAR(20) DEFAULT 'SUBMITTED' CHECK (status IN ('SUBMITTED', 'UNDER_REVIEW', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (opening_id) REFERENCES team_openings(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(opening_id, applicant_id)
);

-- 29. OPPORTUNITIES
CREATE TABLE IF NOT EXISTS opportunities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    creator_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    opportunity_type VARCHAR(30) NOT NULL CHECK (opportunity_type IN ('HACKATHON_TEAM', 'PROJECT_COLLABORATION', 'STUDY_PARTNER', 'MENTOR_REQUEST', 'RESEARCH_PARTNER', 'EVENT_SPEAKER')),
    description TEXT NOT NULL,
    required_skill_id INTEGER,
    slots_total INTEGER DEFAULT 1 CHECK (slots_total >= 1),
    slots_filled INTEGER DEFAULT 0 CHECK (slots_filled >= 0 AND slots_filled <= slots_total),
    deadline DATE,
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED', 'ARCHIVED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (required_skill_id) REFERENCES skills(id) ON DELETE SET NULL
);

-- 30. PROJECTS
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    tagline VARCHAR(255),
    problem_statement TEXT,
    solution_description TEXT,
    github_url VARCHAR(255),
    demo_url VARCHAR(255),
    competition_id INTEGER,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('PLANNING', 'ACTIVE', 'COMPLETED', 'ARCHIVED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE SET NULL
);

-- 31. PROJECT MEMBERS
CREATE TABLE IF NOT EXISTS project_members (
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    role_title VARCHAR(50) DEFAULT 'Contributor',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, user_id),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 32. PROJECT SKILLS
CREATE TABLE IF NOT EXISTS project_skills (
    project_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, skill_id),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 33. PROJECT KANBAN TASKS
CREATE TABLE IF NOT EXISTS project_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    assignee_id INTEGER,
    status VARCHAR(20) DEFAULT 'TODO' CHECK (status IN ('TODO', 'IN_PROGRESS', 'BLOCKED', 'DONE')),
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 34. PROJECT MILESTONES
CREATE TABLE IF NOT EXISTS project_milestones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    target_date DATE,
    is_completed INTEGER DEFAULT 0 CHECK (is_completed IN (0, 1)),
    completed_at TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- 35. CHALLENGES
CREATE TABLE IF NOT EXISTS challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    skill_id INTEGER NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'MEDIUM' CHECK (difficulty IN ('EASY', 'MEDIUM', 'HARD')),
    xp_reward INTEGER DEFAULT 100 CHECK (xp_reward >= 0),
    time_limit_minutes INTEGER DEFAULT 45,
    sample_code TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE RESTRICT
);

-- 36. CHALLENGE SUBMISSIONS
CREATE TABLE IF NOT EXISTS challenge_submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    challenge_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    code_submission TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PASSED' CHECK (status IN ('SUBMITTED', 'EVALUATING', 'PASSED', 'FAILED')),
    score INTEGER DEFAULT 100 CHECK (score >= 0 AND score <= 100),
    xp_awarded INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 37. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    type VARCHAR(30) NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    entity_type VARCHAR(30),
    entity_id INTEGER,
    is_read INTEGER DEFAULT 0 CHECK (is_read IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 38. REPORTS (MODERATION)
CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporter_id INTEGER NOT NULL,
    target_type VARCHAR(20) NOT NULL CHECK (target_type IN ('POST', 'COMMENT', 'RESOURCE', 'USER', 'TEAM')),
    target_id INTEGER NOT NULL,
    reason VARCHAR(50) NOT NULL,
    details TEXT,
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'DISMISSED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 39. SYSTEM AUDIT LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    actor_id INTEGER,
    action VARCHAR(50) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id INTEGER,
    details_json TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================================
-- INDEXES FOR QUERY OPTIMIZATION
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_user_skills_lookup ON user_skills(skill_id, proficiency);
CREATE INDEX IF NOT EXISTS idx_resources_skill_type ON resources(skill_id, resource_type);
CREATE INDEX IF NOT EXISTS idx_resources_created ON resources(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_learning_sessions_teacher ON learning_sessions(teacher_id, status);
CREATE INDEX IF NOT EXISTS idx_learning_sessions_learner ON learning_sessions(learner_id, status);
CREATE INDEX IF NOT EXISTS idx_team_openings_skill ON team_openings(skill_id, status);
CREATE INDEX IF NOT EXISTS idx_team_apps_team ON team_applications(team_id, status);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);
