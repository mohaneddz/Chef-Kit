"""JWT middleware for Supabase Auth token verification.

Verifies JWT tokens from Supabase Auth and extracts user info.
Protects endpoints by checking for valid, non-expired tokens.
"""

import os
import jwt
import requests
from functools import wraps
from flask import request, jsonify
from typing import Dict, Any, Optional

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY", "")


def get_supabase_public_key() -> Optional[str]:
    """
    Fetch the Supabase JWT public key from the JWKS endpoint.
    This is used to verify JWT signatures.
    """
    if not SUPABASE_URL:
        raise ValueError("SUPABASE_URL not set")
    
    try:
        jwks_url = f"{SUPABASE_URL}/.well-known/jwks.json"
        response = requests.get(jwks_url, timeout=5)
        if response.status_code == 200:
            jwks = response.json()
            # Extract the first public key (Supabase typically provides one)
            if jwks.get("keys"):
                return jwt.algorithms.RSAAlgorithm.from_jwk(jwks["keys"][0])
        return None
    except Exception as e:
        print(f"Error fetching Supabase public key: {e}")
        return None


# Cache the public key to avoid repeated fetches
_public_key_cache = None


def get_cached_public_key() -> Optional[str]:
    """Get or fetch the Supabase public key."""
    global _public_key_cache
    if _public_key_cache is None:
        _public_key_cache = get_supabase_public_key()
    return _public_key_cache


def verify_token(token: str) -> Dict[str, Any]:
    """
    Verify a JWT token and return decoded claims.
    
    Args:
        token: JWT token string (without 'Bearer ' prefix)
    
    Returns:
        Decoded JWT claims (includes 'sub' as user_id, 'exp', 'iat', etc.)
    
    Raises:
        ValueError: If token is invalid or expired
    """
    public_key = get_cached_public_key()
    if not public_key:
        raise ValueError("Unable to fetch Supabase public key")
    
    try:
        decoded = jwt.decode(
            token,
            public_key,
            algorithms=["RS256"],
            audience="authenticated",  # Supabase convention
        )
        return decoded
    except jwt.ExpiredSignatureError:
        raise ValueError("Token has expired")
    except jwt.InvalidTokenError as e:
        raise ValueError(f"Invalid token: {str(e)}")


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
        if not auth_header:
            return jsonify({"error": "Missing Authorization header"}), 401
        
        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return jsonify({"error": "Invalid Authorization header format. Use 'Bearer <token>'"}), 401
        
        token = parts[1]
        try:
            token_claims = verify_token(token)
            # Pass claims and raw token to the route handler
            return f(token_claims=token_claims, token=token, *args, **kwargs)
        except ValueError as e:
            return jsonify({"error": str(e)}), 401
        except Exception as e:
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
