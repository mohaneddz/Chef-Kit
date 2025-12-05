import os
from typing import Tuple


def get_cloudinary_config() -> Tuple[str, str, str]:
    """Read Cloudinary credentials from environment.

    CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
    must be set in the backend environment.
    """

    cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
    api_key = os.getenv("CLOUDINARY_API_KEY")
    api_secret = os.getenv("CLOUDINARY_API_SECRET")

    if not cloud_name or not api_key or not api_secret:
        raise RuntimeError("Cloudinary env vars not set: CLOUDINARY_CLOUD_NAME/API_KEY/API_SECRET")

    return cloud_name, api_key, api_secret
