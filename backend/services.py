"""Service layer for Chef-Kit backend.

Contains functions that wrap Supabase client operations.
Keeping database logic here makes `app.py` simple and easy to test.
"""
from typing import Any, Dict, List, Optional
from supabase_client import supabase
from supabase_client import set_postgrest_token


def _extract_response_data(resp):
    """Normalize Supabase client responses across versions."""
    error = getattr(resp, "error", None)
    if error:
        message = getattr(error, "message", None) or str(error)
        raise RuntimeError(message)

    data = getattr(resp, "data", None)
    return data
# -----------------------------
# Auth
# -----------------------------
def auth_signup(email: str, password: str, full_name: Optional[str] = None) -> Dict[str, Any]:
    """Sign up a user via Supabase Auth and create user profile."""
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
            user_id = getattr(user_data, 'id', None)
            
            # If user exists and is already confirmed, reject
            if hasattr(user_data, 'email_confirmed_at') and user_data.email_confirmed_at:
                raise ValueError("email_exists: User already registered and verified")
            
            # Create user profile immediately with provided name
            if user_id:
                default_avatar = "https://via.placeholder.com/250/FF6B6B/FFFFFF?text=Chef"
                try:
                    supabase.table("users").insert({
                        "user_id": user_id,
                        "user_full_name": full_name,
                        "user_email": email,
                        "user_avatar": default_avatar,
                        "user_following_count": 0,
                        "user_followers_count": 0,
                        "user_recipes_count": 0,
                        "user_is_chef": False,
                    }).execute()
                    print(f"Created user profile for {email} with name: {full_name}")
                except Exception as e:
                    print(f"Failed to create user profile during signup: {e}")
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
        default_avatar = "https://via.placeholder.com/250/FF6B6B/FFFFFF?text=Chef"
        # Try to get user metadata for full name
        user_metadata = getattr(user_obj, 'user_metadata', {})
        full_name = user_metadata.get('full_name') if user_metadata else None
        
        try:
            existing = supabase.table("users").select("user_id").eq("user_id", user_id).single().execute()
            # If no data, insert a profile with name from metadata if available
            if not getattr(existing, "data", None):
                _ = supabase.table("users").insert({
                    "user_id": user_id,
                    "user_full_name": full_name,
                    "user_email": user_email,
                    "user_avatar": default_avatar,
                    "user_following_count": 0,
                    "user_followers_count": 0,
                    "user_recipes_count": 0,
                    "user_is_chef": False,
                }).execute()
        except Exception:
            # Attempt insert blindly if select failed
            _ = supabase.table("users").insert({
                "user_id": user_id,
                "user_full_name": full_name,
                "user_email": user_email,
                "user_avatar": default_avatar,
                "user_following_count": 0,
                "user_followers_count": 0,
                "user_recipes_count": 0,
                "user_is_chef": False,
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
    data = _extract_response_data(resp)
    if data is None:
        raise RuntimeError("Failed to fetch users")
    return data if isinstance(data, list) else [data]


def get_user(user_id: str) -> Optional[Dict[str, Any]]:
    """Get user by ID. If not found in public.users, create a minimal profile."""
    try:
        resp = supabase.table("users").select("*").eq("user_id", user_id).single().execute()
        if resp.data:
            print(f"=== get_user returning data ===")
            print(f"User ID: {user_id}")
            print(f"Response data: {resp.data}")
            print(f"user_full_name: {resp.data.get('user_full_name')}")
            print(f"user_avatar: {resp.data.get('user_avatar')}")
            print(f"==============================")
            return resp.data
    except Exception as e:
        # User not found, try to create a minimal profile
        print(f"User {user_id} not found in database: {e}")
    
    # Create minimal user profile with default values
    try:
        # Get email from auth.users if possible (requires service role key)
        default_avatar = "https://via.placeholder.com/250/FF6B6B/FFFFFF?text=Chef"
        minimal_profile = {
            "user_id": user_id,
            "user_full_name": "User",
            "user_email": None,  # Will be updated on next login
            "user_avatar": default_avatar,
            "user_following_count": 0,
            "user_followers_count": 0,
            "user_recipes_count": 0,
            "user_is_chef": False,
        }
        print(f"Attempting to create user profile: {minimal_profile}")
        resp = supabase.table("users").insert(minimal_profile).execute()
        print(f"Insert response: {resp}")
        if resp.data and len(resp.data) > 0:
            return resp.data[0]
        return minimal_profile
    except Exception as e:
        print(f"Failed to create user profile: {e}")
        raise RuntimeError(f"User not found and failed to create profile: {e}")


def create_user(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("users").insert(data).execute()
    result = _extract_response_data(resp)
    return result


def update_user(user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("users").update(data).eq("user_id", user_id).execute()
    result = _extract_response_data(resp)
    if isinstance(result, list) and result:
        return result[0]
    return result or {}


# Alias for clearer import naming in app.py
update_user_service = update_user


# -----------------------------
# Recipes
# -----------------------------
def get_all_recipes() -> List[Dict[str, Any]]:
    resp = supabase.table("recipe").select("*").execute()
    data = _extract_response_data(resp)
    return data or []


def get_recipe(recipe_id: str) -> Dict[str, Any]:
    resp = supabase.table("recipe").select("*").eq("recipe_id", recipe_id).single().execute()
    data = _extract_response_data(resp)
    return data or {}


def create_recipe(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("recipe").insert(data).execute()
    data = _extract_response_data(resp)
    return data


def update_recipe(recipe_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    print(f"[services.update_recipe] Recipe ID: {recipe_id}")
    print(f"[services.update_recipe] Data to update: {data}")
    print(f"[services.update_recipe] recipe_image_url value: {data.get('recipe_image_url')}")
    
    # Execute update
    resp = supabase.table("recipe").update(data).eq("recipe_id", recipe_id).execute()
    result = _extract_response_data(resp)
    
    print(f"[services.update_recipe] Update response from Supabase: {result}")
    
    # If update returns empty (due to RLS or old client), fetch the updated record
    if not result or (isinstance(result, list) and len(result) == 0):
        print(f"[services.update_recipe] Empty response, fetching updated record...")
        fetch_resp = supabase.table("recipe").select("*").eq("recipe_id", recipe_id).single().execute()
        result = _extract_response_data(fetch_resp)
        print(f"[services.update_recipe] Fetched record: {result}")
    
    if isinstance(result, list) and result:
        final_data = result[0]
        print(f"[services.update_recipe] Final recipe_image_url: {final_data.get('recipe_image_url')}")
        return final_data
    elif isinstance(result, dict):
        print(f"[services.update_recipe] Final recipe_image_url: {result.get('recipe_image_url')}")
        return result
    
    print(f"[services.update_recipe] ⚠️ WARNING: Could not retrieve updated recipe")
    return {}


def delete_recipe(recipe_id: str) -> None:
    resp = supabase.table("recipe").delete().eq("recipe_id", recipe_id).execute()
    _extract_response_data(resp)
    return None


# -----------------------------
# Ingredients
# -----------------------------
def get_all_ingredients() -> List[Dict[str, Any]]:
    resp = supabase.table("ingredients").select("*").execute()
    data = _extract_response_data(resp)
    return data or []


def get_ingredient(ingredient_id: str) -> Dict[str, Any]:
    resp = supabase.table("ingredients").select("*").eq("ingredient_id", ingredient_id).single().execute()
    data = _extract_response_data(resp)
    if isinstance(data, dict) and data:
        return data
    # Fall back to raw attribute in case of single() returning dict directly
    if getattr(resp, "data", None):
        return resp.data
    raise RuntimeError(f"Ingredient {ingredient_id} not found")


def create_ingredient(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("ingredients").insert(data).execute()
    data = _extract_response_data(resp)
    return data


# -----------------------------
# Notifications
# -----------------------------
def get_notifications_for_user(user_id: str) -> List[Dict[str, Any]]:
    resp = supabase.table("notifications").select("*").eq("user_id", user_id).execute()
    data = _extract_response_data(resp)
    return data or []


def create_notification(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("notifications").insert(data).execute()
    data = _extract_response_data(resp)
    return data


def mark_notification_read(notification_id: str) -> Dict[str, Any]:
    resp = supabase.table("notifications").update({"notification_is_read": True}).eq("notification_id", notification_id).execute()
    data = _extract_response_data(resp)
    if isinstance(data, list) and data:
        return data[0]
    return data or {}


# -----------------------------
# Chefs (users with special queries)
# -----------------------------
def get_chefs_on_fire() -> List[Dict[str, Any]]:
    """Get all chefs that are marked as 'on fire'."""
    resp = supabase.table("users").select("*").eq("user_is_on_fire", True).eq("user_is_chef", True).execute()
    data = _extract_response_data(resp)
    return data or []


def get_chef_by_id(chef_id: str) -> Dict[str, Any]:
    """Get a specific chef by ID."""
    resp = supabase.table("users").select("*").eq("user_id", chef_id).single().execute()
    data = _extract_response_data(resp)
    return data or {}


def get_recipes_by_chef(chef_id: str) -> List[Dict[str, Any]]:
    """Get all recipes created by a specific chef."""
    resp = supabase.table("recipe").select("*").eq("recipe_owner", chef_id).execute()
    data = _extract_response_data(resp)
    return data or []


def get_trending_recipes() -> List[Dict[str, Any]]:
    """Get all recipes marked as trending."""
    resp = supabase.table("recipe").select("*").eq("recipe_is_trending", True).execute()
    data = _extract_response_data(resp)
    return data or []


# -----------------------------
# Follow/Unfollow functionality
# -----------------------------
def check_if_following(follower_id: str, following_id: str) -> bool:
    """Check if follower_id is following following_id."""
    # For now, we'll use a simple approach without a separate follows table
    # In production, you'd want a proper follows table with (follower_id, following_id) pairs
    # This is a placeholder that always returns False
    # TODO: Implement proper follow tracking with a follows table
    return False


def toggle_follow(follower_id: str, chef_id: str) -> Dict[str, Any]:
    """Toggle follow status for a chef."""
    # For now, just increment/decrement the followers count
    # In production, you'd maintain a follows table
    chef = supabase.table("users").select("user_followers_count").eq("user_id", chef_id).single().execute()
    current_count = chef.data.get("user_followers_count", 0) if chef.data else 0
    
    # Check if already following (placeholder - always toggle for now)
    is_following = False  # TODO: Check actual follow status
    
    if is_following:
        # Unfollow
        new_count = max(0, current_count - 1)
    else:
        # Follow
        new_count = current_count + 1
    
    # Update chef's followers count
    resp = supabase.table("users").update({"user_followers_count": new_count}).eq("user_id", chef_id).execute()
    data = _extract_response_data(resp)
    
    # Update follower's following count
    follower = supabase.table("users").select("user_following_count").eq("user_id", follower_id).single().execute()
    follower_count = follower.data.get("user_following_count", 0) if follower.data else 0
    new_follower_count = max(0, follower_count - 1) if is_following else follower_count + 1
    supabase.table("users").update({"user_following_count": new_follower_count}).eq("user_id", follower_id).execute()
    
    return {
        "is_following": not is_following,
        "followers_count": new_count
    }
