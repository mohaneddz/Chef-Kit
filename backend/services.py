"""Service layer for Chef-Kit backend.

Contains functions that wrap Supabase client operations.
Keeping database logic here makes `app.py` simple and easy to test.
"""
from typing import Any, Dict, List, Optional
import os
import json
import firebase_admin
from firebase_admin import credentials, messaging
from supabase_client import supabase, supabase_admin
from supabase_client import set_postgrest_token

# Firebase Admin initialization (tries: env JSON -> env path -> local file)
try:
    firebase_initialized = False
    
    firebase_json = os.getenv('FIREBASE_CREDENTIALS_JSON')
    if firebase_json:
        import json as _json
        cred_dict = _json.loads(firebase_json)
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)
        firebase_initialized = True
    
    if not firebase_initialized:
        cred_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
    
    if not firebase_initialized:
        local_key = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
        if os.path.exists(local_key):
            cred = credentials.Certificate(local_key)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
    
    if not firebase_initialized:
        print("Warning: No Firebase credentials found. Push notifications disabled.")
except Exception as e:
    print(f"Firebase init error: {e}")


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
    
    try:
        existing = supabase.table("users").select("user_email").eq("user_email", email).execute()
        if existing.data and len(existing.data) > 0:
            raise ValueError("email_exists: User with this email already exists")
    except ValueError:
        raise
    except Exception:
        pass
    
    try:
        resp = supabase.auth.sign_up({"email": email, "password": password})
        if resp and hasattr(resp, 'user') and resp.user:
            user_data = resp.user
            user_id = getattr(user_data, 'id', None)
            
            if hasattr(user_data, 'email_confirmed_at') and user_data.email_confirmed_at:
                raise ValueError("email_exists: User already registered and verified")
            
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
                except Exception:
                    pass
    except ValueError:
        raise
    except Exception as e:
        msg = str(e)
        if "already registered" in msg or "User already exists" in msg:
            raise ValueError(f"email_exists: {e}")
        raise RuntimeError(f"signup_failed: {e}")
    # Return a simple JSON-serializable response
    return {"message": "signup_ok"}


def auth_login(email: str, password: str, device_token: Optional[str] = None) -> Dict[str, Any]:
    """Login via Supabase Auth (password).
    
    Args:
        email: User's email
        password: User's password
        device_token: Optional FCM device token for push notifications
    """

    
    
    user_id = None 
    access_token = None
    refresh_token = None
    
    try:
        session = supabase.auth.sign_in_with_password({"email": email, "password": password})
    except Exception as e:
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
        raise RuntimeError(f"login_failed: {e}")
    
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
    except Exception as e:
        user_payload = {"email": email}
    
    # Store device token for push notifications
    if device_token and user_id:
        try:
            update_fcm_token(user_id, device_token)
        except Exception:
            pass
    
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

            return resp.data
    except Exception:
        pass
    
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
        resp = supabase.table("users").insert(minimal_profile).execute()
        if resp.data and len(resp.data) > 0:
            return resp.data[0]
        return minimal_profile
    except Exception as e:
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
_RECIPE_COLUMNS = (
    "recipe_id, recipe_name, recipe_description, recipe_image_url, recipe_owner, "
    "recipe_servings_count, recipe_prep_time, recipe_cook_time, recipe_calories, "
    "recipe_ingredients, recipe_instructions, recipe_tags, recipe_is_trending, recipe_is_seasonal, title_ar, title_fr, tags_ar, tags_fr, steps_ar, steps_fr, basic_ingredients"
)

def get_all_recipes(tag: Optional[str] = None) -> List[Dict[str, Any]]:
    query = supabase.table("recipe").select(_RECIPE_COLUMNS)
    if tag:
        query = query.contains("recipe_tags", [tag])
    # Limit to 100 to show more recipes
    resp = query.limit(100).execute()
    data = _extract_response_data(resp)
    return data or []


