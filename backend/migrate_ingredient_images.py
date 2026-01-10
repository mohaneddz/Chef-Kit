"""
Upload local ingredient assets to Cloudinary and update Supabase URLs.

Usage:
    cd backend
    python migrate_ingredient_images.py [--dry-run]

Requirements:
- Environment variables: CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
- Supabase service role key set (SUPABASE_SERVICE_ROLE_KEY) so updates bypass RLS.
"""
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional

import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv

from cloudinary_utils import get_cloudinary_config
from supabase_client import supabase, supabase_admin

load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = PROJECT_ROOT / "assets" / "images" / "ingredients"
VALID_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".avif"}


def slugify(value: str) -> str:
    """Convert ingredient names into filename-friendly keys."""
    return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")


def ensure_clients() -> None:
    """Validate Cloudinary and Supabase admin clients are available."""
    cloud_name, api_key, api_secret = get_cloudinary_config()
    cloudinary.config(
        cloud_name=cloud_name,
        api_key=api_key,
        api_secret=api_secret,
        secure=True,
    )

    if not supabase_admin:
        raise RuntimeError(
            "Supabase admin client is not initialized. "
            "Set SUPABASE_SERVICE_ROLE_KEY in backend/.env"
        )


def load_supabase_rows() -> List[Dict]:
    """Fetch all ingredients so we can map by filename or name."""
    resp = supabase_admin.table("ingredients").select("*").execute()
    rows = getattr(resp, "data", None)
    if not rows:
        raise RuntimeError("No ingredient rows returned from Supabase.")
    return rows


def build_row_index(rows: List[Dict]) -> Dict[str, Dict]:
    """Index rows by a few possible keys (filename stem, slugified English name)."""
    index: Dict[str, Dict] = {}
    for row in rows:
        keys = set()
        current_url = row.get("ingredient_image_url") or row.get("image_path") or ""
        if current_url:
            keys.add(Path(current_url).stem.lower())

        name_fields = ("ingredient_name_en", "name_en", "ingredient_name")
        for field in name_fields:
            if row.get(field):
                keys.add(slugify(str(row[field])))

        for key in keys:
            # Later matches overwrite earlier ones, but keys should be unique per row.
            index[key] = row
    return index


def resolve_id_and_field(row: Dict) -> Optional[tuple]:
    """Return (id_column, id_value, image_field) for the row."""
    row_id = row.get("ingredient_id") or row.get("id")
    if not row_id:
        return None

    if "ingredient_image_url" in row:
        image_field = "ingredient_image_url"
    elif "image_path" in row:
        image_field = "image_path"
    else:
        image_field = "ingredient_image_url"

    id_column = "ingredient_id" if "ingredient_id" in row else "id"
    return id_column, row_id, image_field


def upload_to_cloudinary(path: Path) -> str:
    """Upload a file and return its secure URL."""
    result = cloudinary.uploader.upload(
        str(path),
        folder="chef-kit/ingredients",
        use_filename=True,
        unique_filename=False,
        overwrite=True,
    )
    secure_url = result.get("secure_url")
    if not secure_url:
        raise RuntimeError(f"Cloudinary upload failed for {path.name}: missing secure_url")
    return secure_url


def main(dry_run: bool = False) -> None:
    ensure_clients()
    if not ASSETS_DIR.exists():
        raise FileNotFoundError(f"Ingredient assets directory not found: {ASSETS_DIR}")

    rows = load_supabase_rows()
    index = build_row_index(rows)

    print(f"Found {len(rows)} ingredients in Supabase.")
    asset_files = [p for p in ASSETS_DIR.iterdir() if p.suffix.lower() in VALID_EXTENSIONS]
    print(f"Discovered {len(asset_files)} local ingredient images.")

    updated = 0
    skipped = 0
    for asset in sorted(asset_files, key=lambda p: p.name.lower()):
        key = asset.stem.lower()
        row = index.get(key)
        if not row:
            print(f"⚠️  No matching DB row for asset {asset.name} (key={key})")
            skipped += 1
            continue

        resolved = resolve_id_and_field(row)
        if not resolved:
            print(f"⚠️  Missing ingredient_id for row matched to {asset.name}; skipping.")
            skipped += 1
            continue

        id_column, row_id, image_field = resolved
        print(f"→ Uploading {asset.name} for ingredient {row_id} (field {image_field})")

        try:
            secure_url = upload_to_cloudinary(asset)
        except Exception as exc:
            print(f"❌ Upload failed for {asset.name}: {exc}")
            skipped += 1
            continue

        if dry_run:
            print(f"DRY-RUN: would update {image_field} to {secure_url}")
            updated += 1
            continue

        client = supabase_admin or supabase
        resp = (
            client.table("ingredients")
            .update({image_field: secure_url})
            .eq(id_column, row_id)
            .execute()
        )
        if getattr(resp, "data", None) is None:
            print(f"⚠️  Supabase update returned no data for {row_id}")
        else:
            print(f"✅ Updated {row_id} ({asset.name})")
        updated += 1

    print(f"\nDone. Updated {updated} images; skipped {skipped} images.")


if __name__ == "__main__":
    dry_run_flag = "--dry-run" in sys.argv
    main(dry_run=dry_run_flag)

