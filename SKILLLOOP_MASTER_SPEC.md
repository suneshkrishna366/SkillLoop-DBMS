# SkillLoop — Master Product & Engineering Specification

> **Status:** Master specification / source of truth  
> **Audience:** Antigravity + developers + project collaborators  
> **Project type:** Full-stack web application with a serious relational DBMS core  
> **Primary goal:** Build a real student knowledge, skill, collaboration, and opportunity platform — not a toy CRUD app and not generic “vibe-coded slop”.

---

## 0. NON-NEGOTIABLE PROJECT PRINCIPLES

This project must be built deliberately.

### 0.1 No vibe-coded slop

Do **not**:

- generate a large pile of UI components without understanding the domain;
- create fake dashboard numbers just to make the UI look impressive;
- create pages that do not connect to real data;
- duplicate business logic across frontend and backend;
- hardcode data that should come from the database;
- create meaningless CRUD tables solely to increase table count;
- introduce AI features just because “AI” sounds impressive;
- hide weak database design behind ORM magic;
- use a single giant component or route with everything mixed together;
- ignore validation, authorization, transactions, constraints, indexes, or failure cases;
- use arbitrary colors, giant gradients, excessive glassmorphism, random animations, or template-like visuals as a substitute for product design;
- claim something is implemented when it is only mocked;
- replace important relational logic with application-side hacks when the database should own the integrity rule;
- create unnecessary microservices for a student project;
- add dependencies without a reason;
- use generated sample data in production paths unless explicitly marked as seed/demo data.

### 0.2 Build the product before the spectacle

Every screen must answer:

1. Who is this for?
2. What user problem does it solve?
3. What data powers it?
4. What action can the user take?
5. What happens after that action?
6. What database records change?
7. What edge cases can occur?

### 0.3 DBMS is the backbone

The relational database is not a storage dump. It must model the actual business domain.

The system should meaningfully demonstrate:

- entity relationships;
- normalization;
- primary and foreign keys;
- composite keys where appropriate;
- unique constraints;
- check constraints;
- not-null constraints;
- referential integrity;
- indexes;
- transactions;
- views;
- stored procedures/functions where they provide value;
- triggers where they provide value;
- audit/history tables where needed;
- aggregation and analytics queries;
- concurrency-aware operations;
- robust error handling.

### 0.4 Prefer clarity over unnecessary complexity

The project should be ambitious in product capability but disciplined in architecture.

Use a modular monolith first.

Do not prematurely introduce:

- microservices;
- event buses;
- distributed caches;
- Kubernetes;
- complex ML infrastructure;
- multiple databases;
- serverless functions everywhere.

Add infrastructure only when there is a concrete requirement.

---

# 1. PRODUCT VISION

## 1.1 Product name

**SkillLoop**

## 1.2 One-line description

A student-centered platform where people can **learn, teach, share knowledge, find collaborators, form teams, discover competitions, work on projects, and build a verified reputation**.

## 1.3 Core idea

SkillLoop is not merely:

> “a website where students exchange skills.”

It is a connected ecosystem around student growth.

Users can:

- teach what they know;
- learn what they need;
- share notes and useful resources;
- share YouTube tutorials and playlists;
- discuss topics in communities;
- message other users;
- find study partners;
- form hackathon/competition teams;
- recruit project collaborators;
- publish projects;
- participate in challenges;
- build a reputation from actual activity;
- discover opportunities matched to their interests and skills.

## 1.4 Product loop

```text
LEARN
  ↓
PRACTICE
  ↓
SHARE
  ↓
CONNECT
  ↓
COLLABORATE
  ↓
BUILD
  ↓
ACHIEVE
  ↓
EARN REPUTATION
  ↓
HELP OTHERS LEARN
  ↺
```

## 1.5 Product philosophy

The platform should make the user's profile a record of **real participation**, not an inflated list of self-declared claims.

Examples:

- A skill can be self-declared, practiced, challenged, or peer-verified.
- A tutorial can have completion and review data.
- A project can have actual members, tasks, milestones, and outcomes.
- A competition can have deadlines, teams, applications, and results.
- Reputation can be based on completed interactions rather than vanity metrics.

---

# 2. PRIMARY USERS AND ROLES

## 2.1 Student / Member

The default role.

Capabilities:

- create profile;
- add skills;
- define learning goals;
- define teaching offerings;
- search people/content/opportunities;
- bookmark resources;
- upload notes/resources;
- share tutorial links;
- post discussions;
- comment and react;
- direct message other users;
- join community groups;
- create or join teams;
- apply to team openings;
- create projects;
- join projects;
- participate in challenges;
- schedule learning sessions;
- exchange skill credits;
- review sessions/resources/collaborations;
- track learning progress;
- receive notifications;
- report problematic content/users.

## 2.2 Team Leader / Project Owner

A normal member with additional ownership capabilities inside a team or project.

Capabilities:

- create a team;
- define team roles;
- publish openings;
- review applications;
- accept/reject applicants;
- manage members;
- create tasks and milestones;
- manage project documentation;
- submit project outcomes;
- archive or close the team.

## 2.3 Moderator

Capabilities:

- review reports;
- hide/remove violating content;
- restrict users temporarily;
- review suspicious activity;
- manage reported resources/posts/comments;
- see moderation audit history.

## 2.4 Administrator

Capabilities:

- manage users and roles;
- manage taxonomy (skills, categories, tags);
- manage competitions/challenges;
- manage platform configuration;
- view system analytics;
- audit critical operations;
- manage moderation policies.

## 2.5 Optional future role: Organization

Do not implement in the first version unless needed.

Potential future use:

- clubs;
- college departments;
- companies;
- competition organizers;
- student communities.

---

# 3. PRODUCT MODULES

The product should be organized around these modules.

## Module A — Authentication & Identity

- registration;
- login;
- logout;
- password reset;
- email verification;
- session management;
- role management;
- profile management;
- privacy controls.

## Module B — Profile & Skills

- profile;
- skills;
- proficiency;
- skill evidence;
- teaching offerings;
- learning goals;
- availability;
- reputation.

## Module C — Social Feed

- posts;
- comments;
- reactions;
- tags;
- saves/bookmarks;
- feed filtering;
- reporting.

## Module D — Knowledge Hub

Content types:

- notes;
- PDFs;
- slide decks;
- cheat sheets;
- code repositories;
- documentation links;
- blog links;
- YouTube videos;
- YouTube playlists;
- online course links;
- useful tools/websites.

The platform stores metadata and links/references. It does not copy copyrighted third-party videos onto its own storage.

## Module E — Messaging & Communities

