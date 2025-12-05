"""Service layer for Chef-Kit backend.

Contains functions that wrap Supabase client operations.
Keeping database logic here makes `app.py` simple and easy to test.
"""
from typing import Any, Dict, List, Optional
from supabase_client import supabase
from supabase_client import set_postgrest_token
# -----------------------------
# Auth
# -----------------------------
def auth_signup(email: str, password: str) -> Dict[str, Any]:
    """Sign up a user via Supabase Auth."""
    # Check if email already exists in public.users (or attempt login to detect existing auth user)
    try:
        # Try to find existing user in public.users table
        existing = supabase.table("users").select("user_email").eq("user_email", email).execute()
        if existing.data and len(existing.data) > 0:
            raise ValueError("email_exists: User with this email already exists")
    except ValueError:
        raise
    except Exception:
        # If table check fails, proceed with signup attempt
        pass
    
    try:
        resp = supabase.auth.sign_up({"email": email, "password": password})
        # Check if Supabase returned existing user (some configs do this)
        if resp and hasattr(resp, 'user') and resp.user:
            user_data = resp.user
            # If user exists and is already confirmed, reject
            if hasattr(user_data, 'email_confirmed_at') and user_data.email_confirmed_at:
                raise ValueError("email_exists: User already registered and verified")
    except ValueError:
        raise
    except Exception as e:
        msg = str(e)
        if "already registered" in msg or "User already exists" in msg:
            raise ValueError(f"email_exists: {e}")
        raise RuntimeError(f"signup_failed: {e}")
    # Return a simple JSON-serializable response
    return {"message": "signup_ok"}


def auth_login(email: str, password: str) -> Dict[str, Any]:
    """Login via Supabase Auth (password)."""
    try:
        session = supabase.auth.sign_in_with_password({"email": email, "password": password})
    except Exception as e:
        # Only map unverified email specifically; otherwise bubble up
        msg = str(e)
        if "Email not confirmed" in msg or "unverified_email" in msg:
            # For unverified users attempting login, trigger a new signup to resend confirmation
            # This works because Supabase allows re-signup for unconfirmed emails
            try:
                supabase.auth.sign_up({"email": email, "password": password})
            except Exception:
                # If re-signup fails, try resend as fallback
                try:
                    supabase.auth.resend({"email": email, "type": "signup"})
                except Exception:
                    pass
            raise PermissionError(f"unverified_email: {e}")
        # Other auth errors
        raise RuntimeError(f"login_failed: {e}")
    # Build a minimal, serializable user payload
    user_payload: Dict[str, Any] = {}
    try:
        user_obj = getattr(session, "user", None)
        user_id = getattr(user_obj, "id", None)
        user_email = getattr(user_obj, "email", email)
        user_payload = {"id": user_id, "email": user_email}
        # Extract tokens robustly across client versions
        access_token = (
            getattr(session, "access_token", None)
            or (getattr(getattr(session, "session", None), "access_token", None))
        )
        refresh_token = (
            getattr(session, "refresh_token", None)
            or (getattr(getattr(session, "session", None), "refresh_token", None))
        )
        if not access_token or not refresh_token:
            # Do not assume unverified if tokens missing; treat as login error
            raise RuntimeError("login_failed: missing tokens")
        # Attach access token to PostgREST so RLS recognizes auth.uid()
        set_postgrest_token(access_token)
        # Ensure a corresponding row exists in public.users
        try:
            existing = supabase.table("users").select("user_id").eq("user_id", user_id).single().execute()
            # If no data, insert a minimal profile
            if not getattr(existing, "data", None):
                _ = supabase.table("users").insert({
                    "user_id": user_id,
                    "user_full_name": None,
                    "user_email": user_email,
                }).execute()
        except Exception:
            # Attempt insert blindly if select failed
            _ = supabase.table("users").insert({
                "user_id": user_id,
                "user_full_name": None,
                "user_email": user_email,
            }).execute()
    except Exception:
        user_payload = {"email": email}
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": user_payload,
    }


