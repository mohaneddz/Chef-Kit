import os
from dotenv import load_dotenv
from typing import Optional
from supabase import create_client, Client, ClientOptions

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL:
    raise ValueError("SUPABASE_URL must be set in .env")

if not SUPABASE_ANON_KEY and not SUPABASE_SERVICE_ROLE_KEY:
    raise ValueError("At least one of SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY must be set")

# STATELESS CLIENT OPTIONS
# For backend servers, we disable session persistence to ensure each request is independent.
stateless_options = ClientOptions(
    auto_refresh_token=False,  # Don't auto-refresh tokens
    persist_session=False,     # Don't persist session to storage
)

# Use SERVICE ROLE KEY for the main client if available
# This bypasses RLS and makes the backend truly stateless
# (no need to attach user tokens to the client)
_main_key = SUPABASE_SERVICE_ROLE_KEY or SUPABASE_ANON_KEY

supabase: Client = create_client(
    SUPABASE_URL, 
    _main_key,
    options=stateless_options
)

# Admin client is the same as main client when using service role
supabase_admin: Optional[Client] = None

if SUPABASE_SERVICE_ROLE_KEY:
    supabase_admin = supabase  # Both point to same service-role client
    print("[Supabase] Using SERVICE ROLE KEY - RLS bypassed, fully stateless")
else:
    print("[Supabase] WARNING: Using ANON KEY - RLS enforced, may have state issues!")

print(f"[Supabase] supabase_admin available: {supabase_admin is not None}")


def set_postgrest_token(token: str) -> None:
    """DEPRECATED: No longer needed when using service role key.
    
    This function was causing state leakage between requests.
    With service role key, RLS is bypassed so user tokens aren't needed.
    """
    # This is now a no-op to prevent state issues
    # The service role key bypasses RLS so we don't need user tokens
    print("[Supabase] WARNING: set_postgrest_token called but is now deprecated/no-op")
    pass


def clear_postgrest_token() -> None:
    """Clear any attached token from the postgrest client."""
    try:
        supabase.postgrest.auth(None)
    except Exception:
        pass