- direct messages;
- group chats;
- project/team chats;
- community channels;
- unread message state;
- message timestamps;
- attachment/link references;
- notifications.

## Module F — Skill Exchange

- teaching requests;
- learning requests;
- mentor/peer matching;
- learning sessions;
- time slots;
- session status;
- session reviews;
- Skill Credits;
- credit ledger.

## Module G — Opportunities

Opportunity categories:

- hackathon team openings;
- project collaborators;
- study partners;
- mentors;
- research collaborators;
- event speakers;
- competition teams;
- internship/project opportunities (only where legally/operationally appropriate).

## Module H — Competitions & Hackathons

- competition discovery;
- categories;
- deadlines;
- team formation;
- member requirements;
- applications;
- bookmarks;
- participation tracking;
- results.

## Module I — Projects

- project creation;
- project team;
- required skills;
- tasks;
- milestones;
- project links;
- project updates;
- showcase page;
- achievements.

## Module J — Challenges

- coding/technical/creative challenges;
- submissions;
- scoring;
- XP;
- leaderboards;
- challenge history.

## Module K — Learning Paths

- goals;
- prerequisites;
- skill dependency graph;
- progress;
- recommended resources;
- recommended people;
- recommended projects/challenges.

## Module L — Notifications

Examples:

- new message;
- team application status;
- team member request;
- session reminder;
- resource comment;
- post interaction;
- competition deadline reminder;
- skill verification outcome;
- project invitation.

## Module M — Moderation & Trust

- reports;
- content review;
- moderation actions;
- audit logs;
- trust/reliability score;
- anti-abuse controls.

---

# 4. HOME / DASHBOARD EXPERIENCE

After login, the home page should provide a personalized but explainable view.

Suggested sections:

### Top navigation

```text
SkillLoop
Search
Explore
Learn
Opportunities
Projects
Messages
Notifications
Profile
```

### Dashboard cards

- Learning goal progress
- Skill Credits balance
- Reputation summary
- Upcoming session
- Applications awaiting action
- Saved competitions
- Recommended opportunities

### Main feed

Mixed, relevance-ranked content from:

- followed topics;
- communities;
- connections/interactions;
- bookmarked/interested categories;
- recent platform activity.

Do not fabricate engagement numbers.

### Discovery strip

Examples:

- “3 teams are looking for React developers.”
- “2 new DBMS resources were added today.”
- “You have a common availability slot with 4 potential mentors.”
- “This competition closes in 3 days.”

Every recommendation must have a reason when practical.

---

# 5. PROFILE SYSTEM

## 5.1 Profile contents

```text
Avatar
Name
Username
Bio
College / Institution (optional)
Department (optional)
Year (optional)
Location (coarse / optional)
Website
GitHub
LinkedIn
Other links
```

## 5.2 Skill section

Each user's skill entry contains:

- skill;
- proficiency level;
- months/years experience (optional);
- interest status;
- evidence;
- verification status;
- last updated time.

Suggested proficiency levels:

```text
Beginner
Elementary
Intermediate
Advanced
Expert
```

Do not imply that a skill level is objectively certified unless verification exists.

## 5.3 Teaching offerings

A user can advertise:

```text
Skill: C++
Level taught: Beginner → Intermediate
Session format: Online / In-person / Either
Typical duration: 30 / 60 / 90 min
Languages: English / Tamil / etc.
Description
```

## 5.4 Learning goals

Example:

```text
Goal: Become a Full Stack Developer
Priority: High
Target date: 2027-02-01
Current progress: 62%
```

## 5.5 Activity history

Show meaningful activity:

- resources uploaded;
- tutorials shared;
- projects;
- challenges;
- completed sessions;
- achievements;
- verified skills.

Avoid showing meaningless activity such as every page visit.

---

# 6. SKILL TAXONOMY AND SKILL GRAPH

Skills should have a central master table.

Examples:

```text
Programming
 ├── C
 ├── C++
 │    └── DSA
 ├── Java
 └── Python

Web Development
 ├── HTML
 ├── CSS
 ├── JavaScript
 │    └── React
 ├── Node.js
 └── Express

Databases
 ├── SQL
 ├── PostgreSQL
 ├── MySQL
 ├── MongoDB
 └── Database Design
```

## 6.1 Skill relationships

Possible relationship types:

- prerequisite_of;
- related_to;
- specialization_of;
- commonly_used_with.

The database should support a skill dependency graph.

## 6.2 Why this matters

When a user wants to learn React, SkillLoop can determine whether they already know related prerequisites and recommend a path.

This can be implemented with relational queries first. AI is not required.

---

# 7. KNOWLEDGE HUB / RESOURCE SYSTEM

## 7.1 Resource types

```text
NOTE
PDF
PPT
CHEAT_SHEET
CODE_REPOSITORY
ARTICLE
YOUTUBE_VIDEO
YOUTUBE_PLAYLIST
COURSE
TOOL
DOCUMENTATION
OTHER_LINK
```

## 7.2 Resource metadata

```text
Title
Description
Resource type
URL / file reference
Author / creator (when applicable)
Uploader
Skill
Category
Difficulty
Tags
Language
Created at
Updated at
Visibility
Status
```

## 7.3 YouTube/tutorial links

The platform should store **links**, not duplicate third-party video content.

Metadata can include:

- title;
- URL;
- channel/creator;
- video vs playlist;
- duration if available from trusted metadata (optional);
- skill/topic;
- level;
- tags;
- description.

Users can:

- open the tutorial externally;
- bookmark it;
- mark it as started/completed;
- rate it;
- comment;
- recommend it.

## 7.4 Resource interactions

Track meaningful interactions:

- view;
- save;
- download where appropriate;
- completion;
- rating;
- report.

Do not build fake counters.

## 7.5 Search

Search should support:

- title;
- description;
- tags;
- skill;
- resource type;
- difficulty;
- creator.

Use database indexing for search fields where appropriate.

---

# 8. SOCIAL FEED

## 8.1 Post types

```text
GENERAL
QUESTION
RESOURCE_SHARE
PROJECT_UPDATE
ACHIEVEMENT
OPPORTUNITY
DISCUSSION
LEARNING_UPDATE
```

## 8.2 Post capabilities

- create;
- edit own post;
- delete own post;
- react;
- comment;
- save;
- report;
- share internally.

## 8.3 Questions

A question post can optionally accept an answer.

```text
Question
 ├── Answer(s)
 ├── Accepted answer
 └── Votes/reactions
```

If implementing voting, enforce one vote/reaction per user per target where appropriate.

---

# 9. CHAT / MESSAGING

## 9.1 Conversation types

```text
DIRECT
GROUP
TEAM
PROJECT
COMMUNITY
```