def get_seasonal_recipes() -> List[Dict[str, Any]]:
    """
    Get all recipes marked as seasonal.
    """
    query = supabase.table("recipe").select(_RECIPE_COLUMNS).eq("recipe_is_seasonal", True)
    # Limit to 20 for now
    resp = query.limit(20).execute()
    data = _extract_response_data(resp)
    return data or []


def get_recipes_result(ingredients: List[str] = None) -> List[Dict[str, Any]]:
    """
    Get a fixed list of 10 recipes for the results page.
    TODO: Implement actual logic for recipe results based on ingredients/preferences.
    """
    resp = supabase.table("recipe").select(_RECIPE_COLUMNS).limit(10).execute()
    data = _extract_response_data(resp)
    return data or []


def get_recipe(recipe_id: str) -> Dict[str, Any]:
    resp = supabase.table("recipe").select("*").eq("recipe_id", recipe_id).single().execute()
    data = _extract_response_data(resp)
    return data or {}


def create_recipe(data: Dict[str, Any]) -> Dict[str, Any]:
    resp = supabase.table("recipe").insert(data).execute()
    result = _extract_response_data(resp)
    
    # Notify followers
    try:
        if isinstance(result, list) and result:
            recipe_data = result[0]
        elif isinstance(result, dict):
            recipe_data = result
        else:
            recipe_data = {}

        if recipe_data:
            owner_id = recipe_data.get('recipe_owner')
            recipe_id = recipe_data.get('recipe_id')
            recipe_name = recipe_data.get('recipe_name')
            
            if owner_id:
                # Get followers
                followers_resp = supabase.table("follows").select("follower_id").eq("following_id", owner_id).execute()
                followers = _extract_response_data(followers_resp)
                
                if followers:
                    notifications = []
                    for f in followers:
                        notifications.append({
                            "user_id": f['follower_id'],
                            "notification_title": "New Recipe",
                            "notification_type": "new_recipe",
                            "notification_message": f"Chef you follow posted: {recipe_name}",
                            "notification_data": {"recipe_id": recipe_id, "chef_id": owner_id}
                        })
                    
                        supabase.table("notifications").insert(notifications).execute()
                        
                        # Send Push Notifications
                        for n in notifications:
                            _send_push_notification(n)
    except Exception as e:
        print(f"Error creating new recipe notifications: {e}")
        
    return result


def update_recipe(recipe_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    # Execute update
    resp = supabase.table("recipe").update(data).eq("recipe_id", recipe_id).execute()
    result = _extract_response_data(resp)
    
    # If empty response (due to RLS), fetch the updated record
    if not result or (isinstance(result, list) and len(result) == 0):
        fetch_resp = supabase.table("recipe").select("*").eq("recipe_id", recipe_id).single().execute()
        result = _extract_response_data(fetch_resp)
    
    if isinstance(result, list) and result:
        return result[0]
    elif isinstance(result, dict):
        return result
    
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
    # Use admin client to bypass RLS if needed, or ensure RLS allows users to read their own notifications
    client = supabase_admin if supabase_admin else supabase
    resp = client.table("notifications").select("*").eq("user_id", user_id).order("notification_created_at", desc=True).execute()
    data = _extract_response_data(resp)
    return data or []


def update_fcm_token(user_id: str, token: str) -> Dict[str, Any]:
    """Update user's FCM token list."""
    client = supabase_admin if supabase_admin else supabase
    
    try:
        resp = client.table("users").select("user_devices").eq("user_id", user_id).single().execute()
        current_data = _extract_response_data(resp)
        
        devices_raw = current_data.get("user_devices")
        devices = []
        
        if devices_raw:
            if isinstance(devices_raw, list):
                devices = devices_raw
            elif isinstance(devices_raw, str):
                try:
                    devices = json.loads(devices_raw)
                    if not isinstance(devices, list):
                        devices = []
                except:
                    devices = []
        
        if token not in devices:
            devices.append(token)
            client.table("users").update({
                "user_devices": json.dumps(devices)
            }).eq("user_id", user_id).execute()
            return {"message": "Token added", "total_devices": len(devices)}
        else:
            return {"message": "Token already registered", "total_devices": len(devices)}
            
    except Exception as e:
        return {"error": str(e)}


def _send_push_notification(data: Dict[str, Any]) -> None:
    """Send FCM push notification to user's devices."""
    try:
        user_id = data.get("user_id")
        title = data.get("notification_title")
        body = data.get("notification_message")
        
        if not (user_id and title and body):
            return
            
        client = supabase_admin if supabase_admin else supabase
        user_resp = client.table("users").select("user_devices").eq("user_id", user_id).single().execute()
        user_data = _extract_response_data(user_resp)
        devices_json = user_data.get("user_devices")
        
        if not devices_json:
            return
            
        tokens = []
        try:
            tokens = json.loads(devices_json)
        except:
            pass
            
        if not tokens or not isinstance(tokens, list):
            return
        
        # Build FCM data payload
        fcm_data = {k: str(v) for k, v in data.get("notification_data", {}).items()}
        if data.get("notification_type"):
            fcm_data["notification_type"] = str(data.get("notification_type"))
        
        for token in tokens:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(title=title, body=body),
                    data=fcm_data,
                    token=token,
                    android=messaging.AndroidConfig(
                        priority="high",
                        notification=messaging.AndroidNotification(
                            channel_id="chef_kit_notifications",
                            priority="high",
                        ),
                    ),
                    apns=messaging.APNSConfig(
                        headers={"apns-priority": "10"},
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(content_available=True),
                        ),
                    ),
                )
                messaging.send(message)
            except Exception:
                pass
    except Exception:
        pass


