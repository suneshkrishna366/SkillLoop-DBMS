import sqlite3
import os
import threading
from contextlib import contextmanager

DB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "database"))
DB_PATH = os.path.join(DB_DIR, "skillloop.db")

_lock = threading.Lock()

def get_db_connection():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.row_factory = sqlite3.Row
    return conn

@contextmanager
def get_db():
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()

def init_db(force_reseed=False):
    with _lock:
        db_exists = os.path.exists(DB_PATH)
        if force_reseed and db_exists:
            os.remove(DB_PATH)
            db_exists = False

        if not db_exists:
            print(f"[DB] Initializing new SkillLoop database at {DB_PATH}")
            conn = get_db_connection()
            cursor = conn.cursor()

            # Execute schema
            schema_file = os.path.join(DB_DIR, "schema.sql")
            with open(schema_file, "r", encoding="utf-8") as f:
                cursor.executescript(f.read())

            # Execute views
            views_file = os.path.join(DB_DIR, "views.sql")
            with open(views_file, "r", encoding="utf-8") as f:
                cursor.executescript(f.read())

            # Execute triggers
            triggers_file = os.path.join(DB_DIR, "triggers.sql")
            with open(triggers_file, "r", encoding="utf-8") as f:
                cursor.executescript(f.read())

            # Execute seeds
            seeds_file = os.path.join(DB_DIR, "seeds.sql")
            with open(seeds_file, "r", encoding="utf-8") as f:
                cursor.executescript(f.read())

            conn.commit()
            conn.close()
            print("[DB] Schema, views, triggers, and seed records successfully initialized.")
        else:
            print(f"[DB] Using existing database at {DB_PATH}")