## 9.2 Message model

Messages should store:

- conversation;
- sender;
- body;
- timestamp;
- edited flag;
- deleted flag;
- optional reply-to;
- optional attachment/link metadata.

## 9.3 Platform object references

Messages can optionally reference:

- resource;
- post;
- project;
- team;
- competition;
- opportunity;
- challenge.

Example:

```text
“Check this DBMS note”
→ [Resource reference]
```

This makes communication part of the same platform rather than a disconnected chat feature.

## 9.4 Safety

Implement:

- block user;
- report conversation/message;
- basic rate limits;
- access checks on conversation membership.

---

# 10. SKILL EXCHANGE ENGINE

This is a central differentiator.

## 10.1 Skill Credits

Use an internal non-monetary accounting unit called **Skill Credits**.

Example rules:

```text
30-minute teaching session → +0.5 credit
60-minute teaching session → +1 credit
90-minute teaching session → +1.5 credits
```

A learner may spend credits to attend sessions.

## 10.2 Critical rule: use a ledger

Never simply increment/decrement a `balance` column without history.

Use:

```text
CREDIT_ACCOUNT
CREDIT_TRANSACTION
```

Every transaction should have:

- unique ID;
- user/account;
- amount;
- type;
- source entity;
- timestamp;
- balance-after snapshot (optional but useful);
- reference/description;
- idempotency reference where needed.

## 10.3 Transaction safety

Credit transfer and session completion must be transactional.

Example:

```text
BEGIN

Validate session is completed
Validate credit conditions
Create credit transaction for teacher
Create debit transaction for learner if applicable
Update any derived balance safely
Mark session settlement as completed

COMMIT
```

If anything fails:

```text
ROLLBACK
```

No half-completed transactions.

## 10.4 Prevent abuse

Potential rules:

- no self-transfers;
- no duplicate settlement;
- cannot settle an already cancelled session;
- minimum session duration;
- rate-limit repeated actions;
- no rating before session completion;
- no multiple ratings for the same interaction.

---

# 11. LEARNING SESSIONS

## 11.1 Session lifecycle

```text
REQUESTED
   ↓
ACCEPTED
   ↓
SCHEDULED
   ↓
COMPLETED
   ↓
REVIEWED
```

Alternative states:

```text
DECLINED
CANCELLED
NO_SHOW
DISPUTED
```

## 11.2 Session data

Store:

- teacher;
- learner;
- skill;
- requested level;
- scheduled start/end;
- status;
- session notes;
- meeting link if applicable;
- credit settlement status;
- timestamps.

## 11.3 Availability

Users define recurring availability slots or explicit future slots.

Example:

```text
Monday 18:00–20:00
Wednesday 19:00–22:00
Saturday 10:00–13:00
```

The system can find overlaps.

Do not allow impossible session overlaps without intentional support for them.

---

# 12. MATCHING / RECOMMENDATION ENGINE

The first version should use **transparent deterministic logic**, not an unexplained AI score.

## 12.1 Potential inputs

- requested skill;
- proficiency;
- skill verification;
- availability overlap;
- teaching reputation;
- reliability;
- previous successful sessions;
- interests;
- learning goals;
- preferred format;
- language.

## 12.2 Example score

```text
Skill match             40%
Availability             20%
Teaching reputation      15%
Reliability              10%
Goal alignment           10%
Prior successful history  5%
```

Weights should be configuration, not scattered constants.

## 12.3 Explainability

Show:

> “Recommended because you both have Saturday availability, the tutor teaches your target level, and their reliability score is high.”

Do not show a mysterious “92.73% AI match” with no explanation.

---

# 13. OPPORTUNITY SYSTEM

This expands the platform beyond skill exchange.

## 13.1 Opportunity types

```text
HACKATHON_TEAM
PROJECT_COLLABORATION
STUDY_PARTNER
MENTOR_REQUEST
RESEARCH_PARTNER
EVENT_SPEAKER
COMPETITION_TEAM
OTHER
```

## 13.2 Opportunity fields

```text
Title
Description
Creator
Opportunity type
Required skills
Preferred skills
Member slots
Current member count
Application deadline
Start/end dates
Mode
Location if needed
Status
```

## 13.3 Example

```text
VMedithon Team — Looking for ML Member

Current team: 2/4

Required:
- Python
- ML

Nice to have:
- React
- Medical domain interest

Deadline: 2026-10-20

[Apply]
```

## 13.4 Matching

The system can recommend openings based on the user's skill profile and interests.

---

# 14. HACKATHON / COMPETITION SYSTEM

## 14.1 Competition entity

Store:

- name;
- organizer;
- type;
- description;
- eligibility;
- registration deadline;
- event start/end;
- website;
- skill tags;
- status.

## 14.2 Team entity

A team belongs to a competition or optionally exists as a general project team.

Store:

- name;
- owner;
- competition;
- description;
- max members;
- current status.

## 14.3 Team openings

Each opening can specify:

```text
Role: Frontend Developer
Required skill: React
Minimum proficiency: Intermediate
Openings: 1
```

## 14.4 Applications

Application lifecycle:

```text
SUBMITTED
 ↓
UNDER_REVIEW
 ↓
ACCEPTED / REJECTED / WITHDRAWN
```

Constraint:

A user should not be accepted into multiple teams for the same exclusive competition when the competition rules prohibit that.

Do not rely solely on the frontend to enforce this.

---

# 15. PROJECT SYSTEM

## 15.1 Project page

A project showcase should include:

- title;
- short description;
- problem statement;
- solution;
- technologies;
- team;
- screenshots/media where appropriate;
- GitHub link;
- live demo link;
- competition/achievement;
- status;
- updates.

## 15.2 Internal project management

Optional but valuable:

```text
Project
 ├── Members
 ├── Roles
 ├── Tasks
 ├── Milestones
 ├── Updates
 └── Links
```

Task statuses:

```text
TODO
IN_PROGRESS
BLOCKED
DONE
```

## 15.3 Contribution history

Where practical, record member contributions through platform actions:

- tasks completed;
- project updates;
- accepted pull-request link references (optional future integration);
- milestones completed.

Do not fabricate contribution percentages.

---

# 16. CHALLENGE SYSTEM

Challenges provide a structured way to prove skill.

## 16.1 Challenge fields

```text
Title
Description
Skill
Difficulty
Time limit
Submission type
Start/end
Creator
Status
```

## 16.2 Submission

```text
Challenge
 ↓
Submission
 ↓
Evaluation
 ↓
XP / Result
```

Possible submission types:

- code link;
- text answer;
- file;
- project link;
- quiz answer.

