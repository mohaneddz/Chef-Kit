"""
Chef-Kit Backend API
Flask server for Chef-Kit Flutter app.
Uses Supabase (Postgres) as the data store.
Endpoints wired to DB_SCHEMA.md tables.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from services import (
    get_all_users,
    get_user as service_get_user,
    create_user as service_create_user,
    update_user as service_update_user,
    get_all_recipes,
    get_recipes_result,
    get_recipe,
    create_recipe,
    update_recipe,
    delete_recipe,
    get_all_ingredients,
    get_ingredient,
    create_ingredient,
    get_notifications_for_user,
    create_notification,
    mark_notification_read,
    mark_all_notifications_read,
    auth_signup,
    auth_login,
    auth_refresh,
    auth_logout,
    auth_verify_email_otp,
    update_user_service,
    get_chefs_on_fire,
    get_chef_by_id,
    get_recipes_by_chef,
    get_trending_recipes,
    toggle_follow,
    get_user_favorites,
    toggle_user_favorite,
    get_user_favorite_ids,
    update_fcm_token,
)
from auth import token_required, optional_token
from supabase_client import set_postgrest_token
from supabase_client import (
    supabase,
    supabase_admin,
    SUPABASE_URL,
    SUPABASE_ANON_KEY,
    SUPABASE_SERVICE_ROLE_KEY,
)
import traceback
import time
import hashlib
import requests
import re
from cloudinary_utils import get_cloudinary_config
from cooking import generate_cooking_instructions
from typing import Any, Dict

_SUPABASE_PASSWORD_RESET_REDIRECT = os.getenv("SUPABASE_PASSWORD_RESET_REDIRECT")

# Simple in-memory throttle store for resend limits (per email)
_last_resend_ts = {}
_pending_email_changes: Dict[str, Dict[str, Any]] = {}
_pending_password_changes: Dict[str, Dict[str, Any]] = {}

_EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
_OTP_TTL_SECONDS = 600  # 10 minutes
_MAX_OTP_ATTEMPTS = 5


def _require_service_key() -> None:
    if not SUPABASE_SERVICE_ROLE_KEY:
        raise RuntimeError("Supabase service role key is required for this operation")


def _admin_headers() -> dict[str, str]:
    _require_service_key()
    return {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
        "Content-Type": "application/json",
    }


def _anon_headers() -> dict[str, str]:
    api_key = SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY
    if not api_key:
        raise RuntimeError("Supabase anonymous key is not configured")
    return {
        "apikey": api_key,
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }


def _user_headers(access_token: str) -> dict[str, str]:
    api_key = SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY
    if not api_key:
        raise RuntimeError("Supabase anonymous key is not configured")
    return {
        "apikey": api_key,
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }


def _auth_email_exists(email: str) -> bool:
    """Check if email exists in public.users table (simpler than auth lookup)."""
    try:
        result = supabase.table("users").select("user_id").eq("user_email", email).limit(1).execute()
        return bool(getattr(result, "data", None))
    except Exception:
        return False


def _verify_current_password(email: str, password: str) -> bool:
    try:
        resp = requests.post(
            f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
            headers={
                "apikey": SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY,
                "Content-Type": "application/json",
            },
            json={"email": email, "password": password},
            timeout=10,
        )
    except requests.RequestException as exc:
        raise RuntimeError(f"Password verification failed: {exc}")

    if resp.status_code == 200:
        return True
    if resp.status_code in (400, 401):
        return False
    raise RuntimeError(f"Password verification unexpected error: {resp.status_code} {resp.text}")

app = Flask(__name__)
CORS(app)
# Auth
@app.route("/auth/signup", methods=["POST"])
def signup():
    try:
        payload = request.get_json() or {}
        email = payload.get("email")
        password = payload.get("password")
        full_name = payload.get("full_name")
        if not email or not password:
            return jsonify({"error": "email and password are required"}), 400
        result = auth_signup(email, password, full_name)
        return jsonify(result), 200
    except ValueError as e:
        # Email already exists
        msg = str(e)
        if "email_exists" in msg:
            return jsonify({"error": "email_exists"}), 409
        return jsonify({"error": msg}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/auth/login", methods=["POST"])
def login():
    try:
        payload = request.get_json() or {}
        email = payload.get("email")
        password = payload.get("password")
        if not email or not password:
            return jsonify({"error": "email and password are required"}), 400
        result = auth_login(email, password)
        return jsonify(result), 200
    except Exception as e:
        status = 401
        msg = str(e)
        if isinstance(e, PermissionError) or ("unverified_email" in msg):
            status = 403
            msg = "unverified_email"
        return jsonify({"error": msg}), status


@app.route("/auth/refresh", methods=["POST"])
def refresh():
    try:
        payload = request.get_json() or {}
        refresh_token = payload.get("refresh_token")
        if not refresh_token:
            return jsonify({"error": "refresh_token is required"}), 400
        result = auth_refresh(refresh_token)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 401


@app.route("/auth/logout", methods=["POST"])
@token_required
def logout(token_claims, token=None):
    try:
        auth_logout()
        return jsonify({"message": "signed out"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# OTP verification
@app.route("/auth/verify", methods=["POST"])
def verify():
    try:
        payload = request.get_json() or {}
        email = payload.get("email")
        token = payload.get("token")
        if not email or not token:
            return jsonify({"error": "email and token are required"}), 400
        result = auth_verify_email_otp(email, token)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/auth/resend", methods=["POST"])
def resend():
    """Resend OTP with a throttle (min interval 60 seconds per email)."""
    try:
        payload = request.get_json() or {}
        email = payload.get("email")
        if not email:
            return jsonify({"error": "email is required"}), 400
        now = time.time()
        last = _last_resend_ts.get(email, 0)
        min_interval = 60  # seconds; adjust to 120 for 2 minutes
        remain = int(min_interval - (now - last))
        if remain > 0:
            return jsonify({"error": "throttled", "retry_after": remain}), 429
        
        # Trigger Supabase resend for email confirmation
        try:
            # Use resend with proper type for email confirmation
            result = supabase.auth.resend({"type": "signup", "email": email})
            _last_resend_ts[email] = now
            return jsonify({"message": "resent", "email": email}), 200
        except Exception as resend_err:
            return jsonify({"error": f"Failed to resend: {str(resend_err)}"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Security endpoints
@app.route("/auth/email/change/request", methods=["POST"])
@token_required
def request_email_change(token_claims, token):
    """Send OTP to new email address for email change."""
    try:
        payload = request.get_json() or {}
        new_email = (payload.get("new_email") or "").strip().lower()
        if not new_email:
            return jsonify({"error": "Please enter a new email address."}), 400
        if not _EMAIL_REGEX.match(new_email):
            return jsonify({"error": "Please enter a valid email address."}), 400

        user_claims = token_claims.get("user") or {}
        current_email = (user_claims.get("email") or "").strip().lower()
        if not current_email:
            return jsonify({"error": "Unable to retrieve current email. Please log in again."}), 400
        if current_email == new_email:
            return jsonify({"error": "New email is the same as current email."}), 400
        if not token:
            return jsonify({"error": "Authentication required. Please log in again."}), 401

        # Check if new email already exists
        if _auth_email_exists(new_email):
            return jsonify({"error": "This email is already in use by another account."}), 409

        # Use admin client with user's token to trigger email change
        try:
            # Set user's access token for the request
            set_postgrest_token(token)
            
            # Make REST API call with user's token
            headers = _user_headers(token)
            update_resp = requests.put(
                f"{SUPABASE_URL}/auth/v1/user",
                headers=headers,
                json={"email": new_email}
            )
            
            if update_resp.status_code not in (200, 204):
                error_data = update_resp.json() if update_resp.text else {}
                error_msg = error_data.get("msg") or error_data.get("message") or str(error_data)
                
                # Handle rate limiting
                if update_resp.status_code == 429:
                    return jsonify({"error": "Too many requests. Please wait a moment before trying again."}), 429
                
                raise RuntimeError(error_msg)
        except Exception as exc:
            error_str = str(exc)
            if "rate_limit" in error_str.lower() or "429" in error_str:
                return jsonify({"error": "Too many email change requests. Please wait before trying again."}), 429
            return jsonify({"error": f"Failed to send verification code. Please try again."}), 400

        user_id = token_claims.get("sub")
        if not user_id:
            return jsonify({"error": "user_not_found"}), 400

        _pending_email_changes[user_id] = {
            "new_email": new_email,
            "current_email": current_email,
            "requested_at": time.time(),
            "expires_at": time.time() + _OTP_TTL_SECONDS,
            "attempts": 0,
        }

        return jsonify({"message": "email_change_otp_sent"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/auth/email/change/verify", methods=["POST"])
@token_required
def verify_email_change(token_claims, token):
    """Verify OTP and confirm new email address."""
    try:
        payload = request.get_json() or {}
        otp = (payload.get("otp") or "").strip()
        new_email = (payload.get("new_email") or "").strip().lower()

        if not otp or not new_email:
            return jsonify({"error": "Please enter both verification code and email address."}), 400
        if not _EMAIL_REGEX.match(new_email):
            return jsonify({"error": "Please enter a valid email address."}), 400

        user_id = token_claims.get("sub")
        pending = _pending_email_changes.get(user_id)
        if not pending:
            return jsonify({"error": "No pending email change request. Please request a new code."}), 400

        if time.time() > pending.get("expires_at", 0):
            _pending_email_changes.pop(user_id, None)
            return jsonify({"error": "Verification code expired. Please request a new one."}), 410

        if pending.get("new_email") != new_email:
            return jsonify({"error": "Email address doesn't match. Please check and try again."}), 400

        attempts = int(pending.get("attempts", 0))
        if attempts >= _MAX_OTP_ATTEMPTS:
            _pending_email_changes.pop(user_id, None)
            return jsonify({"error": "Too many failed attempts. Please request a new code."}), 429

        # Verify OTP code for email change
        # Supabase sends a 6-digit OTP to the new email address
        try:
            verify_resp = requests.post(
                f"{SUPABASE_URL}/auth/v1/verify",
                headers=_anon_headers(),
                json={
                    "type": "email_change",
                    "email": new_email,
                    "token": otp
                }
            )
            
            if verify_resp.status_code != 200:
                error_data = verify_resp.json() if verify_resp.text else {}
                error_msg = error_data.get("msg") or error_data.get("message") or str(error_data)
                raise RuntimeError(f"Verification failed: {error_msg}")
            
            resp_data = verify_resp.json()
        except Exception as exc:
            pending["attempts"] = attempts + 1
            if pending["attempts"] >= _MAX_OTP_ATTEMPTS:
                _pending_email_changes.pop(user_id, None)
            return jsonify({"error": f"otp_verification_failed: {exc}"}), 400

        # CRITICAL: Update email in Supabase Auth using Admin API
        # This is the ONLY way to actually change the email in auth.users table
        try:
            admin_update_resp = requests.put(
                f"{SUPABASE_URL}/auth/v1/admin/users/{user_id}",
                headers=_admin_headers(),
                json={"email": new_email, "email_confirm": True}
            )
            
            if admin_update_resp.status_code not in (200, 204):
                error_data = admin_update_resp.json() if admin_update_resp.text else {}
                raise RuntimeError(f"Auth update failed: {error_data}")
        except Exception as exc:
            return jsonify({"error": f"auth_email_update_failed: {exc}"}), 500

        # Update profile table with new email
        client = supabase_admin or supabase
        try:
            update_resp = client.table("users").update({"user_email": new_email}).eq("user_id", user_id).execute()
            if not getattr(update_resp, "data", None):
                raise RuntimeError("profile_update_failed")
        except Exception as exc:
            return jsonify({"error": f"profile_update_failed: {exc}"}), 500

        _pending_email_changes.pop(user_id, None)
        
        # Extract complete session and user data from REST response
        user_data = resp_data.get("user", {})
        session_data = {
            "access_token": resp_data.get("access_token"),
            "refresh_token": resp_data.get("refresh_token"),
        }
        
        # CRITICAL: Force the email to be the new_email in the response
        # This ensures Flutter app gets the updated email for state management
        user_data["email"] = new_email
        
        # Ensure all required fields are present
        if not user_data.get("id"):
            user_data["id"] = user_id
        if not user_data.get("aud"):
            user_data["aud"] = "authenticated"
        if "app_metadata" not in user_data:
            user_data["app_metadata"] = {}
        if "user_metadata" not in user_data:
            user_data["user_metadata"] = {}
        if "created_at" not in user_data:
            user_data["created_at"] = None
        
        return jsonify({
            "message": "email_updated", 
            "session": session_data, 
            "user": user_data,
            "new_email": new_email  # Extra field for explicit clarity
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/auth/password/change/request", methods=["POST"])
@token_required
def request_password_change(token_claims, token):
    """Send password reset OTP to user's email."""
    try:
        payload = request.get_json() or {}
        current_password = (payload.get("current_password") or "").strip()
        new_password = (payload.get("new_password") or "").strip()

        if not current_password or not new_password:
            return jsonify({"error": "Please enter both current and new password."}), 400
        if len(new_password) < 8:
            return jsonify({"error": "Password must be at least 8 characters long."}), 400
        if current_password == new_password:
            return jsonify({"error": "New password must be different from current password."}), 400

        user_claims = token_claims.get("user") or {}
        email = (user_claims.get("email") or "").strip().lower()
        if not email:
            return jsonify({"error": "current_email_unavailable"}), 400

        # Verify current password
        valid_password = _verify_current_password(email, current_password)
        if not valid_password:
            return jsonify({"error": "Current password is incorrect."}), 403

        # Send password reset OTP using REST API
        try:
            payload_json = {"email": email}
            if _SUPABASE_PASSWORD_RESET_REDIRECT:
                payload_json["options"] = {"redirect_to": _SUPABASE_PASSWORD_RESET_REDIRECT}
            
            reset_resp = requests.post(
                f"{SUPABASE_URL}/auth/v1/recover",
                headers=_anon_headers(),
                json=payload_json
            )
            
            if reset_resp.status_code == 429:
                return jsonify({"error": "Too many password reset requests. Please wait 60 seconds before trying again."}), 429
            
            if reset_resp.status_code not in (200, 204):
                error_data = reset_resp.json() if reset_resp.text else {}
                raise RuntimeError(f"Status {reset_resp.status_code}: {error_data}")
        except Exception as exc:
            return jsonify({"error": f"password_otp_failed: {exc}"}), 400

        user_id = token_claims.get("sub")
        if not user_id:
            return jsonify({"error": "user_not_found"}), 400

        password_hash = hashlib.sha256(new_password.encode("utf-8")).hexdigest()
        _pending_password_changes[user_id] = {
            "email": email,
            "requested_at": time.time(),
            "expires_at": time.time() + _OTP_TTL_SECONDS,
            "attempts": 0,
            "new_password_hash": password_hash,
        }

        return jsonify({"message": "password_otp_sent"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/auth/password/change/verify", methods=["POST"])
@token_required
def verify_password_change(token_claims, token):
    """Verify OTP and update password."""
    try:
        payload = request.get_json() or {}
        otp = (payload.get("otp") or "").strip()
        new_password = (payload.get("new_password") or "").strip()

        if not otp or not new_password:
            return jsonify({"error": "Please enter both verification code and new password."}), 400
        if len(new_password) < 8:
            return jsonify({"error": "Password must be at least 8 characters long."}), 400

        user_id = token_claims.get("sub")
        entry = _pending_password_changes.get(user_id)
        if not entry:
            return jsonify({"error": "No pending password change. Please request a new code."}), 400

        if time.time() > entry.get("expires_at", 0):
            _pending_password_changes.pop(user_id, None)
            return jsonify({"error": "Verification code expired. Please request a new one."}), 410

        attempts = int(entry.get("attempts", 0))
        if attempts >= _MAX_OTP_ATTEMPTS:
            _pending_password_changes.pop(user_id, None)
            return jsonify({"error": "Too many failed attempts. Please request a new code."}), 429

        expected_hash = entry.get("new_password_hash")
        provided_hash = hashlib.sha256(new_password.encode("utf-8")).hexdigest()
        if expected_hash != provided_hash:
            return jsonify({"error": "Password doesn't match. Please enter the same password you used when requesting the code."}), 400

        email = entry.get("email")
        
        # Verify OTP using REST API
        try:
            verify_resp = requests.post(
                f"{SUPABASE_URL}/auth/v1/verify",
                headers=_anon_headers(),
                json={
                    "type": "recovery",
                    "token": otp,
                    "email": email
                }
            )
            
            if verify_resp.status_code != 200:
                error_data = verify_resp.json() if verify_resp.text else {}
                raise RuntimeError(f"Status {verify_resp.status_code}: {error_data}")
            
            verify_data = verify_resp.json()
            verify_token = verify_data.get("access_token")
            
            if not verify_token:
                raise RuntimeError("No access token in verify response")
        except Exception as exc:
            entry["attempts"] = attempts + 1
            if entry["attempts"] >= _MAX_OTP_ATTEMPTS:
                _pending_password_changes.pop(user_id, None)
            return jsonify({"error": f"otp_verification_failed: {exc}"}), 400

        # Update password using the verified token
        try:
            update_resp = requests.put(
                f"{SUPABASE_URL}/auth/v1/user",
                headers=_user_headers(verify_token),
                json={"password": new_password}
            )
            
            if update_resp.status_code not in (200, 204):
                error_data = update_resp.json() if update_resp.text else {}
                raise RuntimeError(f"Status {update_resp.status_code}: {error_data}")
            
            update_data = update_resp.json() if update_resp.text else {}
        except Exception as exc:
            return jsonify({"error": f"password_update_failed: {exc}"}), 400

        _pending_password_changes.pop(user_id, None)
        
        # Extract complete session and user data
        user_data = update_data.get("user", verify_data.get("user", {}))
        session_data = {
            "access_token": update_data.get("access_token") or verify_token,
            "refresh_token": update_data.get("refresh_token") or verify_data.get("refresh_token"),
        }
        
        # Ensure all required fields
        if not user_data.get("id"):
            user_data["id"] = user_id
        if not user_data.get("email"):
            user_data["email"] = email
        if not user_data.get("aud"):
            user_data["aud"] = "authenticated"
        if "app_metadata" not in user_data:
            user_data["app_metadata"] = {}
        if "user_metadata" not in user_data:
            user_data["user_metadata"] = {}
        if "created_at" not in user_data:
            user_data["created_at"] = None
        
        return jsonify({"message": "password_updated", "session": session_data, "user": user_data}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Health Check
@app.route("/health", methods=["GET"])
def health():
    """Simple health check endpoint."""
    return jsonify({"status": "ok", "message": "Chef-Kit backend is running"}), 200


@app.route("/api/users", methods=["GET"])
@optional_token
def get_users(token_claims, token):
    """Fetch all users. RLS allows public read. Optional auth for follow status."""
    try:
        users = get_all_users()
        
        # If user is authenticated, check follow status for each user
        if token_claims:
            from services import check_if_following
            current_user_id = token_claims.get("sub")
            if current_user_id:
                for user in users:
                    user["is_followed"] = check_if_following(current_user_id, user["user_id"])
            else:
                for user in users:
                    user["is_followed"] = False
        else:
            for user in users:
                user["is_followed"] = False
        
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/users/<user_id>", methods=["GET"])
def get_user(user_id):
    """Fetch a single user by ID."""
    try:
        user = service_get_user(user_id)
        return jsonify(user), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/api/users", methods=["POST"])
@token_required
def create_user(token_claims, token):
    """Create a new user. Requires valid JWT token (from Supabase Auth)."""
    try:
        data = request.get_json()
        # Ensure user_id matches the token's sub (user cannot create profiles for others)
        if "user_id" in data and data["user_id"] != token_claims["sub"]:
            return jsonify({"error": "Cannot create profile for another user"}), 403
        # Set user_id from token if not provided
        data["user_id"] = token_claims["sub"]
        set_postgrest_token(token)
        created = service_create_user(data)
        return jsonify(created), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/users/<user_id>", methods=["PUT"])
@token_required
def update_user(user_id, token_claims, token):
    """Update a user. Requires valid JWT token (auth.uid() = user_id)."""
    try:
        # Enforce user can only update their own profile
        if token_claims["sub"] != user_id:
            return jsonify({"error": "Cannot update another user's profile"}), 403
        data = request.get_json()
        set_postgrest_token(token)
        updated = service_update_user(user_id, data)
        return jsonify(updated), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/users/<user_id>/avatar", methods=["POST"])
@token_required
def upload_avatar(user_id, token_claims, token):
    """Upload avatar image to Cloudinary and update user_avatar.

    Expects JSON: { "image_base64": "data:image/...;base64,XXX" or pure base64 }
    """
    try:
        print(f"[avatar] Upload requested for user_id={user_id}")
        print(f"[avatar] Token claims: {token_claims}")
        # Enforce user can only update their own avatar
        if token_claims["sub"] != user_id:
            print(f"[avatar] Token subject {token_claims.get('sub')} does not match path {user_id}")
            return jsonify({"error": "Cannot update another user's avatar"}), 403

        payload = request.get_json() or {}
        image_b64 = payload.get("image_base64") or ""
        if not image_b64:
            print("[avatar] Missing image_base64 in payload")
            return jsonify({"error": "image_base64 is required"}), 400

        # Strip data URL prefix if present
        if "," in image_b64:
            image_b64 = image_b64.split(",", 1)[1]
        print(f"[avatar] Base64 payload length: {len(image_b64)}")

        cloud_name, api_key, api_secret = get_cloudinary_config()
        print(f"[avatar] Using Cloudinary cloud={cloud_name}")

        timestamp = int(time.time())
        folder = "chef-kit/avatars"
        params_to_sign = {
            "folder": folder,
            "timestamp": str(timestamp),
        }

        to_sign = "&".join(f"{k}={v}" for k, v in sorted(params_to_sign.items()))
        signature = hashlib.sha1((to_sign + api_secret).encode("utf-8")).hexdigest()
        print(f"[avatar] Signature string: {to_sign}")

        data = {
            "file": f"data:image/jpeg;base64,{image_b64}",
            "folder": folder,
            "timestamp": timestamp,
            "api_key": api_key,
            "signature": signature,
        }

        upload_url = f"https://api.cloudinary.com/v1_1/{cloud_name}/image/upload"
        print(f"[avatar] Uploading to Cloudinary endpoint: {upload_url}")
        resp = requests.post(upload_url, data=data)
        if resp.status_code != 200:
            print(f"[avatar] Cloudinary upload failed: {resp.status_code} {resp.text}")
            return jsonify({"error": "cloudinary_upload_failed", "details": resp.text}), 502

        upload_json = resp.json()
        secure_url = upload_json.get("secure_url")
        if not secure_url:
            print("[avatar] Cloudinary response missing secure_url")
            return jsonify({"error": "cloudinary_no_url"}), 502

        print(f"[avatar] Cloudinary upload succeeded. URL={secure_url}")
        set_postgrest_token(token)
        updated = update_user_service(user_id, {"user_avatar": secure_url})
        print(f"[avatar] Supabase update result: {updated}")
        return jsonify({"avatar_url": secure_url, "user": updated}), 200
    except Exception as e:
        print(f"[avatar] Unexpected error: {e}")
        return jsonify({"error": str(e)}), 500


# Recipes 
@app.route("/api/recipes", methods=["GET"])
def get_recipes():
    """Fetch all recipes. RLS allows public read."""
    tag = request.args.get('tag')
    try:
        recipes = get_all_recipes(tag=tag)
        response = jsonify(recipes)
        response.headers["Connection"] = "close"
        return response, 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# TODO: Implement actual logic for recipe results
@app.route("/api/recipes/result", methods=["POST"])
def get_recipes_result_route():
    """Fetch 10 recipes for the results page based on ingredients."""
    try:
        payload = request.get_json() or {}
        ingredients = payload.get("ingredients", [])
        
        print(f"Fetching recipes result for ingredients: {ingredients}")
        recipes = get_recipes_result(ingredients)
        print(f"Fetched {len(recipes)} recipes.")
        
        # Debug: Check for circular references or non-serializable data
        # by dumping to string first
        import json
        json_str = json.dumps(recipes, default=str)
        print(f"JSON response size: {len(json_str)} bytes")
        
        response = jsonify(recipes)
        response.headers["Connection"] = "close" # Force close to avoid keep-alive issues
        return response, 200
    except Exception as e:
        print(f"Error in get_recipes_result_route: {e}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes/<recipe_id>", methods=["GET"])
def get_recipe_route(recipe_id):
    """Fetch a single recipe by ID."""
    try:
        recipe = get_recipe(recipe_id)
        return jsonify(recipe), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/api/user/recipes", methods=["GET"])
@token_required
def get_current_user_recipes(token_claims, token):
    """Get all recipes for the authenticated user/chef. Requires valid JWT token."""
    try:
        user_id = token_claims["sub"]
        set_postgrest_token(token)
        recipes = get_recipes_by_chef(user_id)
        return jsonify(recipes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes/upload-image", methods=["POST"])
@token_required
def upload_recipe_image(token_claims, token):
    """Upload recipe image to Cloudinary.

    Expects JSON: { "image_base64": "data:image/...;base64,XXX" or pure base64 }
    Returns: { "image_url": "https://..." }
    """
    try:
        print("[recipe-image] Upload requested")
        print(f"[recipe-image] Token claims: {token_claims}")

        payload = request.get_json() or {}
        image_b64 = payload.get("image_base64") or ""
        if not image_b64:
            print("[recipe-image] Missing image_base64 in payload")
            return jsonify({"error": "image_base64 is required"}), 400

        # Strip data URL prefix if present
        if "," in image_b64:
            image_b64 = image_b64.split(",", 1)[1]
        print(f"[recipe-image] Base64 payload length: {len(image_b64)}")

        cloud_name, api_key, api_secret = get_cloudinary_config()
        print(f"[recipe-image] Using Cloudinary cloud={cloud_name}")

        timestamp = int(time.time())
        folder = "chef-kit/recipes"
        params_to_sign = {
            "folder": folder,
            "timestamp": str(timestamp),
        }

        to_sign = "&".join(f"{k}={v}" for k, v in sorted(params_to_sign.items()))
        signature = hashlib.sha1((to_sign + api_secret).encode("utf-8")).hexdigest()
        print(f"[recipe-image] Signature string: {to_sign}")

        data = {
            "file": f"data:image/jpeg;base64,{image_b64}",
            "folder": folder,
            "timestamp": timestamp,
            "api_key": api_key,
            "signature": signature,
        }

        upload_url = f"https://api.cloudinary.com/v1_1/{cloud_name}/image/upload"
        print(f"[recipe-image] Uploading to Cloudinary endpoint: {upload_url}")
        resp = requests.post(upload_url, data=data)
        if resp.status_code != 200:
            print(f"[recipe-image] Cloudinary upload failed: {resp.status_code} {resp.text}")
            return jsonify({"error": "cloudinary_upload_failed", "details": resp.text}), 502

        upload_json = resp.json()
        secure_url = upload_json.get("secure_url")
        if not secure_url:
            print("[recipe-image] Cloudinary response missing secure_url")
            return jsonify({"error": "cloudinary_no_url"}), 502

        print(f"[recipe-image] Cloudinary upload succeeded. URL={secure_url}")
        return jsonify({"image_url": secure_url}), 200
    except Exception as e:
        print(f"[recipe-image] Unexpected error: {e}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes", methods=["POST"])
@token_required
def create_recipe_route(token_claims, token):
    """Create a new recipe. Requires valid JWT token."""
    try:
        data = request.get_json()
        # Set recipe_owner to the authenticated user
        data["recipe_owner"] = token_claims["sub"]
        set_postgrest_token(token)
        created = create_recipe(data)
        return jsonify(created), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/recipes/<recipe_id>", methods=["PUT"])
@token_required
def update_recipe_route(recipe_id, token_claims, token):
    """Update a recipe. Requires valid JWT token (must be the recipe owner)."""
    try:
        data = request.get_json()
        print(f"[update-recipe] Recipe ID: {recipe_id}")
        print(f"[update-recipe] Request data: {data}")
        print(f"[update-recipe] recipe_image_url in request: {data.get('recipe_image_url')}")
        
        set_postgrest_token(token)
        updated = update_recipe(recipe_id, data)
        
        print(f"[update-recipe] Updated recipe: {updated}")
        print(f"[update-recipe] recipe_image_url in response: {updated.get('recipe_image_url')}")
        
        return jsonify(updated), 200
    except Exception as e:
        print(f"[update-recipe] Error: {e}")
        return jsonify({"error": str(e)}), 400


@app.route("/api/recipes/<recipe_id>", methods=["DELETE"])
@token_required
def delete_recipe_route(recipe_id, token_claims, token):
    """Delete a recipe. Requires valid JWT token (must be the recipe owner)."""
    try:
        set_postgrest_token(token)
        delete_recipe(recipe_id)
        return jsonify({"message": "Recipe deleted"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Ingredients
@app.route("/api/ingredients", methods=["GET"])
def get_ingredients():
    """Fetch all ingredients. RLS allows public read."""
    try:
        items = get_all_ingredients()
        return jsonify(items), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/ingredients/<ingredient_id>", methods=["GET"])
def get_ingredient(ingredient_id):
    """Fetch a single ingredient by ID."""
    try:
        item = get_ingredient(ingredient_id)
        return jsonify(item), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/api/ingredients", methods=["POST"])
def create_ingredient():
    """Create a new ingredient."""
    try:
        data = request.get_json()
        created = create_ingredient(data)
        return jsonify(created), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Notifications
@app.route("/api/notifications/<user_id>", methods=["GET"])
@token_required
def get_notifications(user_id, token_claims, token):
    """Fetch notifications for a user. Requires valid JWT token."""
    try:
        # Users can only fetch their own notifications
        if token_claims["sub"] != user_id:
            return jsonify({"error": "Cannot access another user's notifications"}), 403
        set_postgrest_token(token)
        notifications = get_notifications_for_user(user_id)
        return jsonify(notifications), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/notifications", methods=["POST"])
@token_required
def create_notification(token_claims, token):
    """Create a new notification. Requires valid JWT token."""
    try:
        data = request.get_json()
        set_postgrest_token(token)
        created = create_notification(data)
        return jsonify(created), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400





# Chefs & Trending
@app.route("/api/chefs/on-fire", methods=["GET"])
@optional_token
def get_chefs_on_fire_route(token_claims, token):
    """Get all chefs marked as 'on fire'. Public endpoint with optional auth."""
    try:
        chefs = get_chefs_on_fire()
        
        # If user is authenticated, check follow status for each chef
        if token_claims:
            from services import check_if_following
            current_user_id = token_claims.get("sub")
            if current_user_id:
                for chef in chefs:
                    chef["is_followed"] = check_if_following(current_user_id, chef["user_id"])
            else:
                for chef in chefs:
                    chef["is_followed"] = False
        else:
            for chef in chefs:
                chef["is_followed"] = False
        
        return jsonify(chefs), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/chefs/<chef_id>", methods=["GET"])
@optional_token
def get_chef_route(chef_id, token_claims, token):
    """Get a specific chef by ID. Public endpoint with optional auth."""
    try:
        chef = get_chef_by_id(chef_id)
        
        # If user is authenticated, check if they're following this chef
        if token_claims:
            from services import check_if_following
            current_user_id = token_claims.get("sub")
            if current_user_id:
                is_following = check_if_following(current_user_id, chef_id)
                chef["is_followed"] = is_following
            else:
                chef["is_followed"] = False
        else:
            chef["is_followed"] = False
        
        return jsonify(chef), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/api/chefs/<chef_id>/recipes", methods=["GET"])
def get_chef_recipes_route(chef_id):
    """Get all recipes by a specific chef. Public endpoint."""
    try:
        recipes = get_recipes_by_chef(chef_id)
        return jsonify(recipes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes/trending", methods=["GET"])
def get_trending_recipes_route():
    """Get all trending recipes. Public endpoint."""
    try:
        recipes = get_trending_recipes()
        response = jsonify(recipes)
        response.headers["Connection"] = "close"
        return response, 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes/seasonal", methods=["GET"])
def get_seasonal_recipes_route():
    """Get all seasonal recipes. Public endpoint."""
    try:
        from services import get_seasonal_recipes
        recipes = get_seasonal_recipes()
        response = jsonify(recipes)
        response.headers["Connection"] = "close"
        return response, 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/chefs/<chef_id>/follow", methods=["POST"])
@token_required
def toggle_follow_route(chef_id, token_claims, token):
    """Toggle follow status for a chef. Requires authentication."""
    try:
        follower_id = token_claims["sub"]
        
        # Prevent following yourself
        if follower_id == chef_id:
            return jsonify({"error": "Cannot follow yourself"}), 400
        
        result = toggle_follow(follower_id, chef_id)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Favorites
@app.route("/api/favorites", methods=["GET"])
@token_required
def get_favorites(token_claims, token=None):
    try:
        user_id = token_claims.get("sub")
        favorites = get_user_favorites(user_id)
        return jsonify(favorites), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/favorites/<recipe_id>/toggle", methods=["POST"])
@token_required
def toggle_favorite_route(token_claims, recipe_id, token=None):
    try:
        user_id = token_claims.get("sub")
        print(f"[toggle_favorite_route] User {user_id} toggling recipe {recipe_id}")
        is_fav = toggle_user_favorite(user_id, recipe_id)
        return jsonify({"is_favorite": is_fav}), 200
    except Exception as e:
        print(f"[toggle_favorite_route] Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 400


@app.route("/api/favorites/ids", methods=["GET"])
@token_required
def get_favorite_ids(token_claims, token=None):
    try:
        user_id = token_claims.get("sub")
        ids = get_user_favorite_ids(user_id)
        return jsonify(ids), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Notifications
@app.route("/api/notifications", methods=["GET"])
@token_required
def get_notifications_route(token_claims, token=None):
    try:
        user_id = token_claims.get("sub")
        notifications = get_notifications_for_user(user_id)
        return jsonify(notifications), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/notifications/<notification_id>/read", methods=["PUT"])
@token_required
def mark_notification_read_route(token_claims, notification_id, token=None):
    try:
        result = mark_notification_read(notification_id)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/notifications/read-all", methods=["PUT"])
@token_required
def mark_all_notifications_read_route(token_claims, token=None):
    try:
        user_id = token_claims.get("sub")
        result = mark_all_notifications_read(user_id)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/notifications/token", methods=["POST"])
@token_required
def update_fcm_token_route(token_claims, token=None):
    try:
        user_id = token_claims.get("sub")
        data = request.get_json()
        fcm_token = data.get("token")
        
        if not fcm_token:
            return jsonify({"error": "Token is required"}), 400
            
        result = update_fcm_token(user_id, fcm_token)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# cooking functionality
@app.route("/api/cook", methods=["POST"])
def cook_recipe():
    """Find best matching recipes based on provided ingredients and optional time constraint."""
    try:
        payload = request.get_json() or {}
        ingredients = payload.get("ingredients", [])
        time = payload.get("time")  # Optional time constraint in 'mm:ss' format
        recipe_instructions = generate_cooking_instructions(ingredients, time)
        return jsonify({"recipes": recipe_instructions}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Error Handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000, threaded=True)
