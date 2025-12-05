"""JWT middleware for Supabase Auth token verification.

Verifies Supabase access tokens by calling the Supabase Auth REST API.
Protects endpoints by checking for valid, non-expired tokens.
"""

import os
import requests
from functools import wraps
from flask import request, jsonify
from typing import Dict, Any

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY", "")


def verify_token(token: str) -> Dict[str, Any]:
    """Validate the access token via Supabase Auth REST API."""
    if not SUPABASE_URL:
        raise ValueError("SUPABASE_URL not set")

    headers = {
        "Authorization": f"Bearer {token}",
        "apikey": SUPABASE_KEY,
    }

    url = f"{SUPABASE_URL}/auth/v1/user"
    try:
        response = requests.get(url, headers=headers, timeout=5)
        print(f"[auth] GET {url} -> {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            sub = data.get("id")
            if not sub:
                raise ValueError("Supabase response missing user id")
            print(f"[auth] Supabase user verified: id={sub}")
            return {"sub": sub, "user": data}
        elif response.status_code == 401:
            raise ValueError("Invalid or expired token")
        else:
            raise ValueError(f"Supabase auth error ({response.status_code}): {response.text}")
    except requests.RequestException as exc:
        raise ValueError(f"Supabase auth request failed: {exc}")


def token_required(f):
    """
    Flask decorator to protect endpoints with JWT verification.
    
    Extracts the token from the Authorization header (Bearer scheme),
    verifies it, and passes the decoded claims to the route handler.
    
    Usage:
        @app.route('/api/protected', methods=['GET'])
        @token_required
        def protected_route(token_claims):
            user_id = token_claims['sub']
            ...
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if auth_header:
            preview = auth_header[:40] + ("..." if len(auth_header) > 40 else "")
            print(f"[token_required] Authorization header: {preview}")
        else:
            print("[token_required] Missing Authorization header")
            return jsonify({"error": "Missing Authorization header"}), 401

        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            print(f"[token_required] Bad Authorization header format: {auth_header}")
            return jsonify({"error": "Invalid Authorization header format. Use 'Bearer <token>'"}), 401

        token = parts[1]
        try:
            token_claims = verify_token(token)
            # Pass claims and raw token to the route handler
            print(f"[token_required] Token accepted for sub={token_claims.get('sub')}")
            return f(token_claims=token_claims, token=token, *args, **kwargs)
        except ValueError as e:
            print(f"[token_required] Verification error: {e}")
            return jsonify({"error": str(e)}), 401
        except Exception as e:
            print(f"[token_required] Unexpected auth failure: {e}")
            return jsonify({"error": f"Authentication failed: {str(e)}"}), 500
    
    return decorated_function


def optional_token(f):
    """
    Flask decorator for endpoints that optionally accept a JWT.
    
    If a valid token is provided, it is passed to the handler.
    If no token is provided, the handler receives None.
    If an invalid token is provided, an error is returned.
    
    Usage:
        @app.route('/api/recipes', methods=['GET'])
        @optional_token
        def get_recipes(token_claims=None):
            if token_claims:
                user_id = token_claims['sub']
            ...
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        token_claims = None
        token = None
        
        if auth_header:
            parts = auth_header.split()
            if len(parts) != 2 or parts[0].lower() != "bearer":
                return jsonify({"error": "Invalid Authorization header format. Use 'Bearer <token>'"}), 401
            
            token = parts[1]
            try:
                token_claims = verify_token(token)
            except ValueError as e:
                return jsonify({"error": str(e)}), 401
            except Exception as e:
                return jsonify({"error": f"Authentication failed: {str(e)}"}), 500
        
        return f(token_claims=token_claims, token=token, *args, **kwargs)
    
    return decorated_function