## 16.3 XP vs Skill Credits

These are intentionally different.

### XP
Represents participation/progress/reputation progression.

### Skill Credits
Represent internal exchange value for learning sessions.

Never merge them into one metric.

---

# 17. REPUTATION SYSTEM

Avoid making reputation a single meaningless star number.

Use multiple dimensions:

```text
Teaching
Learning / Participation
Collaboration
Resource Quality
Reliability
Community Conduct
```

Ratings must originate from actual interactions.

## 17.1 Example

```text
Teaching:       4.8
Collaboration:  4.7
Resources:      4.9
Reliability:    4.8
```

## 17.2 Reliability score

Can be derived from:

- attended sessions;
- cancellations;
- no-shows;
- completed commitments.

The exact formula should be explicit and documented.

---

# 18. LEARNING PATH SYSTEM

Users can choose goals.

Examples:

```text
Become a Backend Developer
Learn Data Structures
Prepare for DBMS
Build an IoT Project
Learn UI/UX
```

Each goal maps to a sequence/graph of skills.

Example:

```text
HTML
 ↓
CSS
 ↓
JavaScript
 ↓
React
 ↓
Node.js
 ↓
Express
 ↓
PostgreSQL
 ↓
Deployment
```

For every step show:

- current state;
- prerequisites;
- recommended tutorials;
- notes;
- challenges;
- people who can teach it;
- projects that use it.

---

# 19. SEARCH AND DISCOVERY

A single global search experience should support multiple result types.

Search for:

```text
people
skills
resources
posts
projects
teams
competitions
opportunities
challenges
```

Example query:

> `React`

Results:

```text
People
Resources
Teams looking for React
Projects
Challenges
Discussions
```

Search should not be a collection of unrelated page-specific search boxes.

---

# 20. RECOMMENDATION FEED

Potential sections:

### For You

Resources and people aligned with current learning goals.

### Teams You Could Join

Openings matching user skills.

### Learn Next

Prerequisite-aware recommendations.

### People to Connect With

Users with complementary teaching/learning interests and overlapping availability.

### Competitions You May Like

Competition category + skills + timing.

Recommendations should be traceable to stored data.

---

# 21. NOTIFICATION ENGINE

Notification categories:

```text
MESSAGE
TEAM_APPLICATION
TEAM_INVITATION
SESSION
RESOURCE
POST
PROJECT
COMPETITION
CHALLENGE
SYSTEM
```

Every notification should have:

- recipient;
- type;
- title;
- message;
- read/unread state;
- optional target entity;
- created timestamp.

Do not send duplicate notifications without intentional deduplication.

---

# 22. DATABASE DESIGN — HIGH-LEVEL ENTITY LIST

The exact schema should be finalized after ER modeling, but the domain is expected to include many of the following entities.

## Identity

- users
- roles
- user_roles
- sessions/auth tokens as needed
- user_privacy_settings

## Skills

- skills
- skill_categories
- skill_relationships
- user_skills
- skill_evidence
- skill_verifications
- learning_goals
- goal_skills
- user_availability

## Social

- posts
- post_tags
- tags
- comments
- reactions
- bookmarks
- follows/connections if included
- reports

## Resources

- resources
- resource_tags
- resource_ratings
- resource_completions
- resource_bookmarks
- resource_views

## Messaging

- conversations
- conversation_members
- messages
- message_reactions
- message_attachments / link references if needed
- blocked_users

## Skill exchange

- teaching_offers
- learning_requests
- learning_sessions
- session_participants if the model needs many participants
- session_reviews
- credit_accounts
- credit_transactions

## Opportunities

- opportunities
- opportunity_skills
- opportunity_applications

## Competitions

- competitions
- competition_skills
- teams
- team_members
- team_openings
- team_applications

## Projects

- projects
- project_members
- project_skills
- project_tasks
- project_milestones
- project_updates
- project_achievements

## Challenges

- challenges
- challenge_skills
- submissions
- evaluations
- xp_transactions

## Platform

- notifications
- moderation_cases
- moderation_actions
- audit_logs
- platform_settings

Not all of these must become separate tables automatically. Final design should be driven by normalization and business needs.

---

# 23. DATABASE DESIGN RULES

## 23.1 Normalization

Aim for at least **3NF** for the core transactional schema unless a documented reason justifies denormalization.

Avoid:

```text
user_skills = "C++, Java, Python"
```

Instead use a relationship table.

Avoid:

```text
team_member_1
team_member_2
team_member_3
```

Use rows in `team_members`.

## 23.2 Foreign keys

Use real foreign keys for relational integrity.

Do not trust frontend state for database integrity.

## 23.3 Status fields

Use constrained values/enums where appropriate.

Do not allow arbitrary free-text workflow states like:

```text
"done"
"Done"
"completed"
"complete"
```

in the same table.

## 23.4 Timestamps

Core tables should have appropriate creation/update timestamps.

Use UTC storage and convert for display when practical.

## 23.5 Soft deletion

Use soft deletion only when history/audit requirements justify it.

Do not automatically add `deleted_at` to every table without thinking through its semantics.

---

# 24. IMPORTANT DATABASE CONSTRAINTS

Examples to consider:

### Unique

- username unique;
- email unique;
- one reaction per user per post/type where applicable;
- one bookmark per user/resource;
- one application per user/team/opportunity where applicable;
- one review per completed session.

### Check constraints

- ratings within allowed range;
- credit amounts valid;
- end time after start time;
- team capacity positive;
- proficiency value valid.

### Referential integrity

Deleting a skill should not silently orphan user skill records.

Deleting a competition should not destroy historical results unless that is explicitly intended.

Use `CASCADE`, `RESTRICT`, or `SET NULL` deliberately.

---

# 25. TRANSACTIONS THAT MUST BE THOUGHT THROUGH

Important transactional workflows include:

## Team acceptance

```text
BEGIN
Lock/check team capacity
Check applicant status
Check competition eligibility
Accept member
Update application status
COMMIT
```

## Skill-credit settlement

```text
BEGIN
Verify session completion
Verify not already settled
Create ledger entries
Update settlement state
COMMIT
```

## Project membership

```text
BEGIN
Validate invitation/application
Validate project/team limits
Create membership
Update request status
COMMIT
```

## Competition team creation

```text
BEGIN
Validate competition window
Validate creator eligibility
Create team
Create creator membership
COMMIT
```

Failure anywhere should roll back the complete operation.

---

# 26. DATABASE VIEWS

Create views where they make the application clearer or demonstrate DBMS capability.

Potential views:

### v_user_skill_summary

Shows verified/declared skill levels.

### v_team_openings

Shows current open roles with remaining capacity.

