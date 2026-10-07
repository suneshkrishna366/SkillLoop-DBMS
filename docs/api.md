# SkillLoop REST API Specification

All endpoints communicate via JSON over HTTP. Standard HTTP status codes are returned with consistent error structures.

## Error Response Format
```json
{
  "error": {
    "code": "SL_ERROR_CODE",
    "message": "Human-readable description of error",
    "details": {}
  }
}
```

---

## 1. Authentication & Users
- `POST /api/auth/register` — Register a new student/user account.
- `POST /api/auth/login` — Authenticate and receive a session token.
- `GET  /api/auth/me` — Get currently authenticated user profile and roles.
- `GET  /api/users/:id` — Get public user profile, verified skills, and reputation.
- `PATCH /api/users/me` — Update bio, institutions, social links, privacy settings.
- `GET  /api/users/:id/availability` — Get user availability slots.
- `POST /api/users/me/availability` — Update own availability slots.

---

## 2. Skills & Taxonomy
- `GET  /api/skills` — List all master skills with category hierarchies.
- `GET  /api/skills/categories` — List all skill categories.
- `GET  /api/skills/:id/prerequisites` — Get prerequisite/relationship graph for a skill.
- `GET  /api/users/me/skills` — Get current user's skills with proficiencies and evidence.
- `POST /api/users/me/skills` — Add/update a skill on user profile.
- `DELETE /api/users/me/skills/:skillId` — Remove a skill from user profile.
- `GET  /api/users/me/goals` — Get active learning goals.
- `POST /api/users/me/goals` — Set a new learning goal with target date.

---

## 3. Knowledge Hub (Resources & Tutorials)
- `GET  /api/resources` — Filter and search resources (by skill, type, difficulty, search query).
- `POST /api/resources` — Upload note metadata / share tutorial link.
- `GET  /api/resources/:id` — Get resource details.
- `POST /api/resources/:id/ratings` — Rate resource (1-5 stars) and review.
- `POST /api/resources/:id/complete` — Mark resource as finished.
- `POST /api/resources/:id/bookmark` — Toggle bookmark for resource.

---

## 4. Social Feed & Discussions
- `GET  /api/posts` — Retrieve paginated social feed with filters (type, skill).
- `POST /api/posts` — Create a discussion or question post.
- `GET  /api/posts/:id` — Get post with comments and reactions.
- `POST /api/posts/:id/comments` — Add comment to post.
- `POST /api/posts/:id/reactions` — Toggle reaction (`LIKE`, `INSIGHTFUL`, `CELEBRATE`, `HELPFUL`).

---

## 5. Skill Exchange Engine & Credits
- `GET  /api/exchange/offers` — Browse active teaching offers.
- `POST /api/exchange/offers` — Publish teaching offer.
- `POST /api/exchange/match` — Find matching mentors based on skill, availability overlap, and reputation.
- `GET  /api/exchange/sessions` — List user's scheduled/requested sessions.
- `POST /api/exchange/sessions` — Request a learning session.
- `POST /api/exchange/sessions/:id/accept` — Accept requested session (Teacher).
- `POST /api/exchange/sessions/:id/complete` — Complete session and trigger atomic credit settlement.
- `POST /api/exchange/sessions/:id/review` — Submit session review and rating.
- `GET  /api/exchange/credits` — Get credit balance and immutable transaction ledger history.

---

## 6. Hackathons, Competitions & Teams
- `GET  /api/competitions` — List competitions & hackathons.
- `GET  /api/competitions/:id` — Get competition details and participating teams.
- `GET  /api/teams` — List teams with open vacancies.
- `POST /api/teams` — Create a team.
- `POST /api/teams/:id/openings` — Post a team vacancy with skill requirement.
- `POST /api/teams/openings/:id/apply` — Apply to join a team opening.
- `POST /api/teams/applications/:id/review` — Accept or reject applicant (enforces concurrency slot limit).

---

## 7. Projects & Challenges
- `GET  /api/projects` — List showcase projects.
- `POST /api/projects` — Publish a new project.
- `GET  /api/projects/:id` — Get project details, team, and task board.
- `POST /api/projects/:id/tasks` — Create task on Kanban board.
- `PATCH /api/projects/tasks/:id` — Update task status (`TODO`, `IN_PROGRESS`, `BLOCKED`, `DONE`).
- `GET  /api/challenges` — List technical challenges with XP reward.
- `POST /api/challenges/:id/submit` — Submit code solution for challenge evaluation.

---

## 8. Analytics & Admin
- `GET  /api/analytics/summary` — Get platform KPI analytics derived from database views.
- `GET  /api/analytics/queries` — Execute and inspect demo DBMS queries with execution timing.