def create_notification(data: Dict[str, Any]) -> Dict[str, Any]:
    """Create notification and send push."""
    client = supabase_admin if supabase_admin else supabase
    
    try:
        resp = client.table("notifications").insert(data).execute()
        result = _extract_response_data(resp)
        _send_push_notification(data)
        return result
    except Exception as e:
        raise e


def mark_notification_read(notification_id: str) -> Dict[str, Any]:
    """Mark a notification as read."""
    client = supabase_admin if supabase_admin else supabase
    resp = client.table("notifications").update({"notification_is_read": True}).eq("notification_id", notification_id).execute()
    data = _extract_response_data(resp)
    
    if isinstance(data, list) and data:
        return data[0]
    return data or {}


def mark_all_notifications_read(user_id: str) -> List[Dict[str, Any]]:
    """Mark all unread notifications for a user as read."""
    client = supabase_admin if supabase_admin else supabase
    resp = client.table("notifications").update({"notification_is_read": True})\
        .eq("user_id", user_id)\
        .eq("notification_is_read", False)\
        .execute()
    data = _extract_response_data(resp)
    return data or []


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
    resp = supabase.table("recipe").select(_RECIPE_COLUMNS).eq("recipe_is_trending", True).limit(10).execute()
    data = _extract_response_data(resp)
    return data or []


# -----------------------------
# Follow/Unfollow functionality
# -----------------------------
def check_if_following(follower_id: str, following_id: str) -> bool:
    """Check if follower_id is following following_id."""
    try:
        client = supabase_admin if supabase_admin else supabase
        resp = client.table("follows").select("id").eq("follower_id", follower_id).eq("following_id", following_id).execute()
        data = _extract_response_data(resp)
        return len(data) > 0 if data else False
    except Exception as e:
        print(f"Error checking follow status: {e}")
        return False


