"""
Setup script for Chef-Kit Cloudinary avatar uploads.
Run this to install dependencies and verify configuration.
"""
import subprocess
import sys
import os

def check_env_vars():
    """Check if Cloudinary environment variables are set."""
    required = ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"]
    missing = []
    
    for var in required:
        if not os.getenv(var):
            missing.append(var)
    
    if missing:
        print("❌ Missing Cloudinary environment variables:")
        for var in missing:
            print(f"   - {var}")
        print("\n📝 Add these to your backend/.env file:")
        print("   CLOUDINARY_CLOUD_NAME=your_cloud_name")
        print("   CLOUDINARY_API_KEY=your_api_key")
        print("   CLOUDINARY_API_SECRET=your_api_secret")
        print("\n🔑 Get your credentials from: https://console.cloudinary.com/")
        return False
    
    print("✅ All Cloudinary environment variables are set")
    return True

def install_requests():
    """Install requests library if not present."""
    try:
        import requests
        print("✅ requests library already installed")
        return True
    except ImportError:
        print("📦 Installing requests library...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
        print("✅ requests library installed successfully")
        return True

def main():
    print("🚀 Chef-Kit Cloudinary Setup")
    print("=" * 50)
    
    # Install dependencies
    if not install_requests():
        sys.exit(1)
    
    # Check environment variables
    if not check_env_vars():
        print("\n⚠️  Setup incomplete. Please add Cloudinary credentials to .env")
        sys.exit(1)
    
    print("\n✅ Setup complete! You can now:")
    print("   1. Run: python app.py")
    print("   2. In Flutter: Tap the edit icon on profile to upload avatar")
    print("   3. Images will be stored in: chef-kit/avatars/ on Cloudinary")

if __name__ == "__main__":
    main()
