"""
Chef-Kit Backend API
Flask server for Chef-Kit Flutter app.
Uses Supabase (Postgres) as the data store.
Endpoints wired to DB_SCHEMA.md tables.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from services import (
    get_all_users,
    get_user,
    create_user,
    update_user,
    get_all_recipes,
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
    auth_signup,
    auth_login,
    auth_refresh,
    auth_logout,
    auth_verify_email_otp,
)
from auth import token_required, optional_token
from supabase_client import set_postgrest_token
from supabase_client import supabase
import traceback
import time

# Simple in-memory throttle store for resend limits (per email)
_last_resend_ts = {}

app = Flask(__name__)
CORS(app)
# Auth
@app.route("/auth/signup", methods=["POST"])
def signup():
    try:
        payload = request.get_json() or {}
        email = payload.get("email")
        password = payload.get("password")
        if not email or not password:
            return jsonify({"error": "email and password are required"}), 400
        result = auth_signup(email, password)
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
def logout(token_claims):
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


# Health Check
@app.route("/health", methods=["GET"])
def health():
    """Simple health check endpoint."""
    return jsonify({"status": "ok", "message": "Chef-Kit backend is running"}), 200


@app.route("/api/users", methods=["GET"])
def get_users():
    """Fetch all users. RLS allows public read."""
    try:
        users = get_all_users()
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/users/<user_id>", methods=["GET"])
def get_user(user_id):
    """Fetch a single user by ID."""
    try:
        user = get_user(user_id)
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
        created = create_user(data)
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
        updated = update_user(user_id, data)
        return jsonify(updated), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Recipes 
@app.route("/api/recipes", methods=["GET"])
def get_recipes():
    """Fetch all recipes. RLS allows public read."""
    try:
        recipes = get_all_recipes()
        return jsonify(recipes), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/recipes/<recipe_id>", methods=["GET"])
def get_recipe(recipe_id):
    """Fetch a single recipe by ID."""
    try:
        recipe = get_recipe(recipe_id)
        return jsonify(recipe), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/api/recipes", methods=["POST"])
@token_required
def create_recipe(token_claims, token):
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
def update_recipe(recipe_id, token_claims, token):
    """Update a recipe. Requires valid JWT token (must be the recipe owner)."""
    try:
        data = request.get_json()
        set_postgrest_token(token)
        updated = update_recipe(recipe_id, data)
        return jsonify(updated), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/api/recipes/<recipe_id>", methods=["DELETE"])
@token_required
def delete_recipe(recipe_id, token_claims, token):
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


@app.route("/api/notifications/<notification_id>/read", methods=["PUT"])
@token_required
def mark_notification_read(notification_id, token_claims, token):
    """Mark a notification as read. Requires valid JWT token."""
    try:
        set_postgrest_token(token)
        updated = mark_notification_read(notification_id)
        return jsonify(updated), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Error Handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