def toggle_follow(follower_id: str, chef_id: str) -> Dict[str, Any]:
    """Toggle follow status for a chef.
    
    Uses the follows table to track relationships.
    Counts are automatically updated by database triggers.
    """
    # Check if already following
    is_following = check_if_following(follower_id, chef_id)
    
    # Use admin client to bypass RLS for reliable toggling
    client = supabase_admin if supabase_admin else supabase

    try:
        if is_following:
            client.table("follows").delete().eq("follower_id", follower_id).eq("following_id", chef_id).execute()
        else:
            client.table("follows").insert({
                "follower_id": follower_id,
                "following_id": chef_id
            }).execute()
            
            # Create notification for the chef
            try:
                follower = get_user(follower_id)
                follower_name = follower.get('user_full_name', 'Someone') if follower else 'Someone'
                
                create_notification({
                    "user_id": chef_id,
                    "notification_title": "New Follower",
                    "notification_type": "follow",
                    "notification_message": f"{follower_name} started following you.",
                    "notification_data": {"follower_id": follower_id}
                })
            except Exception as e:
                print(f"Error creating follow notification: {e}")
        
        # Get updated follower count for the chef (trigger should have updated it)
        chef_resp = client.table("users").select("user_followers_count").eq("user_id", chef_id).single().execute()
        new_count = chef_resp.data.get("user_followers_count", 0) if chef_resp.data else 0
        
        return {
            "is_following": not is_following,
            "followers_count": new_count
        }
    except Exception as e:
        raise Exception(f"Failed to toggle follow status: {str(e)}")


def get_user_favorites(user_id: str) -> List[Dict[str, Any]]:
    """Get all favorite recipes for a user."""
    try:
        client = supabase_admin if supabase_admin else supabase
        # First get the list of favorite IDs
        user_resp = client.table("users").select("user_favourite_recipees").eq("user_id", user_id).single().execute()
        user_data = _extract_response_data(user_resp)
        
        fav_ids = user_data.get("user_favourite_recipees") or []
        if not fav_ids:
            return []
            
        # Then fetch the recipes
        recipes_resp = client.table("recipe").select("*").in_("recipe_id", fav_ids).execute()
        recipes = _extract_response_data(recipes_resp)
        
        # Mark them as favorites
        for r in recipes:
            r["isFavorite"] = True
            
        return recipes
    except Exception as e:
        print(f"Error fetching favorites: {e}")
        return []


def toggle_user_favorite(user_id: str, recipe_id: str) -> bool:
    """Toggle a recipe in user's favorites. Returns True if added, False if removed."""
    try:
        client = supabase_admin if supabase_admin else supabase
        
        user_resp = client.table("users").select("user_favourite_recipees").eq("user_id", user_id).single().execute()
        user_data = _extract_response_data(user_resp)
        
        fav_ids = user_data.get("user_favourite_recipees")
        if fav_ids is None:
            fav_ids = []
        elif not isinstance(fav_ids, list):
            fav_ids = []
            
        is_fav = recipe_id in fav_ids
        
        if is_fav:
            fav_ids.remove(recipe_id)
        else:
            fav_ids.append(recipe_id)
            
            # Create notification for the recipe owner
            try:
                recipe = get_recipe(recipe_id)
                owner_id = recipe.get('recipe_owner')
                if owner_id and owner_id != user_id: # Don't notify self
                    user = get_user(user_id)
                    user_name = user.get('user_full_name', 'Someone') if user else 'Someone'
                    recipe_name = recipe.get('recipe_name', 'your recipe')
                    
                    create_notification({
                        "user_id": owner_id,
                        "notification_title": "Recipe Liked",
                        "notification_type": "like",
                        "notification_message": f"{user_name} liked your recipe {recipe_name}.",
                        "notification_data": {"recipe_id": recipe_id, "user_id": user_id}
                    })
            except Exception as e:
                print(f"Error creating like notification: {e}")
            
        update_resp = client.table("users").update({"user_favourite_recipees": fav_ids}).eq("user_id", user_id).execute()
        _extract_response_data(update_resp)
        return not is_fav
    except Exception as e:
        raise e


def get_user_favorite_ids(user_id: str) -> List[str]:
    """Get just the IDs of favorite recipes."""
    try:
        client = supabase_admin if supabase_admin else supabase
        user_resp = client.table("users").select("user_favourite_recipees").eq("user_id", user_id).single().execute()
        user_data = _extract_response_data(user_resp)
        return user_data.get("user_favourite_recipees") or []
    except Exception:
        return []


