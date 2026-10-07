-- ============================================================================
-- SkillLoop Realistic Seed Data
-- ============================================================================

-- Roles
INSERT OR IGNORE INTO roles (id, name, description) VALUES
(1, 'STUDENT', 'Standard student member seeking learning, collaboration and projects'),
(2, 'TEAM_LEADER', 'Team manager and project organizer with vacancy recruiting permissions'),
(3, 'MODERATOR', 'Community moderator handling content reviews and reports'),
(4, 'ADMIN', 'System administrator with full platform control');

-- Skill Categories
INSERT OR IGNORE INTO skill_categories (id, name, slug, description, icon) VALUES
(1, 'Programming Languages', 'programming-languages', 'Core languages for software and systems', 'terminal'),
(2, 'Web & Full Stack', 'web-development', 'Frontend, backend and modern web frameworks', 'globe'),
(3, 'Database Management', 'databases', 'Relational, NoSQL, data modeling and query optimization', 'database'),
(4, 'AI & Machine Learning', 'ai-machine-learning', 'Data science, neural networks and computer vision', 'cpu'),
(5, 'Embedded & IoT', 'embedded-iot', 'Microcontrollers, sensors and hardware firmware', 'hard-drive'),
(6, 'DevOps & Cloud', 'devops-cloud', 'CI/CD, Docker, cloud deployment and infrastructure', 'cloud');

-- Master Skills
INSERT OR IGNORE INTO skills (id, category_id, name, slug, description, popularity_count) VALUES
(1, 1, 'C++', 'cpp', 'High performance systems, competitive programming, and algorithms', 142),
(2, 1, 'Java', 'java', 'Object oriented design, enterprise backends, and Android', 118),
(3, 1, 'Python', 'python', 'General scripting, automation, data science and FastAPI', 195),
(4, 2, 'HTML & CSS', 'html-css', 'Semantic markup, modern layout, flexbox, grid, animations', 210),
(5, 2, 'JavaScript', 'javascript', 'ES6+ async programming, browser APIs, and Node.js', 230),
(6, 2, 'React.js', 'react', 'Component architecture, hooks, state management and SPAs', 205),
(7, 2, 'FastAPI / Node Backend', 'backend-api', 'RESTful API design, auth middleware and concurrency', 160),
(8, 3, 'SQL & Relational Design', 'sql-rdbms', '3NF normalization, ACID transactions, views and indexing', 180),
(9, 3, 'PostgreSQL / MySQL', 'postgres-mysql', 'Enterprise relational databases and query execution plans', 150),
(10, 4, 'Machine Learning Basics', 'ml-basics', 'Scikit-learn, classification, regression, clustering', 125),
(11, 5, 'ESP32 & Microcontrollers', 'esp32-embedded', 'FreeRTOS, GPIO sensors, WiFi IoT nodes', 95),
(12, 6, 'Docker & Deployment', 'docker-deployment', 'Containerization, environment configuration, hosting', 110);

-- Skill Relationships (Prerequisite & Hierarchy Graph)
INSERT OR IGNORE INTO skill_relationships (source_skill_id, target_skill_id, relationship_type) VALUES
(4, 5, 'PREREQUISITE_OF'),       -- HTML/CSS -> JavaScript
(5, 6, 'PREREQUISITE_OF'),       -- JavaScript -> React
(5, 7, 'PREREQUISITE_OF'),       -- JavaScript -> Backend API
(8, 9, 'PREREQUISITE_OF'),       -- SQL/RDBMS -> Postgres/MySQL
(3, 10, 'PREREQUISITE_OF'),      -- Python -> Machine Learning
(1, 11, 'COMMONLY_USED_WITH'),   -- C++ -> ESP32
(7, 8, 'COMMONLY_USED_WITH'),    -- Backend API -> SQL
(8, 7, 'COMMONLY_USED_WITH');

