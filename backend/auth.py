import hashlib
import secrets
import time
from typing import Optional, Dict, Any
from backend.database import get_db

# In-memory session store mapping session_token -> dict(user_id, created_at)
_SESSIONS: Dict[str, Dict[str, Any]] = {}
SESSION_EXPIRY_SECONDS = 86400 * 7  # 7 days

def hash_password(password: str, salt: Optional[str] = None) -> str:
    if not salt:
        salt = secrets.token_hex(16)
    # PBKDF2 HMAC SHA-256 with 100,000 iterations
    key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 100000)
    return f"pbkdf2_sha256$100000${salt}${key.hex()}"

def verify_password(password: str, hashed: str) -> bool:
    if hashed.startswith("pbkdf2$demo$"):
        # Demo fallback for pre-seeded test accounts
        return password == "SkillLoopPass123!"
    try:
        algorithm, iterations, salt, expected_hex = hashed.split("$")
        key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), int(iterations))
        return secrets.compare_digest(key.hex(), expected_hex)
    except Exception:
        return False

def create_session(user_id: int) -> str:
    token = secrets.token_urlsafe(32)
    _SESSIONS[token] = {
        "user_id": user_id,
        "created_at": time.time()
    }
    return token

def get_current_user(token: Optional[str]) -> Optional[Dict[str, Any]]:
    if not token or token not in _SESSIONS:
        return None
    
    session = _SESSIONS[token]
    if time.time() - session["created_at"] > SESSION_EXPIRY_SECONDS:
        del _SESSIONS[token]
        return None

    user_id = session["user_id"]
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT u.id, u.username, u.email, u.full_name, u.bio, u.avatar_url, 
                   u.institution, u.department, u.year_of_study, u.github_url, 
                   u.linkedin_url, u.reputation_score, u.is_active,
                   ca.balance AS credit_balance
            FROM users u
            LEFT JOIN credit_accounts ca ON u.id = ca.user_id
            WHERE u.id = ? AND u.is_active = 1
        """, (user_id,))
        row = cursor.fetchone()
        if not row:
            return None
        
        user_dict = dict(row)
        # Fetch user roles
        cursor.execute("""
            SELECT r.name FROM roles r
            JOIN user_roles ur ON r.id = ur.role_id
            WHERE ur.user_id = ?
        """, (user_id,))
        user_dict["roles"] = [r["name"] for r in cursor.fetchall()]
        return user_dict

def invalidate_session(token: str):
    if token in _SESSIONS:
        del _SESSIONS[token]