### v_user_reputation

Aggregates reputation dimensions.

### v_resource_quality

Combines ratings/completions/bookmarks.

### v_competition_team_status

Shows team size and open positions.

### v_learning_progress

Shows goal/skill completion state.

Do not make views purely for show. Each view should have a real use.

---

# 27. STORED PROCEDURES / FUNCTIONS

Use them selectively.

Good candidates:

- settle completed session credits;
- compute user reliability;
- calculate resource rating summary;
- safely accept a team applicant;
- retrieve recommended mentors/teachers;
- update a derived reputation snapshot if necessary.

Do not move every business rule into stored procedures just to claim database complexity.

---

# 28. TRIGGERS

Use triggers only where database-level automation is useful.

Potential examples:

- audit changes to critical records;
- automatically create an audit entry;
- maintain a derived counter when justified;
- enforce history requirements.

Avoid trigger abuse.

A trigger should have a documented purpose.

---

# 29. INDEXING STRATEGY

Indexes should be based on actual query patterns.

Potential indexes:

- users(email);
- users(username);
- user_skills(skill_id, proficiency);
- resources(skill_id, resource_type);
- resources(created_at);
- posts(created_at);
- messages(conversation_id, created_at);
- opportunity_skills(skill_id);
- team_openings(skill_id, status);
- team_applications(team_id, status);
- notifications(user_id, is_read, created_at).

Before adding many indexes, consider write cost and actual usage.

Use `EXPLAIN`/query plans during optimization.

---

# 30. SECURITY REQUIREMENTS

Security is part of the architecture, not a final polish step.

## Authentication

- secure password hashing;
- protected sessions/tokens;
- password reset safeguards;
- email verification where used.

## Authorization

Enforce permissions server-side.

Examples:

- only conversation members can read messages;
- only team leaders can accept applicants;
- only project members can edit internal project data;
- only moderators/admins can perform moderation actions.

## Input validation

Validate:

- request body;
- query parameters;
- path IDs;
- URLs;
- file metadata;
- uploaded content types.

## File handling

For uploaded notes/resources:

- limit size;
- validate type;
- avoid path traversal;
- store safe file identifiers;
- never trust the original filename;
- prevent unauthorized access.

## Abuse protection

At minimum:

- rate limiting on login and sensitive routes;
- reporting;
- blocking;
- spam protection on high-volume actions.

---

# 31. API DESIGN

Use a consistent REST API (unless a different approach is deliberately chosen).

Example routes:

```text
POST   /api/auth/register
POST   /api/auth/login
GET    /api/users/:id
PATCH  /api/users/:id

GET    /api/skills
POST   /api/users/me/skills
DELETE /api/users/me/skills/:skillId

GET    /api/resources
POST   /api/resources
GET    /api/resources/:id
POST   /api/resources/:id/bookmark
POST   /api/resources/:id/rating

GET    /api/posts
POST   /api/posts
POST   /api/posts/:id/comments
POST   /api/posts/:id/reactions

GET    /api/conversations
POST   /api/conversations
GET    /api/conversations/:id/messages
POST   /api/conversations/:id/messages

GET    /api/opportunities
POST   /api/opportunities
POST   /api/opportunities/:id/apply

GET    /api/competitions
POST   /api/competitions
POST   /api/teams
POST   /api/teams/:id/applications
POST   /api/teams/:id/applications/:applicationId/accept

GET    /api/projects
POST   /api/projects
POST   /api/projects/:id/tasks

GET    /api/challenges
POST   /api/challenges/:id/submissions

GET    /api/notifications
POST   /api/notifications/:id/read
```

Routes are illustrative, not final.

---

# 32. ERROR HANDLING

Every important action must have intentional failure behavior.

Examples:

```text
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
422 Validation Error
429 Too Many Requests
500 Internal Server Error
```

Frontend should convert these into useful messages.

Do not show raw stack traces to users.

---

# 33. FRONTEND ARCHITECTURE

Use a componentized, feature-oriented structure.

Example:

```text
src/
  app/
  components/
  features/
    auth/
    profile/
    skills/
    resources/
    feed/
    messaging/
    exchange/
    opportunities/
    competitions/
    teams/
    projects/
    challenges/
    notifications/
  pages/
  hooks/
  lib/
  services/
  types/
```

Do not create one giant `App.jsx`.

Keep API logic separate from presentation.

Use a single source of truth for shared types where practical.

---

# 34. UI / UX DIRECTION

The UI should feel like a credible product used by students every day.

## Design goals

- clean;
- modern;
- information-rich without becoming cluttered;
- responsive;
- keyboard accessible;
- consistent spacing;
- clear hierarchy;
- purposeful animations only;
- strong empty states;
- useful loading states;
- useful error states.

## Avoid

- random gradients everywhere;
- excessive cards for every tiny piece of data;
- huge hero sections for an authenticated dashboard;
- meaningless charts;
- “AI” labels on basic filtering;
- fake activity feeds;
- excessive glassmorphism;
- animations that slow the experience.

## Visual identity

SkillLoop should have its own restrained visual language.

Possible direction:

- neutral base;
- one strong accent color;
- high readability;
- subtle status colors only where semantics matter;
- typography-driven hierarchy.

Final palette should be selected deliberately during design.

---

# 35. RESPONSIVE DESIGN

The application must work on:

- desktop;
- laptop;
- tablet;
- mobile.

Do not merely shrink the desktop UI.

Mobile should have intentional navigation and layout decisions.

---

# 36. ACCESSIBILITY

Minimum expectations:

- semantic HTML;
- accessible labels;
- keyboard navigation;
- visible focus states;
- appropriate color contrast;
- alt text for meaningful images;
- error messages associated with inputs;
- dialogs/modals that can be dismissed and navigated accessibly.

---

# 37. REAL-TIME FEATURES

Real-time features are optional and should be introduced after the core system works.

Potential real-time features:

- chat messages;
- typing indicator;
- online status;
- notification updates.

Use WebSockets or another appropriate mechanism only where necessary.

Core functionality must remain correct even without real-time transport.

---

# 38. FILE AND RESOURCE STORAGE

The database should store metadata, not large binary blobs by default.

Potential architecture:

```text
Frontend
  ↓
Backend
  ↓
Object/File Storage
  ↓
Database stores metadata + reference
```

For a local/dev version, a controlled local storage provider is acceptable.

Do not put arbitrary file bytes into the relational database unless there is a deliberate reason.

---

# 39. ANALYTICS / ADMIN DASHBOARD

Admin analytics should be based on real database queries.

Potential metrics:

