import sqlite3
from typing import Tuple, Optional
from backend.database import get_db

class CreditService:
    @staticmethod
    def settle_session(session_id: int, actor_user_id: int) -> Tuple[bool, str]:
        """
        Atomically settles credit transfer for a completed learning session.
        Teacher earns credits, learner spends credits.
        Enforces double-entry ledger records and prevents duplicate settlements.
        """
        with get_db() as conn:
            try:
                conn.execute("BEGIN TRANSACTION;")
                cursor = conn.cursor()

                # 1. Fetch and lock session
                cursor.execute("""
                    SELECT id, teacher_id, learner_id, skill_id, duration_minutes, status, credit_settled
                    FROM learning_sessions
                    WHERE id = ?
                """, (session_id,))
                session = cursor.fetchone()

                if not session:
                    conn.rollback()
                    return False, "Session not found."

                if session["status"] != "COMPLETED":
                    conn.rollback()
                    return False, f"Cannot settle session in '{session['status']}' state. Session must be COMPLETED."

                if session["credit_settled"] == 1:
                    conn.rollback()
                    return False, "Session credits have already been settled."

                teacher_id = session["teacher_id"]
                learner_id = session["learner_id"]
                duration = session["duration_minutes"]

                # Credit calculation: 30m = 0.5, 60m = 1.0, 90m = 1.5
                credit_amount = round(duration / 60.0, 2)
                if credit_amount <= 0:
                    credit_amount = 1.0

                # 2. Check learner balance
                cursor.execute("SELECT balance FROM credit_accounts WHERE user_id = ?", (learner_id,))
                learner_acc = cursor.fetchone()
                if not learner_acc or learner_acc["balance"] < credit_amount:
                    conn.rollback()
                    return False, f"Learner has insufficient Skill Credits (Required: {credit_amount}, Balance: {learner_acc['balance'] if learner_acc else 0.0})."

                # 3. Debit learner
                learner_new_balance = round(learner_acc["balance"] - credit_amount, 2)
                cursor.execute("""
                    UPDATE credit_accounts
                    SET balance = ?, total_spent = total_spent + ?, updated_at = CURRENT_TIMESTAMP
                    WHERE user_id = ?
                """, (learner_new_balance, credit_amount, learner_id))

                idempotency_learner = f"SETTLE_SESSION_{session_id}_LEARNER"
                cursor.execute("""
                    INSERT INTO credit_transactions 
                    (account_id, amount, transaction_type, session_id, balance_after, idempotency_key, description)
                    VALUES (?, ?, 'SPENT_LEARNING', ?, ?, ?, ?)
                """, (learner_id, -credit_amount, session_id, learner_new_balance, idempotency_learner, f"Completed learning session #{session_id}"))

                # 4. Credit teacher
                cursor.execute("SELECT balance FROM credit_accounts WHERE user_id = ?", (teacher_id,))
                teacher_acc = cursor.fetchone()
                teacher_balance = teacher_acc["balance"] if teacher_acc else 0.0
                teacher_new_balance = round(teacher_balance + credit_amount, 2)

                cursor.execute("""
                    UPDATE credit_accounts
                    SET balance = ?, total_earned = total_earned + ?, updated_at = CURRENT_TIMESTAMP
                    WHERE user_id = ?
                """, (teacher_new_balance, credit_amount, teacher_id))

                idempotency_teacher = f"SETTLE_SESSION_{session_id}_TEACHER"
                cursor.execute("""
                    INSERT INTO credit_transactions 
                    (account_id, amount, transaction_type, session_id, balance_after, idempotency_key, description)
                    VALUES (?, ?, 'EARNED_TEACHING', ?, ?, ?, ?)
                """, (teacher_id, credit_amount, session_id, teacher_new_balance, idempotency_teacher, f"Earned credits for teaching session #{session_id}"))

                # 5. Mark session as settled
                cursor.execute("""
                    UPDATE learning_sessions
                    SET credit_settled = 1, updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (session_id,))

                # 6. Insert notification for both parties
                cursor.execute("""
                    INSERT INTO notifications (user_id, type, title, message, entity_type, entity_id)
                    VALUES (?, 'CREDIT_EARNED', 'Skill Credits Earned!', ?, 'CREDIT_TRANSACTION', ?)
                """, (teacher_id, f"You earned +{credit_amount} Skill Credits for teaching session #{session_id}.", session_id))

                cursor.execute("""
                    INSERT INTO notifications (user_id, type, title, message, entity_type, entity_id)
                    VALUES (?, 'CREDIT_SPENT', 'Skill Credits Deducted', ?, 'CREDIT_TRANSACTION', ?)
                """, (learner_id, f"{credit_amount} Skill Credits deducted for completing session #{session_id}.", session_id))

                conn.commit()
                return True, f"Successfully settled {credit_amount} Skill Credits."

            except sqlite3.IntegrityError as ie:
                conn.rollback()
                return False, f"Database integrity error: {str(ie)}"
            except Exception as e:
                conn.rollback()
                return False, f"Transaction error: {str(e)}"