def generate_recipes(lang: str, max_time: str, ingredients: List[str]) -> Dict[str, Any]:
    """
    Placeholder function for recipe generation.
    Returns mock data based on the provided format.
    """
    # In a real implementation, this would use the inputs to filter/generate recipes.
    # For now, we return the static mock data as requested.
    
    return {
      "recipes": [
        {
          "recipe_id": "2255040a-c9d0-421a-afc8-0af33dd96a4e",
          "recipe_owner": "3366050b-d0e1-432b-bgd9-1bf44ee07b5f",
          "recipe_name": "Apple Funnel Cake",
          "recipe_description": "Applesauce in the batter makes these apple funnel cakes extra tender. To keep the oil from splashing when frying funnel cakes, be sure to hold the tip of the funnel close to the oil.",
          "recipe_image_url": "https://tse2.mm.bing.net/th/id/OIP.uwtaMHs561s9UzW9aCtT1wHaFj?cb=ucfimg2&pid=Api&ucfimg=1",
          "recipe_servings_count": 4,
          "recipe_prep_time": 27,
          "recipe_cook_time": 63,
          "recipe_calories": 320,
          "recipe_ingredients": [
            "2 1/2 cups all-purpose flour",
            "2 teaspoons baking powder",
            "1 teaspoon apple pie spice",
            "1/2 teaspoon salt",
            "1 3/4 cups milk",
            "1 cup applesauce",
            "3 large eggs",
            "1/4 cup white sugar",
            "1/4 teaspoon almond extract"
          ],
          "recipe_items": [],
          "recipe_instructions": [
            "Stir together flour, baking powder, apple pie spice, and salt.",
            "Whisk together milk, applesauce, eggs, sugar, and almond extract. Add flour mixture.",
            "Cook apple topping with butter, apples, brown sugar, and spice.",
            "Heat oil to 375°F (190°C).",
            "Fry batter in circular motion until golden.",
            "Top with apple mixture and serve."
          ],
          "recipe_tags": [
            "French",
            "American",
            "Vegetarian",
            "Kosher",
            "Medium"
          ],
          "recipe_external_source": [
            "https://www.allrecipes.com/recipe/apple-funnel-cake"
          ],
          "recipe_is_trending": True,
          "title_ar": "كعكة قمع التفاح",
          "title_fr": "Gâteau Entonnoir aux Pommes",
          "tags_ar": [
            "فرنسي",
            "أمريكي",
            "نباتي",
            "كوشير",
            "متوسط"
          ],
          "tags_fr": [
            "Français",
            "Américain",
            "Végétarien",
            "Casher",
            "Moyen"
          ],
          "steps_ar": [
            "اخلطي الدقيق مع البيكنج بودر وتوابل فطيرة التفاح والملح.",
            "اخفقي الحليب وعصير التفاح والبيض والسكر ومستخلص اللوز معًا. أضيفي خليط الدقيق.",
            "اطهي طبقة التفاح مع الزبدة والتفاح والسكر البني والتوابل.",
            "سخني الزيت إلى 375 درجة فهرنهايت (190 درجة مئوية).",
            "اقلي العجين بحركة دائرية حتى يصبح ذهبي اللون.",
            "ضعي خليط التفاح فوقها وقدميها."
          ],
          "steps_fr": [
            "Mélanger la farine, la levure chimique, les épices pour tarte aux pommes et le sel.",
            "Fouetter ensemble le lait, la compote de pommes, les œufs, le sucre et l'extrait d'amande. Ajouter le mélange de farine.",
            "Cuire la garniture aux pommes avec le beurre, les pommes, la cassonade et les épices.",
            "Chauffer l'huile à 190°C (375°F).",
            "Frire la pâte en mouvement circulaire jusqu'à ce qu'elle soit dorée.",
            "Garnir du mélange de pommes et servir."
          ],
          "basic_ingredients": "Flour, Applesauce, Milk, Eggs, Sugar",
          "recipe_is_seasonal": True
        },
        {
          "recipe_id": "550e8400-e29b-41d4-a716-446655440000",
          "recipe_owner": "8899050b-a1c2-432b-bgd9-2cf55ee08c6g",
          "recipe_name": "Healthy Green Smoothie Bowl",
          "recipe_description": "A refreshing and nutrient-packed smoothie bowl topped with fresh fruits, seeds, and granola. Perfect for a quick breakfast or post-workout meal.",
          "recipe_image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80",
          "recipe_servings_count": 2,
          "recipe_prep_time": 10,
          "recipe_cook_time": 0,
          "recipe_calories": 450,
          "recipe_ingredients": [
            "2 cups fresh spinach",
            "1 frozen banana",
            "1/2 cup frozen mango chunks",
            "1/2 cup almond milk",
            "1 kiwi, sliced",
            "1 tbsp chia seeds",
            "1/4 cup granola"
          ],
          "recipe_items": [],
          "recipe_instructions": [
            "Combine spinach, banana, mango, and almond milk in a blender.",
            "Blend on high speed until smooth and creamy.",
            "Pour into bowls.",
            "Top with sliced kiwi, chia seeds, and granola immediately before serving."
          ],
          "recipe_tags": [
            "Healthy",
            "Vegan",
            "Breakfast",
            "Gluten-Free",
            "Easy"
          ],
          "recipe_external_source": [],
          "recipe_is_trending": False,
          "title_ar": "وعاء السموذي الأخضر الصحي",
          "title_fr": "Bol de Smoothie Vert Sain",
          "tags_ar": [
            "صحي",
            "نباتي صرف",
            "فطور",
            "خالي من الجلوتين",
            "سهل"
          ],
          "tags_fr": [
            "Sain",
            "Végétalien",
            "Petit-déjeuner",
            "Sans Gluten",
            "Facile"
          ],
          "steps_ar": [
            "اخلطي السبانخ والموز والمانجو وحليب اللوز في الخلاط.",
            "اخلطي بسرعة عالية حتى يصبح الخليط ناعماً وكريمياً.",
            "اسكبي الخليط في أوعية.",
            "زيّني بشرائح الكيوي وبذور الشيا والجرانولا قبل التقديم مباشرة."
          ],
          "steps_fr": [
            "Combiner les épinards, la banane, la mangue et le lait d'amande dans un mélangeur.",
            "Mélanger à haute vitesse jusqu'à consistance lisse et crémeuse.",
            "Verser dans des bols.",
            "Garnir de tranches de kiwi, de graines de chia et de granola juste avant de servir."
          ],
          "basic_ingredients": "Spinach, Banana, Mango, Almond Milk",
          "recipe_is_seasonal": False
        }
      ]
    }