- active users;
- new registrations;
- resources added;
- tutorials shared;
- completed sessions;
- Skill Credits exchanged;
- open team positions;
- applications;
- projects;
- challenge participation;
- reported content;
- competition participation.

Avoid vanity dashboards with made-up values.

---

# 40. USEFUL DBMS QUERIES TO DEMONSTRATE

The final project should include a documented collection of serious SQL queries.

Examples:

### Find students who can teach a skill

Filter by skill, minimum proficiency, verification, and availability.

### Find users with complementary goals

Users who teach what another user wants to learn.

### Find best team candidates

Users matching all required skills for an open team role.

### Find resources with highest useful engagement

Combine rating, completion, saves, and recent activity.

### Find users who completed a tutorial and later joined a related project

Requires multiple relationships.

### Find competitions closing within N days

Date functions.

### Find users whose availability overlaps

Time/date logic.

### Find teams with remaining openings

Aggregations.

### Find users who have contributed but never created a profile skill verification

Anti-gap query.

### Find abandoned opportunities

Opportunities with no applications after a time threshold.

### Find resources for a learning goal

Join goals → goal skills → resources.

### Find mutual teaching/learning compatibility

User A wants X and teaches Y; User B wants Y and teaches X.

---

# 41. DATE/TIME REQUIREMENTS

Dates matter throughout the product.

Use proper database types.

Examples:

- competition deadlines;
- session start/end;
- opportunity application deadlines;
- resource creation time;
- message timestamps;
- notification timestamps;
- project milestones.

Support queries such as:

```text
current_date - deadline
session_duration
competition_days_remaining
monthly_activity
weekly_learning_hours
```

Be careful with time zones.

Store timestamps consistently and convert for display.

---

# 42. AUDITING

Critical actions should be auditable.

Potential audit events:

- role changes;
- account restrictions;
- moderation actions;
- competition changes;
- team member acceptance/rejection;
- credit adjustments;
- privileged administration actions.

Example:

```text
AuditLog
user_id
actor_id
action
target_type
target_id
metadata
created_at
```

Never put secrets in audit metadata.

---

# 43. MODERATION / REPORTING

Users should be able to report:

- post;
- comment;
- resource;
- message;
- profile;
- team/opportunity.

Report lifecycle:

```text
OPEN
 ↓
UNDER_REVIEW
 ↓
RESOLVED / DISMISSED
```

Possible moderation actions:

- no action;
- hide content;
- remove content;
- warn user;
- restrict user;
- suspend user.

All moderation actions should be auditable.

---

# 44. ANTI-GAMING RULES

The platform has multiple reward-like systems, so define rules early.

Examples:

- XP cannot be farmed by self-interaction;
- users cannot rate themselves;
- users cannot transfer credits to themselves;
- one interaction should produce at most one settlement;
- repeated duplicate submissions should not create repeated rewards;
- abuse reports should not automatically punish users without review.

---

# 45. DATA OWNERSHIP AND PRIVACY

Users should control appropriate profile visibility.

Potential visibility states:

```text
PUBLIC
COMMUNITY_ONLY
CONNECTIONS_ONLY
PRIVATE
```

Sensitive/private data should never be exposed through public API responses.

Do not expose:

- password hashes;
- private email when configured hidden;
- auth tokens;
- private messages;
- internal moderation notes.

---

# 46. SEED DATA / DEMO DATA

Provide a realistic seed dataset for development/demo purposes.

It should contain enough variety to demonstrate:

- skills;
- categories;
- resource types;
- users;
- team openings;
- competitions;
- projects;
- sessions;
- posts;
- comments;
- tutorials;
- challenges.

Seed data must be obviously identifiable as demo data.

No fake production analytics.

---

# 47. TESTING STRATEGY

Testing is mandatory.

## Unit tests

Test business logic such as:

- skill matching;
- reputation calculations;
- reliability calculations;
- credit calculations;
- eligibility rules.

## API/integration tests

Test:

- auth;
- permissions;
- CRUD flows;
- team applications;
- credit transactions;
- resource publishing;
- messaging permissions.

## Database tests

Test constraints and transactional behavior.

Examples:

- duplicate reaction rejected;
- duplicate application rejected;
- invalid rating rejected;
- team capacity cannot be exceeded;
- credit settlement cannot happen twice;
- invalid foreign key rejected.

## E2E tests

At least cover these flows:

1. Register → create profile → add skill.
2. Search skill → find tutor → request session.
3. Publish tutorial → bookmark → rate.
4. Create team → publish opening → receive application → accept member.
5. Create project → add member → create task → complete task.
6. Competition → team → application → participation.

---

# 48. OBSERVABILITY / DEBUGGING

Development environment should provide:

- structured server logs;
- request IDs where useful;
- database error logging;
- clear validation errors;
- useful client-side error boundaries.

Do not log:

- passwords;
- auth tokens;
- private message contents unnecessarily;
- sensitive personal information unnecessarily.

---

# 49. PROJECT STRUCTURE

Recommended overall structure:

```text
skillloop/
│
├── apps/
│   ├── web/
│   └── api/
│
├── packages/
│   ├── shared-types/
│   ├── config/
│   └── validation/
│
├── database/
│   ├── migrations/
│   ├── seeds/
│   ├── views/
│   ├── functions/
│   └── triggers/
│
├── docs/
│   ├── architecture.md
│   ├── erd.md
│   ├── api.md
│   ├── dbms-features.md
│   ├── security.md
│   └── decisions/
│
├── tests/
│
├── README.md
└── .env.example
```

Exact structure may differ by framework, but separation of concerns is required.

---

# 50. TECHNOLOGY DIRECTION

A practical initial stack:

## Frontend

- React or Next.js;
- TypeScript;
- Tailwind CSS or another restrained component styling system;
- React Query / TanStack Query or equivalent for server state.

## Backend

- Node.js;
- TypeScript;
- Express/Fastify/NestJS or another well-structured API framework.

## Database

**PostgreSQL** is preferred for this project because the relational capabilities are central to the assignment.

## Validation

Use a schema validation library consistently.

## Authentication

Use secure cookie-based sessions or another deliberate secure authentication architecture.

## File storage

Use local/object storage abstraction rather than coupling application logic to arbitrary filesystem paths.

## Optional

- WebSockets for real-time chat;
- Redis only if there is a real requirement;
- background job queue only if needed.

The final stack must be documented before implementation begins.

---

# 51. DEVELOPMENT PHASES

Do not try to build everything in one generated pass.

## Phase 1 — Domain and architecture

Deliverables:

- product definition;
- user roles;
- user journeys;
- domain glossary;
- ER diagram;
- relational schema;
- state machines;
- architecture diagram;
- API conventions;
- design direction.

