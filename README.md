# SkillLoop — Student Knowledge, Mentorship & Collaboration Network

> **DBMS Core Platform**: 3NF Normalized Relational Database, ACID Double-Entry Ledger, Multi-Dimensional Reputation Engine & Interactive Kanban Board.

---

## 🌟 Key Features

1. **Relational Skill Graph & Prerequisite Trees**:
   - Master taxonomy supporting directed prerequisite relationships (`PREREQUISITE_OF`, `RELATED_TO`, `COMMONLY_USED_WITH`).
   - Interactive dependency inspector for student roadmap planning.

2. **Knowledge Hub & Tutorials**:
   - Searchable student resource metadata catalog (PDF notes, YouTube playlists, cheat sheets, code repositories).
   - Rating, bookmarking, and completion metrics computed via SQL views (`v_resource_quality`).

3. **Peer Mentorship & Skill Credit Ledger**:
   - **Double-Entry Ledger**: Immutable transaction audit log (`credit_transactions`) with atomic balance updates and idempotency keys.
   - **Transparent 4-Factor Matching Engine**: Matches learners with mentors based on skill proficiency, availability overlap, teaching reputation, and completed sessions.

4. **Hackathon Teams & Concurrency-Guarded Recruitment**:
   - Openings catalog for hackathons like *VMedithon 2026*.
   - Transactional slot guard preventing team capacity over-subscription under race conditions.

5. **Projects & Interactive Kanban Board**:
   - Problem/solution statements, member collaboration roles, and interactive 4-column Kanban board (`TODO`, `IN_PROGRESS`, `BLOCKED`, `DONE`).

6. **Technical Challenges & XP Sandbox**:
   - Coding and DBMS problem evaluation with instant XP and reputation progression.

7. **DBMS Core & Relational Query Explorer**:
   - Real-time visualization of views: `v_user_reputation`, `v_team_openings`, `v_mutual_skill_matches`, `v_resource_quality`.
   - Comprehensive demonstration SQL query library with 20+ scenarios.

---

## 🚀 Quick Start (Local Run)

### Prerequisites
- Python 3.10+ (Standard library only — zero pip dependencies required!)

### 1. Launch the Server
```bash
py backend/server.py
```
*The database automatically creates and seeds `database/skillloop.db` on first launch.*

### 2. Open in Browser
Navigate to:
```text
http://localhost:8000/
```

### 3. Run Automated Tests
```bash
py tests/test_schema.py
py tests/test_backend.py
```

---

## 📂 Project Architecture

```text
DBMS Project/
├── backend/
│   ├── database.py           # SQLite / MySQL manager, auto-migrator & connection pool
│   ├── auth.py               # PBKDF2 hashing, sessions & RBAC
│   ├── server.py             # REST API router & static asset server
│   └── services/
│       ├── credit_service.py # ACID credit settlement & immutable ledger
│       ├── matching_service.py # Deterministic explainable mentor matching
│       └── team_service.py   # Concurrency-safe team vacancy acceptance
├── frontend/
│   ├── index.html            # Semantic HTML5 SPA layout
│   ├── css/main.css          # Design system & dark theme
│   └── js/
│       ├── api.js            # REST API client with Bearer auth
│       └── app.js            # Router, state, modals & view controllers
├── database/
│   ├── schema.sql            # 3NF relational DDL with constraints & indexes
│   ├── views.sql             # Analytical & reporting views
│   ├── triggers.sql          # Integrity & audit triggers
│   ├── seeds.sql             # Realistic student demo dataset
│   └── queries.sql           # 20+ DBMS scenario demonstration queries
├── docs/
│   ├── architecture.md       # Modular monolith architecture
│   ├── domain.md             # Domain entities & state machines
│   ├── erd.md                # Entity-Relationship diagram
│   ├── database.md           # Database specification
│   ├── api.md                # REST API contracts
│   ├── security.md           # Security & validation rules
│   └── decisions/            # Architecture Decision Records (ADRs)
└── tests/
    ├── test_schema.py        # Schema integrity & constraint tests
    └── test_backend.py       # Full backend services test suite
```
