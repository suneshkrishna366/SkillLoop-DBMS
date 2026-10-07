# ADR-001: Selection of Relational Database Core

## Context
SkillLoop is a student knowledge network with deeply interconnected relational entities: users, verified skills, prerequisite graphs, double-entry credit ledger, teams, openings, applications, session states, and audit logs. The system requires strict ACID consistency, referential integrity, check constraints, composite keys, and analytical views for academic DBMS defense.

## Decision
We implement a first-class SQL relational core (supporting standard SQL DDL, SQLite for zero-config portable execution with `PRAGMA foreign_keys = ON` and transaction guarantees, alongside MySQL 8.0 compatibility).

## Consequences
- Guarantees strict referential integrity without orphan records.
- Enables expressive queries for mentor matching, team suitability, and learning path prerequisites.
- Provides demonstrable stored procedures, triggers, views, and execution query plans (`EXPLAIN QUERY PLAN`).
