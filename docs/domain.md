# SkillLoop Domain Model & State Machines

## 1. Domain Entities & Glossary

### 1.1 Identity & User Profile
- **User**: Core registered student, member, mentor, or administrator with authentication credentials, profile bio, university/college, department, year, reputation score, and skill credits.
- **Role**: System-level role defining permissions (`STUDENT`, `TEAM_LEADER`, `MODERATOR`, `ADMIN`).
- **UserSkill**: Association entity mapping a user to a skill with declared proficiency level (`BEGINNER`, `ELEMENTARY`, `INTERMEDIATE`, `ADVANCED`, `EXPERT`), evidence notes/links, and verification status (`UNVERIFIED`, `PEER_VERIFIED`, `CHALLENGE_VERIFIED`).
- **UserAvailability**: Defined recurring or specific time windows for teaching and learning sessions.
- **LearningGoal**: Target skill or roadmap milestone a user commits to achieving with target completion date.

### 1.2 Skill Taxonomy & Graph
- **SkillCategory**: High-level domain (e.g., Programming, Web Development, Databases, Embedded Systems, Machine Learning).
- **Skill**: Master taxonomy entry with standard slug, category, and description.
- **SkillRelationship**: Directed relationship graph between skills (`PREREQUISITE_OF`, `RELATED_TO`, `SPECIALIZATION_OF`, `COMMONLY_USED_WITH`).

### 1.3 Knowledge Hub & Resources
- **Resource**: Learning artifact metadata (Notes, PDFs, Cheat Sheets, YouTube video/playlist references, GitHub repositories, documentation links).
- **ResourceRating**: 1–5 star rating submitted by a user with optional review comment.
- **ResourceCompletion**: Record indicating a user worked through and finished a resource.
- **ResourceBookmark**: Saved resource reference for quick retrieval.

### 1.4 Social Feed & Discussions
- **Post**: Feed post (`GENERAL`, `QUESTION`, `RESOURCE_SHARE`, `PROJECT_UPDATE`, `ACHIEVEMENT`, `OPPORTUNITY`, `DISCUSSION`).
- **PostComment**: Comment on a post with optional parent comment ID for threaded replies.
- **PostReaction**: One reaction per user per post (`LIKE`, `INSIGHTFUL`, `CELEBRATE`, `HELPFUL`).
- **QuestionAnswer**: Accepted solution or answer for question-type posts.

### 1.5 Skill Exchange Engine
- **TeachingOffer**: User's published willingness to teach a specific skill with format, language, and session duration.
- **LearningRequest**: Open request from a learner seeking mentorship in a specific topic.
- **LearningSession**: Scheduled 1-on-1 or small-group learning interaction with start/end time, meeting coordinates, credit settlement flag, and state machine.
- **SessionReview**: Structured review (1-5 rating, comments) submitted after session completion.
- **CreditAccount**: Double-entry accounting wallet holding user Skill Credits balance.
- **CreditTransaction**: Immutable audit ledger recording every credit debit/credit event (session payment, reward, refund) with idempotency key.

### 1.6 Opportunities & Competitions
- **Competition**: Hackathon, coding contest, or design challenge with registration deadlines, event dates, rules, and skill tags.
- **Team**: A team formed for a competition or general project with member limits.
- **TeamOpening**: A role vacancy within a team requiring specific skills and minimum proficiency.
- **TeamApplication**: Application submitted by a user to join a team opening.
- **Opportunity**: Open notice for research collaboration, study buddy, project partner, or event speaker.

### 1.7 Projects & Challenges
- **Project**: Student software or hardware build showcase with repository, live demo, problem statement, milestones, and task board.
- **ProjectMember**: Team member with defined project role.
- **ProjectTask**: Kanban/scrum task (`TODO`, `IN_PROGRESS`, `BLOCKED`, `DONE`) assigned to a member.
- **Challenge**: Coding or technical problem with submission guidelines, test evaluation, and XP reward.
- **ChallengeSubmission**: User submission evaluated for XP reward.

### 1.8 Platform Trust, Notifications & Audit
- **Notification**: Real-time / inbox notification with type, title, message, reference entity, and read flag.
- **Report**: User grievance or content violation report (`OPEN`, `UNDER_REVIEW`, `RESOLVED`, `DISMISSED`).
- **AuditLog**: Immutable system audit trail for security and administrative actions.

---

## 2. State Machines

### 2.1 Learning Session State Machine
```text
                  +--------------------------------+
                  |           REQUESTED            |
                  +---------------+----------------+
                                  |
                   +--------------+--------------+
                   |                             |
             [Teacher Accepts]            [Teacher Declines]
                   |                             |
                   v                             v
           +---------------+             +---------------+
           |   ACCEPTED    |             |   DECLINED    |
           +-------+-------+             +---------------+
                   |
           [Schedule Time]
                   |
                   v
           +---------------+
           |   SCHEDULED   |
           +---+-------+---+
               |       |
      [Cancel] |       | [Time Arrives & Finished]
               v       v
 +-----------+   +---------------+
 | CANCELLED |   |   COMPLETED   |
 +-----------+   +-------+-------+
                         |
                 [Settle Credits & Review]
                         |
                         v
                 +---------------+
                 |   REVIEWED    |
                 +---------------+
```

### 2.2 Team Application State Machine
```text
           +---------------+
           |   SUBMITTED   |
           +-------+-------+
                   |
          [Leader Views Profile]
                   |
                   v
           +---------------+
           | UNDER_REVIEW  |
           +-------+-------+
                   |
        +----------+----------+----------------+
        |                     |                |
  [Leader Accepts]     [Leader Rejects]   [User Withdraws]
  (Guarded Slot Lock)         |                |
        |                     v                v
        v              +---------------+ +-------------+
 +---------------+     |   REJECTED    | |  WITHDRAWN  |
 |   ACCEPTED    |     +---------------+ +-------------+
 +---------------+
```

### 2.3 Opportunity & Project Lifecycle
```text
Opportunity: DRAFT  ->  OPEN  ->  FILLED / CLOSED  ->  ARCHIVED
Project:     PLANNING  ->  ACTIVE  ->  COMPLETED  ->  ARCHIVED
Report:      OPEN  ->  UNDER_REVIEW  ->  RESOLVED / DISMISSED
```