def auth_refresh(refresh_token: str) -> Dict[str, Any]:
    """Refresh an access token using refresh token."""
    try:
        response = supabase.auth.refresh_session(refresh_token)
        
        # Extract session from AuthResponse
        new_session = getattr(response, "session", None)
        if not new_session:
            raise ValueError("No session in refresh response")
        
        user_payload: Dict[str, Any] = {}
        try:
            user_obj = getattr(response, "user", None) or getattr(new_session, "user", None)
            user_payload = {
                "id": getattr(user_obj, "id", None),
                "email": getattr(user_obj, "email", None),
            }
        except Exception:
            user_payload = {}
        
        access_token = getattr(new_session, "access_token", None)
        refresh_token_new = getattr(new_session, "refresh_token", None)
        
        if not access_token or not refresh_token_new:
            raise ValueError("Missing tokens in refresh response")
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token_new,
            "user": user_payload,
        }
    except Exception as e:
        raise ValueError(f"Failed to refresh token: {str(e)}")


def auth_logout() -> None:
    """Sign out current session."""
    supabase.auth.sign_out()
    return None

def auth_verify_email_otp(email: str, token: str) -> Dict[str, Any]:
    """Verify email using OTP token after signup/login when using OTP provider."""
    try:
        # Use 'signup' for email confirmation OTP verification
        resp = supabase.auth.verify_otp({"email": email, "token": token, "type": "signup"})
        # Attach token to PostgREST if session present
        if getattr(resp, "session", None) and getattr(resp.session, "access_token", None):
            set_postgrest_token(resp.session.access_token)
        user_payload: Dict[str, Any] = {}
        try:
            user_payload = {
                "id": getattr(resp.user, "id", None),
                "email": getattr(resp.user, "email", email),
            }
        except Exception:
            user_payload = {"email": email}
        return {"message": "verified", "user": user_payload}
    except Exception as e:
        raise RuntimeError(f"verify_failed: {e}")


# -----------------------------
# Users
# -----------------------------
def get_all_users() -> List[Dict[str, Any]]:
    resp = supabase.table("users").select("*").execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def get_user(user_id: str) -> Optional[Dict[str, Any]]:
    resp = supabase.table("users").select("*").eq("user_id", user_id).single().execute()
    if resp.error:
        # If not found, supabase client may return an error; bubble up
        raise RuntimeError(resp.error.message)
    return resp.data


def create_user(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("users").insert(data).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def update_user(user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("users").update(data).eq("user_id", user_id).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


# -----------------------------
# Recipes
# -----------------------------
def get_all_recipes() -> List[Dict[str, Any]]:
    resp = supabase.table("recipe").select("*").execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def get_recipe(recipe_id: str) -> Dict[str, Any]:
    resp = supabase.table("recipe").select("*").eq("recipe_id", recipe_id).single().execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def create_recipe(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("recipe").insert(data).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def update_recipe(recipe_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("recipe").update(data).eq("recipe_id", recipe_id).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def delete_recipe(recipe_id: str) -> None:
    resp = supabase.table("recipe").delete().eq("recipe_id", recipe_id).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return None


# -----------------------------
# Ingredients
# -----------------------------
def get_all_ingredients() -> List[Dict[str, Any]]:
    resp = supabase.table("ingredients").select("*").execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def get_ingredient(ingredient_id: str) -> Dict[str, Any]:
    resp = supabase.table("ingredients").select("*").eq("ingredient_id", ingredient_id).single().execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def create_ingredient(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("ingredients").insert(data).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


# -----------------------------
# Notifications
# -----------------------------
def get_notifications_for_user(user_id: str) -> List[Dict[str, Any]]:
    resp = supabase.table("notifications").select("*").eq("user_id", user_id).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def create_notification(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("notifications").insert(data).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data


def mark_notification_read(notification_id: str) -> Dict[str, Any]:
    resp = supabase.table("notifications").update({"notification_is_read": True}).eq("notification_id", notification_id).execute()
    if resp.error:
        raise RuntimeError(resp.error.message)
    return resp.data
