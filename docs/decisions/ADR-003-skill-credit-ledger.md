# ADR-003: Double-Entry Immutable Skill Credit Ledger

## Context
In a student skill-exchange platform, Skill Credits represent time spent mentoring peers. Updating credit balances using naive `UPDATE users SET balance = balance + 1` leads to lost updates, lacks accountability, and violates financial and database integrity best practices.

## Decision
We implement a double-entry style immutable transaction ledger (`credit_transactions`) linked to user `credit_accounts`.
Every credit event (session reward, booking debit, bonus reward, dispute refund) requires inserting an immutable row containing:
1. `account_id`
2. `amount` (+/- value)
3. `transaction_type`
4. `session_id` (foreign key reference to the triggering session)
5. `balance_after`
6. `idempotency_key` (UNIQUE)

All balance updates and session state transitions execute within a single atomic database transaction (`BEGIN ... COMMIT`).

## Consequences
- Impossible to manipulate balance without leaving an audit record.
- Prevents duplicate settlement via unique idempotency keys.
- Historical ledger can be audited and reconciled at any time.
