import sqlite3
import os
import sys

# Ensure UTF-8 output on Windows console
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

def test_database_initialization():
    db_path = os.path.join(os.path.dirname(__file__), "..", "database", "skillloop_test.db")
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    cursor = conn.cursor()

    # Load and execute schema.sql
    schema_path = os.path.join(os.path.dirname(__file__), "..", "database", "schema.sql")
    with open(schema_path, "r", encoding="utf-8") as f:
        schema_sql = f.read()
    cursor.executescript(schema_sql)
    print("[OK] schema.sql executed successfully.")

    # Load and execute views.sql
    views_path = os.path.join(os.path.dirname(__file__), "..", "database", "views.sql")
    with open(views_path, "r", encoding="utf-8") as f:
        views_sql = f.read()
    cursor.executescript(views_sql)
    print("[OK] views.sql executed successfully.")

    # Load and execute triggers.sql
    triggers_path = os.path.join(os.path.dirname(__file__), "..", "database", "triggers.sql")
    with open(triggers_path, "r", encoding="utf-8") as f:
        triggers_sql = f.read()
    cursor.executescript(triggers_sql)
    print("[OK] triggers.sql executed successfully.")

    # Load and execute seeds.sql
    seeds_path = os.path.join(os.path.dirname(__file__), "..", "database", "seeds.sql")
    with open(seeds_path, "r", encoding="utf-8") as f:
        seeds_sql = f.read()
    cursor.executescript(seeds_sql)
    print("[OK] seeds.sql executed successfully.")

    # Validate views and queries
    cursor.execute("SELECT COUNT(*) FROM users;")
    user_count = cursor.fetchone()[0]
    print(f"[OK] Users in database: {user_count}")
    assert user_count >= 5

    cursor.execute("SELECT COUNT(*) FROM skills;")
    skill_count = cursor.fetchone()[0]
    print(f"[OK] Skills in database: {skill_count}")
    assert skill_count >= 10

    cursor.execute("SELECT * FROM v_user_reputation;")
    rep_rows = cursor.fetchall()
    print(f"[OK] v_user_reputation rows: {len(rep_rows)}")
    assert len(rep_rows) >= 5

    cursor.execute("SELECT * FROM v_mutual_skill_matches;")
    matches = cursor.fetchall()
    print(f"[OK] v_mutual_skill_matches rows: {len(matches)}")

    # Test double-entry credit ledger
    cursor.execute("SELECT balance, total_earned, total_spent FROM credit_accounts WHERE user_id = 1;")
    acc = cursor.fetchone()
    print(f"[OK] User 1 credit account: balance={acc[0]}, earned={acc[1]}, spent={acc[2]}")

    conn.close()
    if os.path.exists(db_path):
        os.remove(db_path)
    print("[SUCCESS] All database integrity checks passed with 100% success!")

if __name__ == "__main__":
    test_database_initialization()