# -----------------------------
# Scheduled Notifications
# -----------------------------
def send_scheduled_recipe_notification():
    """Send daily trending recipe notification to all users with devices."""
    try:
        trending = get_trending_recipes()
        if not trending:
            return {"success": False, "reason": "No trending recipes"}
        
        recipe = trending[0]
        recipe_id = recipe.get("recipe_id")
        
        client = supabase_admin if supabase_admin else supabase
        users_resp = client.table("users").select("user_id, user_devices, user_full_name").not_.is_("user_devices", "null").execute()
        users = _extract_response_data(users_resp) or []
        
        notifications_sent = 0
        for user in users:
            user_id = user.get("user_id")
            devices = user.get("user_devices")
            
            if not devices:
                continue
                
            if isinstance(devices, str):
                try:
                    devices = json.loads(devices)
                except:
                    continue
            
            if not devices or not isinstance(devices, list) or len(devices) == 0:
                continue
            
            try:
                create_notification({
                    "user_id": user_id,
                    "notification_title": "Check the Hot Recipes 🔥",
                    "notification_type": "hot_recipes",
                    "notification_message": "Discover today's trending and most popular recipes!",
                    "notification_data": {}
                })
                notifications_sent += 1
            except Exception:
                pass
        
        return {"success": True, "notifications_sent": notifications_sent}
        
    except Exception as e:
        return {"success": False, "error": str(e)}

