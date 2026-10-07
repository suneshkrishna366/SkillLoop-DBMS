# SkillLoop System Architecture

## 1. High-Level Architecture

SkillLoop is structured as a **Modular Monolith** with a decoupled high-performance Python/FastAPI backend, clean REST API layer, transaction-managed Relational Core (SQLite with Foreign Key & Trigger support / MySQL 8.0), and a responsive SPA frontend.

```text
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT / BROWSER TIER                    │
│  - Responsive SPA (HTML5, Vanilla ES6 Modules, Modern CSS3) │
│  - Interactive Kanban Boards, Live Search, Graphs, Filters   │
└──────────────────────────────┬──────────────────────────────┘
                               │ JSON / HTTP REST
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND / API TIER                      │
│  - FastAPI / Python Modular Application Architecture        │
│  - Request Validation & Serialization (Pydantic / Clean DTO)│
│  - Session & Token Authentication (Secure Bearer / JWT)     │
│  - Role-Based Access Control (RBAC) Enforcement             │
│  - Domain Service Layer (Settlement, Matching, Concurrency) │
└──────────────────────────────┬──────────────────────────────┘
                               │ ACID Transactions / Parameterized SQL
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 RELATIONAL DATABASE ENGINE                  │
│  - 3NF Normalized Entities & Composite Keys                 │
│  - Constraints (CHECK, UNIQUE, FOREIGN KEY, NOT NULL)       │
│  - Automated Audit & Trigger Integrity                      │
│  - Relational Analytical Views                              │
│  - Immutable Double-Entry Credit Ledger                     │
└─────────────────────────────────────────────────────────────┘
```

## 2. Directory Structure

```text
DBMS Project/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── auth.py
│   │   ├── models.py
│   │   ├── routes/
│   │   │   ├── auth.py
│   │   │   ├── users.py
│   │   │   ├── skills.py
│   │   │   ├── resources.py
│   │   │   ├── posts.py
│   │   │   ├── exchange.py
│   │   │   ├── competitions.py
│   │   │   ├── teams.py
│   │   │   ├── opportunities.py
│   │   │   ├── projects.py
│   │   │   ├── challenges.py
│   │   │   ├── notifications.py
│   │   │   └── analytics.py
│   │   └── services/
│   │       ├── matching_service.py
│   │       ├── credit_service.py
│   │       └── team_service.py
├── frontend/
│   ├── index.html
│   ├── css/
│   │   ├── main.css
│   │   └── components.css
│   └── js/
│       ├── app.js
│       ├── api.js
│       ├── state.js
│       └── views/
│           ├── dashboard.js
│           ├── skills.js
│           ├── resources.js
│           ├── feed.js
│           ├── exchange.js
│           ├── competitions.js
│           ├── teams.js
│           ├── projects.js
│           ├── challenges.js
│           ├── profile.js
│           └── admin.js
├── database/
│   ├── schema.sql
│   ├── views.sql
│   ├── triggers.sql
│   ├── seeds.sql
│   └── queries.sql
├── docs/
│   ├── architecture.md
│   ├── domain.md
│   ├── erd.md
│   ├── database.md
│   ├── api.md
│   ├── security.md
│   └── decisions/
└── tests/
    ├── test_schema.py
    ├── test_auth.py
    ├── test_exchange_transactions.py
    └── test_team_concurrency.py
```
