# SkillLoop Security & Data Protection Specification

## 1. Authentication & Session Security
- **Password Hashing**: PBKDF2 with SHA-256 (or bcrypt/Argon2) with high work factor and unique per-user salt.
- **Session Tokens**: Cryptographically random bearer tokens stored securely.
- **Brute Force Protection**: Failed login throttling per IP/username.

## 2. Authorization & RBAC
- Explicit server-side permission checks on all mutation endpoints:
  - Users can only edit/delete their own resources, posts, comments, and applications.
  - Only team leaders can modify team properties, create openings, and accept/reject candidates.
  - Only project owners/members can manage project Kanban tasks.
  - Only assigned moderators and admins can access moderation dashboards and audit logs.

## 3. SQL Injection Defense
- **Strict Parameterized Queries**: All database interactions use parameter substitution (`?` or named parameters).
- **No Dynamic String Concatenation**: Query structures are fixed; user inputs are passed strictly as query arguments.

## 4. Input Validation & Data Sanitization
- All request payloads are strictly validated against strong schemas.
- Text content is escaped to prevent Cross-Site Scripting (XSS).
- Numeric ranges are strictly enforced (`rating` between 1 and 5, `duration` in allowed sets, `page` and `limit` bounded).

## 5. Transaction Safety & Concurrency Control
- Double-entry credit settlement is wrapped in ACID transactions.
- Team slot occupation uses transaction guards to prevent exceeding max members during concurrent applications.
