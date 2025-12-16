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
# Disable session persistence to prevent state leakage between requests
stateless_options = ClientOptions(
    auto_refresh_token=False,
    persist_session=False,
)

# Main client uses ANON KEY for auth operations (login, signup)
# This is required because auth operations need to work with user credentials
supabase: Client = create_client(
    SUPABASE_URL, 
    SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY,
    options=stateless_options
)

# Admin client uses SERVICE ROLE KEY for database operations (bypasses RLS)
supabase_admin: Optional[Client] = None

if SUPABASE_SERVICE_ROLE_KEY:
    supabase_admin = create_client(
        SUPABASE_URL, 
        SUPABASE_SERVICE_ROLE_KEY,
        options=stateless_options
    )
    print("[Supabase] Admin client initialized with service role key")
else:
    print("[Supabase] WARNING: No SUPABASE_SERVICE_ROLE_KEY - some operations may fail!")

print(f"[Supabase] supabase_admin available: {supabase_admin is not None}")


def set_postgrest_token(token: str) -> None:
    """Attach a user's JWT to PostgREST requests.
    
    NOTE: For stateless operation, prefer using supabase_admin which bypasses RLS.
    This function is kept for backward compatibility but should be avoided.
    """
    supabase.postgrest.auth(token)