**No major UI coding before this phase is understood.**

## Phase 2 — Database foundation

Implement:

- database;
- migrations;
- constraints;
- indexes;
- seed data;
- core views/functions where justified.

Test the schema independently.

## Phase 3 — Auth + identity

Implement:

- registration;
- login;
- profile;
- roles;
- skills;
- privacy basics.

## Phase 4 — Knowledge + feed

Implement:

- resources;
- tutorials;
- notes;
- posts;
- comments;
- reactions;
- bookmarks;
- search.

## Phase 5 — Messaging + communities

Implement:

- conversations;
- messages;
- notifications;
- blocking/reporting.

## Phase 6 — Skill exchange

Implement:

- teaching offers;
- learning requests;
- availability;
- matching;
- sessions;
- reviews;
- Skill Credits.

## Phase 7 — Opportunities + competitions

Implement:

- opportunities;
- competitions;
- teams;
- openings;
- applications.

## Phase 8 — Projects + challenges

Implement:

- project management;
- showcase;
- challenges;
- submissions;
- XP;
- achievements.

## Phase 9 — Recommendations + analytics

Implement:

- explainable recommendations;
- learning paths;
- admin dashboard;
- advanced analytics.

## Phase 10 — Hardening

Implement/test:

- security;
- permissions;
- edge cases;
- performance;
- accessibility;
- mobile;
- error states;
- documentation.

---

# 52. DEFINITION OF DONE FOR EACH FEATURE

A feature is not “done” because a page exists.

A feature is done only when:

```text
UI
 ↓
Validation
 ↓
API
 ↓
Authorization
 ↓
Database operation
 ↓
Constraints
 ↓
Error handling
 ↓
Loading/empty states
 ↓
Tests
 ↓
Documentation
```

For example, “Create Team” is not done if it only displays a form.

It must actually:

- validate input;
- authenticate user;
- authorize creator;
- insert team;
- create creator membership;
- enforce uniqueness/capacity rules;
- return useful errors;
- update the UI from server truth;
- have tests.

---

# 53. ANTIGRAVITY OPERATING RULES

When using this document, Antigravity should behave like a senior engineer/product designer, not a code autocomplete engine.

## Before coding

Produce and inspect:

1. domain model;
2. user flows;
3. ER model;
4. database schema proposal;
5. API contract;
6. UI wireframe/information architecture;
7. implementation sequence.

## During coding

After every meaningful feature:

- run tests;
- run type checking;
- run linting;
- inspect database effects;
- inspect authorization;
- inspect error states;
- verify mobile behavior;
- verify that no mock data accidentally became a production dependency.

## When uncertain

Prefer a small, explicit design decision with documentation over silently guessing.

## When generating code

Prefer:

- readable code;
- small cohesive modules;
- explicit naming;
- shared validation;
- typed interfaces;
- real database queries;
- migrations;
- testable services.

Avoid:

- magic constants;
- giant hooks;
- generic “utils” folders filled with unrelated functions;
- one component doing everything;
- duplicated query logic;
- unnecessary abstraction layers.

---

# 54. DOCUMENTATION REQUIREMENTS

Keep documentation alongside implementation.

Required documents:

### `docs/product.md`

What the product does and why.

### `docs/domain.md`

Entities, relationships, states, and terminology.

### `docs/erd.md`

ER diagram + explanation.

### `docs/database.md`

Tables, keys, constraints, indexes, views, functions, triggers.

### `docs/api.md`

Endpoints, request/response contracts, errors.

### `docs/security.md`

Authentication, authorization, validation, file safety, abuse prevention.

### `docs/decisions/`

Architecture Decision Records for important decisions.

---

# 55. ARCHITECTURE DECISION RECORDS TO CREATE

Examples:

```text
ADR-001 Why PostgreSQL
ADR-002 Why modular monolith
ADR-003 Authentication architecture
ADR-004 Skill graph representation
ADR-005 Skill Credit ledger model
ADR-006 File storage strategy
ADR-007 Search architecture
ADR-008 Real-time messaging decision
```

Each ADR should explain:

```text
Context
Decision
Alternatives
Consequences
```

---

# 56. IMPORTANT STATE MACHINES

Document these explicitly.

## Learning Session

```text
REQUESTED
→ ACCEPTED
→ SCHEDULED
→ COMPLETED
→ REVIEWED
```

Alternate:

```text
DECLINED
CANCELLED
NO_SHOW
DISPUTED
```

## Team Application

```text
SUBMITTED
→ UNDER_REVIEW
→ ACCEPTED
```

or

```text
REJECTED
WITHDRAWN
```

## Opportunity

```text
DRAFT
→ OPEN
→ CLOSED
→ ARCHIVED
```

## Project

```text
PLANNED
→ ACTIVE
→ COMPLETED
→ ARCHIVED
```

## Report

```text
OPEN
→ UNDER_REVIEW
→ RESOLVED / DISMISSED
```

---

# 57. MVP DEFINITION

Do not let scope explode immediately.

A serious MVP should include:

### Identity

- auth;
- profile;
- skills;
- learning goals.

### Knowledge

- notes/resources;
- YouTube/tutorial links;
- search;
- bookmarks;
- ratings.

### Social

- feed;
- posts;
- comments;
- reactions.

### Messaging

- direct messages;
- basic group conversation.

### Skill exchange

- teaching offers;
- learning requests;
- availability;
- sessions;
- Skill Credits.

### Collaboration

- opportunities;
- hackathon teams;
- team openings;
- applications.

### Projects

- project pages;
- team members;
- basic tasks.

### Platform

- notifications;
- reports;
- admin basics.

The remaining advanced features can follow after this core works end-to-end.

---

# 58. FEATURES THAT CAN BE V2 / V3

Good later additions:

- organization accounts;
- verified college memberships;
- calendar integrations;
- GitHub integration;
- advanced project analytics;
- recommendation models;
- semantic search;
- AI learning assistant;
- automatic tutorial metadata extraction;
- competition API integrations;
- mentor matching improvements;
- achievement certificates;
- gamified quests;
- public portfolios;
- richer community moderation.

Do not add these just because they are listed. Build them only when the core product is stable.

---

# 59. EXAMPLE END-TO-END USER JOURNEY

### User joins SkillLoop

```text
Register
 ↓
Verify account
 ↓
Create profile
 ↓
Add skills
 ↓
Select learning goals
 ↓
Set availability
```

### User wants to learn React

```text
Learning Goal
 ↓
React skill
 ↓
Check prerequisites
 ↓
View tutorials + notes
 ↓
Find people who teach React
 ↓
Compare availability/reputation
 ↓
Request session
 ↓
Session accepted
 ↓
Session completed
 ↓
Credit settled
 ↓
Review
```

