# Firebase Cloud Messaging (FCM) Implementation

## Overview

This document explains how Firebase Cloud Messaging (FCM) is implemented in the Chef-Kit application to deliver push notifications to users.

## Architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   Flutter App   │──────│  Python Backend │──────│  Firebase FCM   │
│   (Frontend)    │      │    (Flask)      │      │    (Google)     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
        │                        │                        │
        │ 1. Get FCM Token       │                        │
        │◄───────────────────────┼────────────────────────┤
        │                        │                        │
        │ 2. Send token to       │                        │
        │    backend on login    │                        │
        ├───────────────────────►│                        │
        │                        │                        │
        │                        │ 3. Store token in      │
        │                        │    Supabase DB         │
        │                        │                        │
        │                        │ 4. When event occurs,  │
        │                        │    send notification   │
        │                        ├───────────────────────►│
        │                        │                        │
        │ 5. FCM delivers push   │                        │
        │◄───────────────────────┼────────────────────────┤
        │                        │                        │
```

## Components

### 1. Flutter App (Frontend)

#### Files:
- `lib/common/firebase_messaging_service.dart` - Main FCM service
- `lib/main.dart` - Firebase initialization
- `lib/blocs/auth/auth_cubit.dart` - Sends token on login

#### How it works:

**Step 1: Initialize Firebase on app start**
```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (isFirebaseSupported) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessagingService().initialize();
  }
  
  runApp(MainApp());
}
```

**Step 2: Request notification permissions and get FCM token**
```dart
// firebase_messaging_service.dart
Future<void> initialize() async {
  // Request permission
  await _messaging.requestPermission(alert: true, badge: true, sound: true);
  
  // Get the unique device token
  _fcmToken = await _messaging.getToken();
  
  // Listen for token refresh (tokens can change)
  _messaging.onTokenRefresh.listen(_handleTokenRefresh);
  
  // Handle incoming messages
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
}
```

**Step 3: Send token to backend during login**
```dart
// auth_cubit.dart
Future<void> login(String email, String password) async {
  String? deviceToken;
  if (isFirebaseSupported) {
    deviceToken = FirebaseMessagingService().fcmToken;
  }
  
  final resp = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    body: jsonEncode({
      'email': email,
      'password': password,
      'device_token': deviceToken,  // <-- FCM token sent here
    }),
  );
}
```

**Step 4: Handle incoming notifications**
```dart
// For foreground messages, show local notification
void _handleForegroundMessage(RemoteMessage message) {
  _showLocalNotification(
    title: message.notification?.title ?? 'Chef Kit',
    body: message.notification?.body ?? '',
  );
}

// For background/terminated messages, Flutter handles automatically
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Message is automatically shown by the system
}
```

### 2. Python Backend (Flask)

#### Files:
- `backend/services.py` - Contains FCM sending logic
- `backend/app.py` - API endpoints

#### How it works:

**Step 1: Initialize Firebase Admin SDK**
```python
# services.py
import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
```

**Step 2: Store device token on login**
```python
# services.py
def auth_login(email: str, password: str, device_token: str = None):
    # ... authentication logic ...
    
    # Store device token for push notifications
    if device_token and user_id:
        update_fcm_token(user_id, device_token)
    
    return {"access_token": ..., "user": ...}

def update_fcm_token(user_id: str, token: str):
    # Get current tokens
    resp = supabase_admin.table("users").select("user_devices").eq("user_id", user_id).execute()
    
    # Add new token if not exists
    devices = json.loads(resp.data.get("user_devices") or "[]")
    if token not in devices:
        devices.append(token)
        supabase_admin.table("users").update({
            "user_devices": json.dumps(devices)
        }).eq("user_id", user_id).execute()
```

**Step 3: Send push notification when events occur**
```python
# services.py
def _send_push_notification(data: Dict[str, Any]):
    user_id = data.get("user_id")
    title = data.get("notification_title")
    body = data.get("notification_message")
    
    # Get user's device tokens from database
    user_resp = supabase_admin.table("users").select("user_devices").eq("user_id", user_id).execute()
    tokens = json.loads(user_resp.data.get("user_devices") or "[]")
    
    # Send to each device
    for token in tokens:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=token,
        )
        messaging.send(message)

def create_notification(data: Dict[str, Any]):
    # Insert into database
    supabase_admin.table("notifications").insert(data).execute()
    
    # Send push notification
    _send_push_notification(data)
```

**Step 4: Trigger notifications on user actions**
```python
# services.py
def follow_chef(user_id: str, chef_id: str):
    # ... follow logic ...
    
    # Create notification for the chef
    create_notification({
        "user_id": chef_id,
        "notification_title": "New Follower",
        "notification_message": f"{follower_name} started following you.",
        "notification_type": "follow",
        "notification_data": {"follower_id": user_id}
    })
