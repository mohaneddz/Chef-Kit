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

# Initialize Firebase Admin
try:
    cred_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("Firebase Admin initialized successfully")
    else:
        print("Warning: GOOGLE_APPLICATION_CREDENTIALS not found or invalid. Push notifications will not work.")
except Exception as e:
    print(f"Error initializing Firebase Admin: {e}")


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
_RECIPE_COLUMNS = (
    "recipe_id, recipe_name, recipe_description, recipe_image_url, recipe_owner, "
    "recipe_servings_count, recipe_prep_time, recipe_cook_time, recipe_calories, "
    "recipe_ingredients, recipe_instructions, recipe_tags, recipe_is_trending, "
    "title_ar, title_fr, tags_ar, tags_fr, steps_ar, steps_fr, basic_ingredients"
)

def get_all_recipes(tag: Optional[str] = None) -> List[Dict[str, Any]]:
    query = supabase.table("recipe").select(_RECIPE_COLUMNS)
    if tag:
        query = query.contains("recipe_tags", [tag])
    # Limit to 20 to prevent huge payloads for now
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
                    
                    if notifications:
                        supabase.table("notifications").insert(notifications).execute()
                        print(f"Created {len(notifications)} notifications for new recipe")
                        
                        # Send Push Notifications
                        for n in notifications:
                            _send_push_notification(n)
    except Exception as e:
        print(f"Error creating new recipe notifications: {e}")
        
    return result


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
    # Use admin client to bypass RLS if needed, or ensure RLS allows users to read their own notifications
    client = supabase_admin if supabase_admin else supabase
    resp = client.table("notifications").select("*").eq("user_id", user_id).order("notification_created_at", desc=True).execute()
    data = _extract_response_data(resp)
    return data or []


def update_fcm_token(user_id: str, token: str) -> Dict[str, Any]:
    """Update user's FCM token list."""
    try:
        # Get current devices
        resp = supabase.table("users").select("user_devices").eq("user_id", user_id).single().execute()
        current_data = _extract_response_data(resp)
        
        devices_json = current_data.get("user_devices")
        devices = []
        if devices_json:
            try:
                devices = json.loads(devices_json)
                if not isinstance(devices, list):
                    devices = []
            except:
                devices = []
        
        if token not in devices:
            devices.append(token)
            # Update DB
            supabase.table("users").update({
                "user_devices": json.dumps(devices)
            }).eq("user_id", user_id).execute()
            
        return {"message": "Token updated"}
    except Exception as e:
        print(f"Error updating FCM token: {e}")
        return {"error": str(e)}


def _send_push_notification(data: Dict[str, Any]) -> None:
    print(f"[_send_push_notification] Preparing to send push for user {data.get('user_id')}")
    try:
        user_id = data.get("user_id")
        title = data.get("notification_title")
        body = data.get("notification_message")
        
        if user_id and title and body:
            # Get user tokens
            client = supabase_admin if supabase_admin else supabase
            user_resp = client.table("users").select("user_devices").eq("user_id", user_id).single().execute()
            user_data = _extract_response_data(user_resp)
            devices_json = user_data.get("user_devices")
            
            if devices_json:
                tokens = []
                try:
                    tokens = json.loads(devices_json)
                except:
                    pass
                    
                if tokens and isinstance(tokens, list):
                    print(f"[_send_push_notification] Found {len(tokens)} tokens. Sending...")
                    # Send to all tokens
                    message = messaging.MulticastMessage(
                        notification=messaging.Notification(
                            title=title,
                            body=body,
                        ),
                        data={k: str(v) for k, v in data.get("notification_data", {}).items()},
                        tokens=tokens,
                    )
                    response = messaging.send_multicast(message)
                    print(f"[_send_push_notification] Sent {response.success_count} messages; {response.failure_count} failed.")
                else:
                    print(f"[_send_push_notification] No valid tokens found in list.")
            else:
                print(f"[_send_push_notification] No devices registered for user.")
    except Exception as e:
        print(f"[_send_push_notification] Error sending push notification: {e}")


def create_notification(data: Dict[str, Any]) -> Dict[str, Any]:
    print(f"[create_notification] Attempting to create notification: {data}")
    # Insert into DB using admin client to bypass RLS (since users create notifications for others)
    client = supabase_admin if supabase_admin else supabase
    try:
        resp = client.table("notifications").insert(data).execute()
        result = _extract_response_data(resp)
        print(f"[create_notification] Successfully inserted notification: {result}")
        
        # Send Push Notification
        _send_push_notification(data)

        return result
    except Exception as e:
        print(f"[create_notification] FAILED to insert notification: {e}")
        raise e


def mark_notification_read(notification_id: str) -> Dict[str, Any]:
    # Use admin client to bypass RLS policies that might block updates
    client = supabase_admin if supabase_admin else supabase
    print(f"[mark_notification_read] Marking {notification_id} as read")
    resp = client.table("notifications").update({"notification_is_read": True}).eq("notification_id", notification_id).execute()
    data = _extract_response_data(resp)
    
    if isinstance(data, list) and data:
        print(f"[mark_notification_read] Success: {data[0]}")
        return data[0]
    
    print(f"[mark_notification_read] Warning: No rows updated. Check RLS or ID.")
    return data or {}


def mark_all_notifications_read(user_id: str) -> List[Dict[str, Any]]:
    """Mark all unread notifications for a user as read."""
    client = supabase_admin if supabase_admin else supabase
    print(f"[mark_all_notifications_read] Marking all read for user {user_id}")
    
    # Update all unread notifications for this user
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
            # Unfollow: Delete the follow relationship
            client.table("follows").delete().eq("follower_id", follower_id).eq("following_id", chef_id).execute()
            print(f"User {follower_id} unfollowed chef {chef_id}")
        else:
            # Follow: Insert a new follow relationship
            client.table("follows").insert({
                "follower_id": follower_id,
                "following_id": chef_id
            }).execute()
            print(f"User {follower_id} followed chef {chef_id}")
            
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
        print(f"Error toggling follow: {e}")
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
        # Use admin client if available to bypass RLS, otherwise use standard client
        client = supabase_admin if supabase_admin else supabase
        
        print(f"[toggle_user_favorite] Toggling {recipe_id} for user {user_id}")
        
        user_resp = client.table("users").select("user_favourite_recipees").eq("user_id", user_id).single().execute()
        user_data = _extract_response_data(user_resp)
        
        # Handle potential None or non-list values
        fav_ids = user_data.get("user_favourite_recipees")
        if fav_ids is None:
            fav_ids = []
        elif not isinstance(fav_ids, list):
            # If it's not a list, it might be a string representation or something else
            print(f"[toggle_user_favorite] Warning: user_favourite_recipees is not a list: {type(fav_ids)}")
            fav_ids = []
            
        print(f"[toggle_user_favorite] Current favorites: {fav_ids}")
        
        is_fav = recipe_id in fav_ids
        
        if is_fav:
            fav_ids.remove(recipe_id)
            print(f"[toggle_user_favorite] Removing {recipe_id}")
        else:
            fav_ids.append(recipe_id)
            print(f"[toggle_user_favorite] Adding {recipe_id}")
            
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
        
        print(f"[toggle_user_favorite] Update successful")
        return not is_fav
    except Exception as e:
        print(f"[toggle_user_favorite] Error: {e}")
        import traceback
        traceback.print_exc()
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
