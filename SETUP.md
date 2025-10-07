# Zoom Classroom - Setup Guide

This guide will walk you through setting up the Zoom Classroom Flutter app from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK 3.0+**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK 3.0+**: Included with Flutter
- **Android Studio**: [Download here](https://developer.android.com/studio)
- **Xcode** (for iOS development): Available on Mac App Store
- **Git**: [Download here](https://git-scm.com/downloads)

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd flutter_zoom_classroom
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Firebase Setup

### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "Zoom Classroom"
4. Enable Google Analytics (optional)
5. Create project

### 3.2 Configure Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Google** provider:
   - Add your app's package name: `com.classroom.zoom`
   - Download the configuration file
3. Enable **Phone** provider:
   - Add your phone number for testing

### 3.3 Configure Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location close to your users
5. Create database

### 3.4 Configure Cloud Messaging

1. Go to **Cloud Messaging**
2. Note down the Server Key (you'll need this later)

### 3.5 Download Configuration Files

1. Go to **Project Settings** > **General**
2. Under "Your apps", click "Add app"
3. Select **Android**:
   - Package name: `com.classroom.zoom`
   - App nickname: "Zoom Classroom Android"
   - Download `google-services.json`
4. Select **iOS**:
   - Bundle ID: `com.classroom.zoom`
   - App nickname: "Zoom Classroom iOS"
   - Download `GoogleService-Info.plist`

### 3.6 Place Configuration Files

**Android:**
```bash
# Place google-services.json in:
android/app/google-services.json
```

**iOS:**
```bash
# Place GoogleService-Info.plist in:
ios/Runner/GoogleService-Info.plist
```

## Step 4: Zoom API Setup

### 4.1 Create Zoom App

1. Go to [Zoom Marketplace](https://marketplace.zoom.us/)
2. Sign in with your Zoom account
3. Click "Develop" > "Build App"
4. Choose "Server-to-Server OAuth" app type
5. Fill in app details:
   - App Name: "Zoom Classroom"
   - Company Name: Your company name
   - Developer Email: Your email
   - App Description: "Flutter app for classroom Zoom meetings"

### 4.2 Configure App Settings

1. In the app dashboard, go to **App Credentials**
2. Note down:
   - **Client ID**
   - **Client Secret**
   - **Account ID**

### 4.3 Update Zoom Configuration

1. Open `lib/services/zoom_service.dart`
2. Replace the placeholder values:

```dart
static const String _clientId = 'YOUR_ZOOM_CLIENT_ID';
static const String _clientSecret = 'YOUR_ZOOM_CLIENT_SECRET';
static const String _accountId = 'YOUR_ZOOM_ACCOUNT_ID';
```

## Step 5: Platform-Specific Setup

### 5.1 Android Setup

1. **Update build.gradle files** (already configured in the project)

2. **Add SHA-1 fingerprint** (for Google Sign-In):
   ```bash
   # Debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release keystore (when you create one)
   keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
   ```

3. **Add SHA-1 to Firebase**:
   - Go to Firebase Console > Project Settings > General
   - Under "Your apps", select your Android app
   - Add the SHA-1 fingerprint

### 5.2 iOS Setup

1. **Update Info.plist** (already configured in the project)

2. **Configure URL Schemes**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target > Info tab
   - Add URL Types if not present

3. **Enable Background Modes**:
   - In Xcode, select Runner target > Signing & Capabilities
   - Add "Background Modes"
   - Enable "Background fetch" and "Remote notifications"

## Step 6: Environment Configuration

### 6.1 Create Environment File

Create a `.env` file in the root directory:

```env
# Zoom API Configuration
ZOOM_CLIENT_ID=your_zoom_client_id
ZOOM_CLIENT_SECRET=your_zoom_client_secret
ZOOM_ACCOUNT_ID=your_zoom_account_id

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
```

### 6.2 Update .gitignore

Ensure `.env` is in your `.gitignore` file (already configured).

## Step 7: Firestore Security Rules

1. In Firebase Console, go to **Firestore Database** > **Rules**
2. Replace the default rules with the content from `firestore.rules` file
3. Publish the rules

## Step 8: Test the Setup

### 8.1 Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

### 8.2 Test Authentication

1. Try signing in with Google
2. Try signing in with phone number
3. Verify user data is created in Firestore

### 8.3 Test Zoom Integration

1. Create a test meeting (teacher role)
2. Verify meeting is created in Zoom
3. Test joining the meeting

## Step 9: Production Setup

### 9.1 Create Release Keystore (Android)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 9.2 Configure Release Signing

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 9.3 Update Build Configuration

Update `android/app/build.gradle`:

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Firebase configuration not working**:
   - Ensure configuration files are in the correct locations
   - Check that package names match exactly
   - Verify SHA-1 fingerprints are added

2. **Zoom API errors**:
   - Verify Client ID, Secret, and Account ID are correct
   - Check that your Zoom account has API access
   - Ensure the app is published in Zoom Marketplace

3. **Build errors**:
   - Run `flutter clean` and `flutter pub get`
   - Check that all dependencies are compatible
   - Verify platform-specific configurations

4. **Authentication issues**:
   - Check that Google Sign-In is properly configured
   - Verify phone number format for SMS verification
   - Ensure Firebase Authentication providers are enabled

### Debug Mode

Enable debug logging:

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

### Getting Help

1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Review [Firebase documentation](https://firebase.google.com/docs)
3. Consult [Zoom API documentation](https://marketplace.zoom.us/docs/api-reference)
4. Create an issue in the GitHub repository

## Next Steps

After successful setup:

1. **Customize the app** for your specific needs
2. **Add additional features** like file sharing, attendance tracking
3. **Deploy to app stores** (Google Play Store, Apple App Store)
4. **Set up monitoring** and analytics
5. **Configure backup and recovery** procedures

## Security Considerations

1. **Never commit sensitive data** to version control
2. **Use environment variables** for configuration
3. **Implement proper error handling** and logging
4. **Regularly update dependencies** for security patches
5. **Monitor API usage** and implement rate limiting
6. **Use HTTPS** for all API communications
7. **Implement proper authentication** and authorization

## Performance Optimization

1. **Optimize images** and assets
2. **Implement caching** strategies
3. **Use lazy loading** for large datasets
4. **Monitor memory usage** and optimize
5. **Implement offline support** where possible
6. **Use background processing** for heavy operations

## Maintenance

1. **Regular updates** of Flutter and dependencies
2. **Monitor app performance** and crash reports
3. **Update Firebase security rules** as needed
4. **Review and update Zoom API usage**
5. **Backup user data** regularly
6. **Monitor API quotas** and usage limits
