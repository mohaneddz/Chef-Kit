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
# This prevents issues where one user's session state affects another user's requests.
stateless_options = ClientOptions(
    auto_refresh_token=False,  # Don't auto-refresh tokens (we handle this manually)
    persist_session=False,     # Don't persist session to storage
)

supabase: Client = create_client(
    SUPABASE_URL, 
    SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY,
    options=stateless_options
)

supabase_admin: Optional[Client] = None

if SUPABASE_SERVICE_ROLE_KEY:
    # Admin client also stateless
    supabase_admin = create_client(
        SUPABASE_URL, 
        SUPABASE_SERVICE_ROLE_KEY,
        options=stateless_options
    )


def set_postgrest_token(token: str) -> None:
    """Attach a user's JWT to PostgREST requests to enforce RLS."""
    supabase.postgrest.auth(token)