```

## Database Schema

The `users` table in Supabase stores FCM tokens:

```sql
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    user_email TEXT,
    user_full_name TEXT,
    user_devices TEXT,  -- JSON array of FCM tokens: ["token1", "token2"]
    ...
);
```

The `notifications` table stores notification history:

```sql
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    notification_title TEXT,
    notification_message TEXT,
    notification_type TEXT,
    notification_data JSONB,
    notification_is_read BOOLEAN DEFAULT FALSE,
    notification_created_at TIMESTAMPTZ DEFAULT now()
);
```

## Configuration Files

### Flutter (Android)

**`android/app/google-services.json`**
- Downloaded from Firebase Console
- Contains project configuration (project_id, api_key, etc.)
- Links the Android app to the Firebase project

**`android/app/build.gradle.kts`**
```kotlin
plugins {
    id("com.google.gms.google-services")  // Firebase plugin
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

**`android/app/src/main/AndroidManifest.xml`**
```xml
<!-- Required permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- Default notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="chef_kit_notifications"/>
```

### Backend (Python)

**`backend/serviceAccountKey.json`**
- Downloaded from Firebase Console → Project Settings → Service Accounts
- Used by Firebase Admin SDK to authenticate
- Contains private key (keep secret!)

**Environment Variables**
```bash
GOOGLE_APPLICATION_CREDENTIALS=serviceAccountKey.json
```

## Notification Types

| Type | Trigger | Title | Message |
|------|---------|-------|---------|
| `follow` | User follows a chef | "New Follower" | "{name} started following you." |
| `like` | User likes a recipe | "New Like" | "{name} liked your recipe." |
| `comment` | User comments on a recipe | "New Comment" | "{name} commented on your recipe." |

## Message Flow Example

**Scenario: User A follows Chef B**

1. **Flutter App** (User A's phone):
   - User taps "Follow" button
   - App sends POST request to `/api/chefs/{chef_id}/follow`

2. **Backend**:
   - Receives follow request
   - Updates follow relationship in database
   - Calls `create_notification()` with Chef B's user_id
   - Fetches Chef B's FCM tokens from `user_devices` column
   - Sends push notification via Firebase Admin SDK

3. **Firebase**:
   - Receives message from backend
   - Routes to Chef B's devices using FCM tokens

4. **Flutter App** (Chef B's phone):
   - If app is in foreground: `onMessage` listener shows local notification
   - If app is in background: System shows notification automatically
   - If app is terminated: `onBackgroundMessage` handler processes it

## Handling Different App States

| App State | Handler | Notification Display |
|-----------|---------|---------------------|
| Foreground | `FirebaseMessaging.onMessage` | Local notification via `flutter_local_notifications` |
| Background | `FirebaseMessaging.onBackgroundMessage` | System shows automatically |
| Terminated | `FirebaseMessaging.onBackgroundMessage` | System shows automatically |
| Opened from notification | `FirebaseMessaging.onMessageOpenedApp` | Navigate to relevant screen |

## Security Considerations

1. **Service Account Key**: Never commit `serviceAccountKey.json` to git (it's in .gitignore)

2. **RLS (Row Level Security)**: Backend uses `supabase_admin` (service role) to bypass RLS for creating notifications for other users

3. **Token Validation**: FCM tokens are validated by Firebase before sending

4. **Stale Tokens**: When a token is invalid, the send fails gracefully and should be removed from the database

## Dependencies

### Flutter (`pubspec.yaml`)
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.6
  flutter_local_notifications: ^18.0.1
```

### Python (`requirements.txt`)
```
firebase-admin>=6.0.0
```

## Testing

1. **Check FCM token is obtained**:
   - Look for `[FCM] Token obtained: ...` in Flutter debug console

2. **Check token is sent to backend**:
   - Look for `[AuthCubit] FCM token available: true` on login

3. **Check token is stored**:
   - Look for `[update_fcm_token] Adding new token` in backend logs

4. **Check notification is sent**:
   - Look for `[_send_push_notification] Sent X messages` in backend logs

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Platform not supported" | Running on Windows/Linux desktop | Firebase only works on Android/iOS/Web |
| "Token not found" | FCM token not obtained | Check Firebase initialization |
| 404 on /batch | Deprecated API | Use `messaging.send()` instead of `send_multicast()` |
| RLS policy violation | Using regular Supabase client | Use `supabase_admin` for cross-user inserts |
| Session not found | Calling `sign_out()` in backend | Remove `sign_out()` calls |
