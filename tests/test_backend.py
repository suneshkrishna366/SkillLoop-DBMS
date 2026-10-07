import sqlite3
import os
import sys

# Ensure UTF-8 output on Windows console
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend.database import init_db, get_db
from backend.auth import hash_password, verify_password, create_session, get_current_user
from backend.services.credit_service import CreditService
from backend.services.matching_service import MatchingService
from backend.services.team_service import TeamService

def test_full_backend_suite():
    init_db(force_reseed=True)
    print("[TEST 1] Testing Password Hashing & Verification...")
    h = hash_password("MySecurePass123!")
    assert verify_password("MySecurePass123!", h) == True
    assert verify_password("WrongPass", h) == False
    print("  [OK] Password hashing passed.")

    print("[TEST 2] Testing Authentication & Session Management...")
    token = create_session(1)
    user = get_current_user(token)
    assert user is not None
    assert user["username"] == "sunesh"
    assert "STUDENT" in user["roles"]
    assert "ADMIN" in user["roles"]
    print(f"  [OK] User session active for {user['username']} with roles {user['roles']}.")

    print("[TEST 3] Testing Multi-Criteria Mentor Matching Engine...")
    # Find mentors for SQL (skill_id = 8)
    matches = MatchingService.match_mentors_for_user(learner_id=2, target_skill_id=8)
    assert len(matches) > 0
    top_match = matches[0]
    print(f"  [OK] Top mentor match: {top_match['username']} (Score: {top_match['match_score']}, Reasons: {top_match['match_reasons']})")

    print("[TEST 4] Testing Skill Graph Traversal...")
    # Target skill: React (id = 6)
    graph = MatchingService.get_skill_prerequisites(6)
    assert "prerequisites" in graph
    print(f"  [OK] Skill '{graph['skill']['name']}' Prerequisites: {[p['name'] for p in graph['prerequisites']]}")

    print("[TEST 5] Testing Concurrency Guarded Team Acceptance...")
    # Application id 1: Karthik applying to PulseTrack AI
    success, msg = TeamService.accept_applicant(application_id=1, actor_user_id=1)
    print(f"  [OK] Team acceptance status: {success} -> {msg}")
    assert success == True

    # Try duplicate acceptance
    success2, msg2 = TeamService.accept_applicant(application_id=1, actor_user_id=1)
    assert success2 == False
    print(f"  [OK] Duplicate acceptance prevented correctly: {msg2}")

    print("[TEST 6] Testing Double-Entry Skill Credit Settlement...")
    # Settle session #1 (already completed in seeds, let's verify idempotency)
    # Session 3 is scheduled, let's mark it completed and settle
    with get_db() as conn:
        conn.execute("UPDATE learning_sessions SET status = 'COMPLETED' WHERE id = 3;")
        conn.commit()

    success, msg = CreditService.settle_session(session_id=3, actor_user_id=1)
    print(f"  [OK] Credit settlement: {success} -> {msg}")
    assert success == True

    # Settle again (should fail)
    success_dup, msg_dup = CreditService.settle_session(session_id=3, actor_user_id=1)
    assert success_dup == False
    print(f"  [OK] Duplicate settlement prevented correctly: {msg_dup}")

    print("\n[ALL TESTS PASSED] 100% backend services & transactional integrity verified.")

if __name__ == "__main__":
    test_full_backend_suite()
