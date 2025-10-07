# Zoom Classroom - Flutter App

A cross-platform Flutter application that enables teachers to create Zoom meetings directly from the classroom screen and push meeting links to students via in-app notifications. Students can join meetings seamlessly without context switching.

## Features

### 🔐 Authentication
- **Gmail Sign-In**: Quick authentication using Google OAuth
- **Phone Number Login**: SMS-based verification for phone authentication
- **Role-based Access**: Separate interfaces for teachers and students

### 📹 Zoom Integration
- **Meeting Creation**: Teachers can create Zoom meetings with custom settings
- **Seamless Joining**: Students can join meetings with a single tap
- **Meeting Management**: View, edit, and manage scheduled meetings
- **Real-time Status**: Live meeting indicators and status updates

### 💬 Real-time Chat
- **Classroom Communication**: Chat with students and teachers
- **Meeting Notifications**: Automatic meeting invites in chat
- **Message Types**: Support for text, images, files, and meeting invites
- **Read Receipts**: Track message read status

### 🔔 Notifications
- **In-app Notifications**: Meeting invites and chat messages
- **Push Notifications**: Firebase Cloud Messaging integration
- **Local Notifications**: Offline notification support

### 📱 Responsive Design
- **Cross-platform**: Works on both Android and iOS
- **Mobile-first**: Optimized for mobile devices
- **Adaptive UI**: Responsive design that adapts to different screen sizes

## Architecture

### Tech Stack
- **Frontend**: Flutter 3.0+
- **Backend**: Firebase (Authentication, Firestore, Cloud Messaging)
- **Video Conferencing**: Zoom SDK/REST API
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── meeting_model.dart
│   ├── chat_message_model.dart
│   └── class_model.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   ├── zoom_service.dart
│   ├── chat_service.dart
│   ├── meeting_service.dart
│   └── notification_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   └── meeting_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── phone_verification_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── meeting/
│   │   ├── create_meeting_screen.dart
│   │   └── meeting_list_screen.dart
│   ├── chat/
│   │   └── chat_list_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   └── custom_text_field.dart
└── utils/                    # Utilities and themes
    └── app_theme.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode for mobile development
- Firebase project
- Zoom account with API access

### 1. Clone the Repository
```bash
git clone <repository-url>
cd flutter_zoom_classroom
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication, Firestore, and Cloud Messaging

#### Configure Authentication
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Google and Phone providers
3. Add your app's SHA-1 fingerprint for Android

#### Configure Firestore
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules (see `firestore.rules`)

#### Download Configuration Files
1. Download `google-services.json` for Android
2. Download `GoogleService-Info.plist` for iOS
3. Place them in the appropriate directories

### 4. Zoom API Setup

#### Create Zoom App
1. Go to [Zoom Marketplace](https://marketplace.zoom.us/)
2. Create a new app
3. Choose "Server-to-Server OAuth" app type
4. Note down your Client ID, Client Secret, and Account ID

#### Update Zoom Configuration
1. Open `lib/services/zoom_service.dart`
2. Replace the placeholder values:
   ```dart
   static const String _clientId = 'YOUR_ZOOM_CLIENT_ID';
   static const String _clientSecret = 'YOUR_ZOOM_CLIENT_SECRET';
   static const String _accountId = 'YOUR_ZOOM_ACCOUNT_ID';
   ```

### 5. Platform-specific Setup

#### Android Setup
1. Update `android/app/build.gradle`:
   ```gradle
   android {
       compileSdkVersion 34
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 34
       }
   }
   ```

2. Add permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.VIBRATE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   ```

#### iOS Setup
1. Update `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access for video calls</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access for video calls</string>
   ```

2. Update `ios/Runner.xcodeproj/project.pbxproj` for iOS 12+ support

### 6. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

## Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
ZOOM_CLIENT_ID=your_zoom_client_id
ZOOM_CLIENT_SECRET=your_zoom_client_secret
ZOOM_ACCOUNT_ID=your_zoom_account_id
```

### Firebase Security Rules
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Meetings are readable by all authenticated users
    match /meetings/{meetingId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.teacherId == request.auth.uid || 
         !exists(/databases/$(database)/documents/meetings/$(meetingId)));
    }
    
    // Chat messages are readable by class members
    match /chat_messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Usage

### For Teachers
1. **Sign In**: Use Gmail or phone number to authenticate
2. **Create Meeting**: Tap the "+" button to create a new Zoom meeting
3. **Configure Settings**: Set meeting title, description, time, and preferences
4. **Share Meeting**: Meeting link is automatically shared via chat
5. **Manage Meetings**: View and manage all your meetings

### For Students
1. **Sign In**: Use Gmail or phone number to authenticate
2. **View Meetings**: See upcoming and live meetings
3. **Join Meetings**: Tap to join meetings seamlessly
4. **Chat**: Communicate with teachers and classmates
5. **Notifications**: Receive meeting invites and updates

## API Documentation

### Zoom Service
The `ZoomService` class handles all Zoom-related operations:

```dart
// Create a meeting
final result = await ZoomService.createMeeting(
  topic: 'Math Class',
  description: 'Algebra lesson',
  startTime: DateTime.now().add(Duration(hours: 1)),
  durationMinutes: 60,
);

// Get meeting details
final meeting = await ZoomService.getMeeting(meetingId);

// Update meeting
await ZoomService.updateMeeting(
  meetingId: meetingId,
  topic: 'Updated Title',
);
```

### Authentication Service
The `AuthService` class handles user authentication:

```dart
// Sign in with Google
final userCredential = await AuthService.signInWithGoogle();

// Sign in with phone
await AuthService.signInWithPhoneNumber(
  phoneNumber: '+1234567890',
  onCodeSent: (verificationId) => { /* Handle code sent */ },
  onError: (error) => { /* Handle error */ },
);

// Verify phone code
final userCredential = await AuthService.verifyPhoneNumber(
  verificationId: verificationId,
  smsCode: '123456',
);
```

## Troubleshooting

### Common Issues

#### Firebase Configuration
- Ensure `google-services.json` and `GoogleService-Info.plist` are in the correct locations
- Check that Firebase project settings match your app's package name
- Verify that Authentication providers are enabled

#### Zoom API Issues
- Confirm that your Zoom app has the necessary permissions
- Check that your Zoom account has API access enabled
- Verify that the Client ID, Secret, and Account ID are correct

#### Build Issues
- Run `flutter clean` and `flutter pub get` to refresh dependencies
- Ensure you're using the correct Flutter and Dart SDK versions
- Check that all platform-specific configurations are correct

### Debug Mode
Enable debug logging by setting:
```dart
// In main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Enable debug logging
  }
  runApp(MyApp());
}
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section
- Review the Firebase and Zoom documentation

## Roadmap

### Upcoming Features
- [ ] File sharing in chat
- [ ] Attendance tracking
- [ ] Meeting recordings
- [ ] Class management
- [ ] Parent notifications
- [ ] Offline support
- [ ] Multi-language support

### Performance Improvements
- [ ] Image caching optimization
- [ ] Message pagination
- [ ] Background sync
- [ ] Memory optimization

## Changelog

### Version 1.0.0
- Initial release
- Gmail and phone authentication
- Zoom meeting creation and joining
- Real-time chat
- In-app notifications
- Responsive UI design