-- Users (Password for all demo users is 'SkillLoopPass123!' - hashed using PBKDF2 standard demo hash)
-- Password hash: 'pbkdf2_sha256$260000$demo_salt$5d41402abc4b2a76b9719d911017c592'
INSERT OR IGNORE INTO users (id, username, email, password_hash, full_name, bio, avatar_url, institution, department, year_of_study, github_url, linkedin_url, reputation_score) VALUES
(1, 'sunesh', 'sunesh@skillloop.edu', 'pbkdf2$demo$8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Sunesh Kumar', 'CS Undergrad passionate about DBMS, Systems Engineering & Hackathons. Building scalable student tools.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'National Institute of Technology', 'Computer Science & Engineering', 3, 'https://github.com/sunesh', 'https://linkedin.com/in/sunesh', 4.90),
(2, 'priya_dev', 'priya@skillloop.edu', 'pbkdf2$demo$8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Priya Sharma', 'Full-stack UI/UX engineer and React specialist. Love teaching modern web development.', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', 'Vellore Institute of Technology', 'Information Technology', 4, 'https://github.com/priyadev', 'https://linkedin.com/in/priyasharma', 4.85),
(3, 'aravind_ai', 'aravind@skillloop.edu', 'pbkdf2$demo$8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Aravind Raman', 'ML researcher and Python developer. Focusing on computer vision and medical AI.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'IIT Madras', 'Data Science & AI', 3, 'https://github.com/aravindai', 'https://linkedin.com/in/aravindraman', 4.75),
(4, 'ananya_iot', 'ananya@skillloop.edu', 'pbkdf2$demo$8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Ananya Iyer', 'Hardware enthusiast working on ESP32 robotics and smart campus sensor networks.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150', 'Anna University', 'Electronics & Communication', 4, 'https://github.com/ananyaiot', 'https://linkedin.com/in/ananyaiyer', 4.80),
(5, 'karthik_backend', 'karthik@skillloop.edu', 'pbkdf2$demo$8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Karthik Raja', 'Backend engineer specialized in SQL optimization, database design and API performance.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'PSG College of Technology', 'Computer Science', 3, 'https://github.com/karthikraja', 'https://linkedin.com/in/karthikraja', 4.95);

-- User Roles
INSERT OR IGNORE INTO user_roles (user_id, role_id) VALUES
(1, 1), (1, 2), (1, 4), -- Sunesh: Student, Leader, Admin
(2, 1), (2, 2),          -- Priya: Student, Leader
(3, 1),                 -- Aravind: Student
(4, 1), (4, 3),          -- Ananya: Student, Moderator
(5, 1), (5, 2);         -- Karthik: Student, Leader

-- User Skills
INSERT OR IGNORE INTO user_skills (user_id, skill_id, proficiency, years_experience, verification_status) VALUES
(1, 1, 'ADVANCED', 3.0, 'CHALLENGE_VERIFIED'),  -- Sunesh: C++
(1, 8, 'ADVANCED', 2.5, 'PEER_VERIFIED'),       -- Sunesh: SQL & RDBMS
(1, 11, 'INTERMEDIATE', 1.5, 'PEER_VERIFIED'),   -- Sunesh: ESP32
(2, 4, 'EXPERT', 4.0, 'PEER_VERIFIED'),         -- Priya: HTML/CSS
(2, 5, 'EXPERT', 3.5, 'PEER_VERIFIED'),         -- Priya: JavaScript
(2, 6, 'ADVANCED', 3.0, 'CHALLENGE_VERIFIED'),  -- Priya: React
(3, 3, 'EXPERT', 4.0, 'PEER_VERIFIED'),         -- Aravind: Python
(3, 10, 'ADVANCED', 2.5, 'CHALLENGE_VERIFIED'), -- Aravind: ML Basics
(4, 1, 'INTERMEDIATE', 2.0, 'PEER_VERIFIED'),   -- Ananya: C++
(4, 11, 'ADVANCED', 3.0, 'PEER_VERIFIED'),      -- Ananya: ESP32
(5, 8, 'EXPERT', 3.5, 'CHALLENGE_VERIFIED'),    -- Karthik: SQL
(5, 9, 'ADVANCED', 3.0, 'PEER_VERIFIED'),       -- Karthik: PostgreSQL/MySQL
(5, 7, 'ADVANCED', 2.5, 'PEER_VERIFIED');       -- Karthik: Backend API

-- User Availability
INSERT OR IGNORE INTO user_availability (id, user_id, day_of_week, start_time, end_time) VALUES
(1, 1, 6, '10:00', '13:00'), -- Sunesh: Saturday morning
(2, 1, 0, '15:00', '18:00'), -- Sunesh: Sunday afternoon
(3, 2, 6, '10:00', '14:00'), -- Priya: Saturday morning
(4, 2, 2, '18:00', '20:00'), -- Priya: Tuesday evening
(5, 3, 0, '14:00', '17:00'), -- Aravind: Sunday afternoon
(6, 4, 5, '17:00', '20:00'), -- Ananya: Friday evening
(7, 5, 6, '11:00', '15:00'); -- Karthik: Saturday afternoon

-- Learning Goals
INSERT OR IGNORE INTO learning_goals (id, user_id, skill_id, title, target_date, progress_percent, status) VALUES
(1, 1, 6, 'Master React & SPA Architecture', '2026-11-30', 65, 'ACTIVE'),
(2, 1, 10, 'Learn Foundations of ML for Medical Hackathon', '2026-12-15', 30, 'ACTIVE'),
(3, 2, 8, 'Learn Advanced SQL Indexing & Query Tuning', '2026-11-15', 75, 'ACTIVE'),
(4, 3, 7, 'Build High-Throughput REST APIs with FastAPI', '2026-12-01', 50, 'ACTIVE'),
(5, 4, 1, 'Refactor Embedded Firmware to Clean Modern C++', '2026-11-20', 80, 'ACTIVE');

-- Teaching Offers
INSERT OR IGNORE INTO teaching_offers (id, user_id, skill_id, min_learner_level, max_learner_level, session_format, session_duration_minutes, credit_cost, language, description) VALUES
(1, 1, 8, 'BEGINNER', 'ADVANCED', 'ONLINE', 60, 1.0, 'English, Tamil', 'Hands-on Relational Modeling, 3NF Normalization, and ACID Transaction deep dives.'),
(2, 1, 1, 'BEGINNER', 'INTERMEDIATE', 'ONLINE', 60, 1.0, 'English', 'C++ pointers, memory management, OOP and algorithmic problem solving.'),
(3, 2, 6, 'BEGINNER', 'ADVANCED', 'ONLINE', 60, 1.0, 'English, Hindi', 'Modern React 19, hooks, component state, custom styling and performance tips.'),
(4, 3, 10, 'BEGINNER', 'INTERMEDIATE', 'ONLINE', 60, 1.0, 'English', 'Machine Learning algorithms from scratch with Python and scikit-learn.'),
(5, 4, 11, 'BEGINNER', 'ADVANCED', 'HYBRID', 60, 1.0, 'English, Tamil', 'ESP32 sensor interfacing, FreeRTOS multi-threading and IoT data telemetry.'),
(6, 5, 8, 'INTERMEDIATE', 'EXPERT', 'ONLINE', 60, 1.5, 'English', 'PostgreSQL query optimization, execution plans, locking, and trigger design.');

-- Resources & Tutorials
INSERT OR IGNORE INTO resources (id, uploader_id, skill_id, title, description, resource_type, content_url, author_name, difficulty, view_count, completion_count, rating_avg, rating_count) VALUES
(1, 1, 8, 'Complete DBMS Relational Normalization Guide (1NF to BCNF)', 'A comprehensive handbook with practical student examples illustrating functional dependencies, candidate keys, and lossless decomposition.', 'NOTE', 'https://skillloop.edu/resources/dbms-normalization-guide.pdf', 'Sunesh Kumar', 'INTERMEDIATE', 480, 134, 4.92, 42),
(2, 2, 6, 'Modern React 19 Architecture & State Patterns', 'Curated YouTube playlist covering custom hooks, server components, and responsive design systems without UI framework bloat.', 'YOUTUBE_PLAYLIST', 'https://youtube.com/playlist?list=PL_react_mastery_skillloop', 'Priya Sharma', 'BEGINNER', 620, 185, 4.88, 55),
(3, 3, 10, 'Medical Image Classification with CNNs: End-to-End Notebook', 'Jupyter notebook and slides on preprocessing X-ray images, training convolutional neural nets, and evaluating ROC-AUC.', 'CODE_REPOSITORY', 'https://github.com/skillloop-open/medical-cv-baseline', 'Aravind Raman', 'ADVANCED', 310, 78, 4.79, 29),
(4, 4, 11, 'ESP32 FreeRTOS Multitasking & Sensor Telemetry Cheat Sheet', 'Essential register configurations, task priority guidelines, and queue synchronization patterns for ESP32 microcontrollers.', 'CHEAT_SHEET', 'https://skillloop.edu/resources/esp32-freertos-cheatsheet.pdf', 'Ananya Iyer', 'INTERMEDIATE', 275, 92, 4.85, 34),
(5, 5, 8, 'SQL Query Plan Execution & Index Optimization Handbook', 'In-depth guide on understanding B-tree vs Hash indexes, avoiding table scans, and writing high-efficiency joins.', 'NOTE', 'https://skillloop.edu/resources/sql-indexing-masterclass.pdf', 'Karthik Raja', 'ADVANCED', 540, 160, 4.95, 61);

-- Resource Ratings
INSERT OR IGNORE INTO resource_ratings (resource_id, user_id, rating, review_text) VALUES
(1, 2, 5, 'The best explanation of BCNF lossless decomposition I have seen. Clear diagrams!'),
(1, 3, 5, 'Essential reading before database lab exams. Very well structured.'),
(2, 1, 5, 'Helped me finally understand React hook lifecycles and state boundaries.'),
(3, 1, 4, 'Very detailed code with clear ROC-AUC metrics. Great baseline for medical hackathons.'),
(5, 1, 5, 'The execution plan breakdowns are top tier.');

-- Learning Sessions
INSERT OR IGNORE INTO learning_sessions (id, teacher_id, learner_id, skill_id, scheduled_start, scheduled_end, duration_minutes, status, meeting_url, notes, credit_settled) VALUES
(1, 1, 2, 8, '2026-10-01 10:00:00', '2026-10-01 11:00:00', 60, 'COMPLETED', 'https://meet.skillloop.edu/dbms-session-101', 'Walked through 3NF schema design and foreign key cascading rules.', 1),
(2, 2, 1, 6, '2026-10-03 11:00:00', '2026-10-03 12:00:00', 60, 'COMPLETED', 'https://meet.skillloop.edu/react-hooks-201', 'Interactive session on building reusable custom hooks and API state caching.', 1),
(3, 1, 4, 1, '2026-10-10 10:00:00', '2026-10-10 11:00:00', 60, 'SCHEDULED', 'https://meet.skillloop.edu/cpp-firmware-301', 'Upcoming session: Refactoring embedded C struct code to modern C++ classes.', 0);

-- Session Reviews
INSERT OR IGNORE INTO session_reviews (session_id, reviewer_id, reviewee_id, rating, teaching_clarity, punctuality, comments) VALUES
(1, 2, 1, 5, 5, 5, 'Sunesh explained composite keys and 3NF normalization exceptionally well. Highly recommended!'),
(2, 1, 2, 5, 5, 5, 'Priya is an amazing teacher. She simplified complex React state lifting concepts effortlessly.');

-- Credit Accounts & Transactions
INSERT OR IGNORE INTO credit_accounts (user_id, balance, total_earned, total_spent) VALUES
(1, 5.00, 6.00, 1.00), -- Sunesh: Started 5.00, earned 1.00 teaching Priya, spent 1.00 learning React
(2, 5.00, 6.00, 1.00), -- Priya: Started 5.00, spent 1.00 learning SQL, earned 1.00 teaching React
(3, 5.00, 5.00, 0.00),
(4, 5.00, 5.00, 0.00),
(5, 6.50, 6.50, 0.00);

INSERT OR IGNORE INTO credit_transactions (id, account_id, amount, transaction_type, session_id, balance_after, idempotency_key, description) VALUES
(1, 1, 5.00, 'BONUS_ONBOARDING', NULL, 5.00, 'INIT_USER_1', 'Welcome onboarding Skill Credits'),
(2, 2, 5.00, 'BONUS_ONBOARDING', NULL, 5.00, 'INIT_USER_2', 'Welcome onboarding Skill Credits'),
(3, 1, 1.00, 'EARNED_TEACHING', 1, 6.00, 'SETTLE_SESSION_1_TEACHER', 'Earned 1.00 credit teaching Priya in Session #1 (DBMS)'),
(4, 2, -1.00, 'SPENT_LEARNING', 1, 4.00, 'SETTLE_SESSION_1_LEARNER', 'Spent 1.00 credit attending Session #1 (DBMS) with Sunesh'),
(5, 2, 1.00, 'EARNED_TEACHING', 2, 5.00, 'SETTLE_SESSION_2_TEACHER', 'Earned 1.00 credit teaching Sunesh in Session #2 (React)'),
(6, 1, -1.00, 'SPENT_LEARNING', 2, 5.00, 'SETTLE_SESSION_2_LEARNER', 'Spent 1.00 credit attending Session #2 (React) with Priya');

-- Competitions & Hackathons
INSERT OR IGNORE INTO competitions (id, title, organizer, competition_type, description, eligibility, registration_deadline, event_start, event_end, website_url, status) VALUES
(1, 'VMedithon 2026: National Healthcare Hackathon', 'National Medical Research & Tech Council', 'HACKATHON', 'Build AI, IoT, and database solutions to solve critical emergency triage and rural healthcare tracking challenges.', 'Open to all college undergraduate and graduate students', '2026-10-25 23:59:59', '2026-11-05 09:00:00', '2026-11-07 18:00:00', 'https://vmedithon2026.org', 'OPEN'),
(2, 'Smart Campus IoT & Green Energy Challenge', 'Green India Foundation', 'DESIGN_SPRINT', 'Deploy embedded sensor grids to monitor energy consumption, air quality, and automated building management.', 'Engineering students in ECE, EEE, CSE, IT', '2026-11-10 23:59:59', '2026-11-18 09:00:00', '2026-11-20 17:00:00', 'https://greencampus2026.edu', 'OPEN');

-- Competition Skills
INSERT OR IGNORE INTO competition_skills (competition_id, skill_id) VALUES
(1, 3), (1, 6), (1, 8), (1, 10), -- VMedithon: Python, React, SQL, ML
(2, 1), (2, 11), (2, 7);         -- Green Energy: C++, ESP32, Backend API

-- Teams
INSERT OR IGNORE INTO teams (id, competition_id, name, leader_id, description, max_members, current_member_count, status) VALUES
(1, 1, 'PulseTrack AI', 1, 'Building a real-time hospital triage and ICU bed prediction dashboard powered by ML and relational DBMS.', 4, 3, 'RECRUITING'),
(2, 2, 'EcoGrid Sensors', 4, 'Developing autonomous solar telemetry nodes with ESP32 and centralized telemetry dashboard.', 4, 2, 'RECRUITING');

-- Team Members
INSERT OR IGNORE INTO team_members (team_id, user_id, role_title) VALUES
(1, 1, 'Team Leader & Database Architect'),
(1, 2, 'Frontend & UX Specialist'),
(1, 3, 'ML & Computer Vision Engineer'),
(2, 4, 'Hardware & Firmware Lead'),
(2, 5, 'Backend & Cloud Pipeline Engineer');

-- Team Openings
INSERT OR IGNORE INTO team_openings (id, team_id, role_title, skill_id, min_proficiency, slots_available, slots_filled, status) VALUES
(1, 1, 'Data Pipeline & API Integration Engineer', 7, 'INTERMEDIATE', 1, 0, 'OPEN'),
(2, 2, 'Embedded C++ / Firmware Contributor', 1, 'INTERMEDIATE', 1, 0, 'OPEN'),
(3, 2, 'Dashboard Web Developer', 6, 'BEGINNER', 1, 0, 'OPEN');

-- Team Applications
INSERT OR IGNORE INTO team_applications (id, opening_id, team_id, applicant_id, pitch_message, status) VALUES
(1, 1, 1, 5, 'Hey Sunesh! I have extensive experience building FastAPI backends with PostgreSQL transaction pipelines. Would love to join PulseTrack AI!', 'UNDER_REVIEW');

-- Opportunities
INSERT OR IGNORE INTO opportunities (id, creator_id, title, opportunity_type, description, required_skill_id, slots_total, slots_filled, deadline, status) VALUES
(1, 1, 'Looking for Study Partner in Distributed Database Systems', 'STUDY_PARTNER', 'Preparing for advanced relational database exams. Looking for a partner to discuss Two-Phase Locking, WAL logs, and Raft consensus.', 8, 2, 1, '2026-11-01', 'OPEN'),
(2, 3, 'Seeking React Contributor for Open Source Medical Annotation Tool', 'PROJECT_COLLABORATION', 'Building a canvas-based medical image bounding box tool. Need someone comfortable with React and canvas rendering.', 6, 2, 0, '2026-11-15', 'OPEN');

-- Projects
INSERT OR IGNORE INTO projects (id, owner_id, title, tagline, problem_statement, solution_description, github_url, demo_url, competition_id, status) VALUES
(1, 1, 'PulseTrack AI: Smart Hospital Emergency Triage', 'AI-assisted patient priority scoring & real-time bed allocation', 'Hospital ERs face severe bottlenecks during surge admissions, causing critical delays in patient stabilization.', 'A relational DBMS core that manages real-time patient admissions, integrates ML risk scoring, and automates bed assignment.', 'https://github.com/sunesh/pulsetrack-ai', 'https://pulsetrack-demo.skillloop.edu', 1, 'ACTIVE'),
(2, 4, 'EcoSense: Campus Micro-Weather & AQI Station', 'ESP32 solar powered sensor array streaming air quality metrics', 'Campus pollution hotspots go undetected due to lack of localized real-time environmental sensors.', 'Solar powered wireless ESP32 nodes sampling PM2.5, humidity, and temperature streaming into a central database.', 'https://github.com/ananyaiot/ecosense-station', 'https://ecosense.skillloop.edu', 2, 'ACTIVE');

-- Project Members
INSERT OR IGNORE INTO project_members (project_id, user_id, role_title) VALUES
(1, 1, 'Architect & DB Lead'),
(1, 2, 'Frontend Lead'),
(1, 3, 'AI/ML Specialist'),
(2, 4, 'Hardware Lead'),
(2, 5, 'Data Storage Lead');

-- Project Skills
INSERT OR IGNORE INTO project_skills (project_id, skill_id) VALUES
(1, 8), (1, 6), (1, 3), (1, 10),
(2, 11), (2, 1), (2, 7);

-- Project Kanban Tasks
INSERT OR IGNORE INTO project_tasks (id, project_id, title, description, assignee_id, status, priority, due_date) VALUES
(1, 1, 'Design 3NF Relational Triage Schema', 'Draft ER diagram and DDL tables for patient check-in, triage priority, and bed allocation.', 1, 'DONE', 'HIGH', '2026-10-12'),
(2, 1, 'Implement Patient Vitals Form in React', 'Build responsive patient admission component with validation and optimistic updates.', 2, 'IN_PROGRESS', 'MEDIUM', '2026-10-18'),
(3, 1, 'Train Logistic Regression Triage Predictor', 'Train baseline triage severity model on synthetic ER dataset and export ONNX weights.', 3, 'IN_PROGRESS', 'HIGH', '2026-10-20'),
(4, 1, 'Setup Foreign Key Constraints & Indexes', 'Add compound indexes on (patient_id, admission_time) and verify query execution plans.', 1, 'TODO', 'HIGH', '2026-10-22'),
(5, 2, 'Fabricate PCB & Sensor Power Circuit', 'Test solar regulator charging circuit with 18650 Li-ion battery.', 4, 'DONE', 'HIGH', '2026-10-10'),
(6, 2, 'Write ESP32 WiFi Reconnect State Machine', 'Handle WiFi disconnection gracefully and buffer sensor readings in flash memory.', 4, 'IN_PROGRESS', 'MEDIUM', '2026-10-16');

-- Social Feed Posts
INSERT OR IGNORE INTO posts (id, author_id, title, content, post_type, related_skill_id, view_count, comment_count, reaction_count) VALUES
(1, 1, 'Why Database Normalization (3NF) matters for Hackathons', 'When building fast during a 36-hour hackathon, people often store arrays as comma-separated strings. Here is why adopting strict 3NF with foreign keys saved our team hours of debugging when joining data!', 'DISCUSSION', 8, 240, 3, 18),
(2, 2, 'Top 5 mistakes beginners make with React useEffect', 'A quick breakdown of dependency array pitfalls, stale closures, and race conditions when fetching data in React components. Check out the example repo linked in the knowledge hub!', 'RESOURCE_SHARE', 6, 310, 4, 25),
(3, 3, 'Question: Best way to handle class imbalance in medical dataset?', 'We have only 3% positive emergency cases in our triage training set. Should we prioritize focal loss, SMOTE oversampling, or threshold tuning for medical safety?', 'QUESTION', 10, 195, 2, 12);

-- Post Comments
INSERT OR IGNORE INTO post_comments (id, post_id, author_id, content) VALUES
(1, 1, 5, 'Completely agree Sunesh! Also compound indexes on foreign keys make multi-table joins lightning fast.'),
(2, 1, 2, 'Great post! Clear relational modeling makes building frontend tables so much cleaner.'),
(3, 3, 1, 'In medical triage, false negatives are extremely costly. You should evaluate Precision-Recall curves and set a low decision threshold to maximize sensitivity.');

-- Post Reactions
INSERT OR IGNORE INTO post_reactions (post_id, user_id, reaction_type) VALUES
(1, 2, 'INSIGHTFUL'),
(1, 3, 'LIKE'),
(1, 5, 'CELEBRATE'),
(2, 1, 'HELPFUL'),
(2, 4, 'LIKE'),
(3, 1, 'INSIGHTFUL');

-- Notifications
INSERT OR IGNORE INTO notifications (id, user_id, type, title, message, entity_type, entity_id, is_read) VALUES
(1, 1, 'TEAM_APPLICATION', 'New Team Application', 'Karthik Raja applied for opening "Data Pipeline & API Integration Engineer" in PulseTrack AI.', 'TEAM_APPLICATION', 1, 0),
(2, 1, 'SESSION_REMINDER', 'Upcoming Learning Session', 'You have a scheduled C++ session with Ananya Iyer on Oct 10 at 10:00 AM.', 'LEARNING_SESSION', 3, 0),
(3, 2, 'CREDIT_EARNED', 'Skill Credits Credited', 'You received +1.00 Skill Credit for completing React Session #2 with Sunesh.', 'CREDIT_TRANSACTION', 5, 1);
