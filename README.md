# 🍳 ChefKit - Your Ultimate Cooking Companion

A modern, multilingual cooking app built with Flutter and Flask, featuring recipe discovery, chef profiles, inventory management, and smart cooking assistance.

## ✨ Features

- 🔍 **Recipe Discovery**: Browse hot recipes, seasonal delights, and trending chefs
- ❤️ **Favorites**: Save your favorite recipes and access them offline
- 👨‍🍳 **Chef Profiles**: Follow your favorite chefs and discover their recipes
- 📦 **Inventory Management**: Track your ingredients and find recipes based on what you have
- 🌍 **Multilingual**: Full support for English, Arabic, and French
- 🌓 **Dark Mode**: Beautiful UI that adapts to your preference
- 🔔 **Push Notifications**: Daily recipe suggestions and cooking reminders
- 🎯 **Smart Recommendations**: Get personalized recipe suggestions

## 🚀 Quick Start

### Prerequisites

- Flutter 3.x or higher
- Python 3.8+
- Node.js (for Firebase)
- Supabase account
- Firebase account (for push notifications)

### 🏃‍♂️ Running the App

#### Local Development

1. **Start the backend:**
   ```bash
   ./start_backend.sh
   ```

2. **Start the Flutter app:**
   ```bash
   ./start_app_local.sh
   ```

#### Production

```bash
./start_app_prod.sh
```

### 📱 Manual Setup

#### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the `backend` directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   SUPABASE_SERVICE_KEY=your_service_key
   ```

5. Start the server:
   ```bash
   python app.py
   ```

   The backend will run on `http://localhost:8000`

#### Flutter App Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Create a `.env` file in the project root:
   ```env
   BASE_URL=http://localhost:8000
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

3. Run the app:
   ```bash
   flutter run --dart-define=BASE_URL=http://localhost:8000
   ```

## 🎯 Core Functionality

### ✅ Recipe Favorites (Fixed)

Users can now:
- ❤️ Save recipes by tapping the heart icon
- 📋 View all favorites in the Favorites page
- 🔄 Automatic sync with the server
- ⚡ Optimistic updates for instant feedback

**Technical Details:**
- Uses Supabase `users.user_favourite_recipees` array
- Local caching for offline access
- Automatic retry on network failures
- Proper error handling and recovery

### ✅ Chef Follow (Fixed)

Users can now:
- 👥 Follow/unfollow chefs
- 📊 See follower counts update in real-time
- 🔄 Automatic sync with the server
- ⚡ Optimistic updates for instant feedback

**Technical Details:**
- Uses Supabase `follows` table
- Database triggers update follower counts
- Proper authentication handling
- Resilient error recovery

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **flutter_bloc** - State management
- **http** - API communication
- **sqflite** - Local database
- **firebase_messaging** - Push notifications
- **flutter_dotenv** - Environment configuration

### Backend
- **Flask** - Python web framework
- **Supabase** - PostgreSQL database and authentication
- **Firebase Admin SDK** - Push notifications
- **APScheduler** - Scheduled tasks
- **Cloudinary** - Image hosting

## 📁 Project Structure

```
chefkit/
├── lib/
│   ├── blocs/              # State management (BLoC)
│   ├── domain/             # Models and repositories
│   ├── views/              # UI screens and widgets
│   ├── common/             # Shared utilities
│   └── l10n/               # Localization files
├── backend/
│   ├── app.py              # Flask application
│   ├── services.py         # Business logic
│   ├── auth.py             # Authentication middleware
│   └── requirements.txt    # Python dependencies
├── assets/
│   ├── images/             # App images
│   └── fonts/              # Custom fonts
└── test/                   # Unit and widget tests
```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

Run specific test file:
```bash
flutter test test/authentication/auth_cubit_test.dart
```

## 🌍 Localization

The app supports three languages:
- 🇬🇧 English (en)
- 🇸🇦 Arabic (ar) - RTL support
- 🇫🇷 French (fr)

Translation files are located in `lib/l10n/`:
- `app_en.arb` - English
- `app_ar.arb` - Arabic
- `app_fr.arb` - French

## 🐛 Troubleshooting

### Backend not running
```bash
# Check if port 8000 is in use
lsof -ti:8000

# Kill the process if needed
lsof -ti:8000 | xargs kill -9

# Start the backend
./start_backend.sh
```

### Flutter build errors
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run again
flutter run
```

### Favorites not saving
1. Ensure backend is running (`curl http://localhost:8000/health`)
2. Check that you're logged in (not guest mode)
3. Check backend logs for errors
4. Verify `.env` has correct `BASE_URL`

### Chef follow not working
1. Ensure backend is running
2. Verify you're logged in
3. Check authentication token is valid
4. Review backend logs for Supabase errors

## 📝 Recent Fixes

### January 10, 2026
- ✅ Fixed recipe favorites not saving
- ✅ Fixed chef follow functionality
- ✅ Improved error handling and retry logic
- ✅ Added optimistic UI updates
- ✅ Fixed favorites list not refreshing after toggle
- ✅ Added proper localization support for favorites
- ✅ Created startup scripts for easier development

See [FIXES_APPLIED.md](FIXES_APPLIED.md) for detailed information.

## 🚧 Known Issues

1. Recipe translations must exist in database (falls back to English)
2. Local cache may be out of sync on multiple devices (pull-to-refresh fixes this)
3. Network required for follow/favorite (optimistic updates provide good offline UX)

## 🔮 Future Enhancements

- [ ] Offline queue for favorite toggles
- [ ] Visual sync status indicator
- [ ] Pagination for large favorites lists
- [ ] Undo action for accidental unfavorite
- [ ] Cache chef follow status locally
- [ ] Animated heart icon
- [ ] Rich notifications for likes and follows
- [ ] Recipe sharing via social media
- [ ] Voice-guided cooking instructions
- [ ] Meal planning calendar

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Contributors

- Development Team - ChefKit

## 📧 Support

For issues or questions, please contact the development team.

---

**Made with ❤️ and Flutter**