### User wants a hackathon team

```text
Search competition
 ↓
Open competition
 ↓
Find teams needing skills
 ↓
View team
 ↓
Apply
 ↓
Leader reviews profile
 ↓
Accept
 ↓
Join team chat
 ↓
Work on project
 ↓
Complete project
 ↓
Publish showcase
 ↓
Record achievement
```

This journey is the heart of the product.

---

# 60. EXAMPLE USER PROFILE STORY

A strong profile might evolve like this:

```text
Sunesh

Skills
C++ — Advanced
Java — Intermediate
DBMS — Advanced
ESP32 — Intermediate
Python — Intermediate

Learning
React
Machine Learning

Teaching
C++
DBMS
ESP32

Resources
18 shared

Tutorials
11 shared

Sessions
27 completed

Projects
6

Teams
4

Challenges
12 completed

Achievements
VMedithon finalist
DBMS Challenge winner

Reputation
Teaching       4.8
Collaboration  4.7
Resources      4.9
Reliability    4.8
```

The key point: these numbers must be calculated from real underlying records.

---

# 61. WHAT MAKES THIS A DBMS PROJECT

The project's strongest academic value should be visible.

## Relational modelling

Many entities naturally connect:

```text
Users ↔ Skills
Users ↔ Resources
Users ↔ Posts
Users ↔ Conversations
Users ↔ Sessions
Users ↔ Teams
Users ↔ Projects
Users ↔ Challenges
```

## Many-to-many relationships

Examples:

- users ↔ skills;
- resources ↔ tags;
- users ↔ teams;
- projects ↔ skills;
- competitions ↔ skills.

## Transactions

Examples:

- Skill Credit settlements;
- team acceptance;
- membership creation.

## Complex queries

Examples:

- matching;
- eligibility;
- availability overlap;
- recommendation;
- activity analytics.

## Views

Useful reporting abstractions.

## Procedures/functions

Useful transactional or domain operations.

## Triggers

Useful audit/integrity automation.

## Indexing

Needed for search and feed queries.

## Concurrency

Important when multiple users try to fill the last team slot.

That last example should be explicitly tested.

---

# 62. CONCURRENCY SCENARIO TO DEMONSTRATE

Suppose a team has:

```text
Capacity = 4
Current members = 3
```

Two students simultaneously click **Apply/Accept**.

The backend/database must prevent the result from becoming 5 members.

This is a perfect demonstration of why database-level consistency matters.

Possible strategies include:

- transaction + row locking;
- atomic update with a guarded condition;
- other carefully justified concurrency control.

The implementation choice must be documented and tested.

---

# 63. SEPARATION OF CONCERNS

### Frontend

Responsible for:

- presentation;
- user interaction;
- local UI state;
- optimistic UI only where safe.

### Backend

Responsible for:

- authentication;
- authorization;
- input validation;
- business workflows;
- orchestration;
- API contracts.

### Database

Responsible for:

- persistence;
- integrity;
- constraints;
- transaction boundaries where appropriate;
- relational queries;
- database-level automation where justified.

Do not place all business logic in React.

Do not place all logic in stored procedures.

Choose the correct layer deliberately.

---

# 64. QUALITY BAR

Before calling SkillLoop complete, ask:

### Product

- Does it solve a recognizable student problem?
- Are the core workflows coherent?
- Are features connected rather than isolated?

### Database

- Is the schema normalized?
- Are foreign keys and constraints meaningful?
- Are important operations transactional?
- Are indexes based on real query patterns?
- Can we explain every table?

### Backend

- Are permissions enforced server-side?
- Are validation and errors handled cleanly?
- Are routes organized?
- Are business rules centralized?

### Frontend

- Does every important screen have real data?
- Are loading/empty/error states present?
- Does mobile actually work?
- Is navigation coherent?

### Security

- Can users access data they should not?
- Can users bypass team limits?
- Can credit balances be manipulated?
- Can users rate themselves or spam endpoints?

### Testing

- Are important workflows tested?
- Are database constraints tested?
- Have race conditions been considered?

### Documentation

- Could another developer understand the architecture?
- Can the DBMS concepts be demonstrated during a viva?

---

# 65. FINAL PRODUCT POSITIONING

SkillLoop should be presented as:

> **A database-powered student collaboration network connecting learning, knowledge sharing, mentorship, project collaboration, competitions, and opportunities in one ecosystem.**

The application should feel like a real product first and an academic demonstration second — while still making its database architecture strong enough that the DBMS work is obvious and defensible.

---

# 66. FINAL INSTRUCTION TO ANTIGRAVITY

**Do not start by generating the whole application.**

First understand this specification.

Then produce:

1. a concise product architecture;
2. a domain model;
3. a complete ER diagram proposal;
4. normalized relational schema proposal;
5. key state machines;
6. API surface proposal;
7. frontend information architecture;
8. implementation roadmap;
9. risks and design questions;
10. a first implementation slice.

Only after that should implementation begin.

At every stage:

- preserve the database-first design;
- keep the code maintainable;
- use real data flows;
- avoid fake/demo-only UI logic in actual feature paths;
- test what is built;
- document important decisions;
- avoid unnecessary dependencies;
- avoid premature complexity;
- never sacrifice correctness for visual polish.

### The standard

**We are not trying to make a website that looks like a project.**

**We are trying to build a project that genuinely works like a product.**

---

# 67. INITIAL BUILD TARGET

The first working vertical slice should prove the architecture end-to-end:

```text
Register/Login
      ↓
Create Profile
      ↓
Add Skills + Learning Goal
      ↓
Create/Share a Tutorial or Note
      ↓
Search Resource / Person
      ↓
Create an Opportunity
      ↓
Apply to Opportunity
      ↓
Accept Applicant
      ↓
Open Team Chat
      ↓
Create Project
      ↓
Show Team + Project on Profile
```

If this slice works with real database records, authorization, constraints, tests, and polished UI, the foundation is strong enough to expand.

---

# 68. THE “MAKE HISTORY” RULE

The goal is not to have the largest feature list.

The goal is to build something that, when someone opens the repository, they can see:

```text
Thoughtful product design
        +
Serious relational modelling
        +
Real full-stack engineering
        +
Good UX
        +
Meaningful database features
        +
Testing
        +
Documentation
```

Every feature must earn its place.

Every table must have a reason.

Every relationship must represent a real concept.

Every metric must come from real data.

Every important workflow must handle failure.

Every architectural choice must be explainable.

**Build SkillLoop like we intend to keep improving it, not like we intend to submit it and forget it.**
