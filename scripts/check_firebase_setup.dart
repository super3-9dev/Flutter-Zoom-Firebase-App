#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script to check Firebase setup configuration
void main(List<String> args) async {
  print('🔥 Firebase Setup Verification\n');

  bool allGood = true;

  // Check Android Firebase config
  print('📱 Checking Android Firebase Configuration...');
  final androidConfig = File('android/app/google-services.json');
  if (await androidConfig.exists()) {
    try {
      final content = await androidConfig.readAsString();
      final config = jsonDecode(content);
      
      final projectId = config['project_info']?['project_id'];
      final projectNumber = config['project_info']?['project_number'];
      
      print('✅ Android config found');
      print('   Project ID: $projectId');
      print('   Project Number: $projectNumber');
      
      if (projectId == 'zoom-classroom-f77fc') {
        print('✅ Project ID matches expected value');
      } else {
        print('⚠️  Project ID mismatch. Expected: zoom-classroom-f77fc');
        allGood = false;
      }
      
    } catch (e) {
      print('❌ Error reading Android config: $e');
      allGood = false;
    }
  } else {
    print('❌ Android Firebase config missing: android/app/google-services.json');
    allGood = false;
  }

  print('');

  // Check iOS Firebase config
  print('🍎 Checking iOS Firebase Configuration...');
  final iosConfig = File('ios/Runner/GoogleService-Info.plist');
  if (await iosConfig.exists()) {
    try {
      final content = await iosConfig.readAsString();
      
      if (content.contains('CLIENT_ID') && content.contains('API_KEY')) {
        print('✅ iOS config found');
        print('   Contains CLIENT_ID and API_KEY');
      } else {
        print('⚠️  iOS config may be incomplete');
        allGood = false;
      }
    } catch (e) {
      print('❌ Error reading iOS config: $e');
      allGood = false;
    }
  } else {
    print('❌ iOS Firebase config missing: ios/Runner/GoogleService-Info.plist');
    allGood = false;
  }

  print('');

  // Check Flutter dependencies
  print('📦 Checking Flutter Dependencies...');
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    try {
      final content = await pubspec.readAsString();
      
      final requiredDeps = [
        'firebase_core:',
        'firebase_auth:',
        'cloud_firestore:',
        'google_sign_in:',
        'provider:',
      ];
      
      bool depsGood = true;
      for (final dep in requiredDeps) {
        if (content.contains(dep)) {
          print('✅ $dep found');
        } else {
          print('❌ $dep missing');
          depsGood = false;
          allGood = false;
        }
      }
      
    } catch (e) {
      print('❌ Error reading pubspec.yaml: $e');
      allGood = false;
    }
  } else {
    print('❌ pubspec.yaml not found');
    allGood = false;
  }

  print('');

  // Check project structure
  print('📁 Checking Project Structure...');
  final requiredFiles = [
    'lib/main.dart',
    'lib/firebase_options.dart',
    'lib/models/user_model.dart',
    'lib/services/auth_service.dart',
    'lib/providers/auth_provider.dart',
    'lib/screens/auth/login_screen.dart',
    'lib/screens/auth/role_selection_screen.dart',
    'lib/screens/home/home_screen.dart',
    'firestore.rules',
  ];
  
  for (final file in requiredFiles) {
    if (await File(file).exists()) {
      print('✅ $file exists');
    } else {
      print('❌ $file missing');
      allGood = false;
    }
  }

  print('');

  // Summary
  print('📋 Firebase Setup Status:');
  if (allGood) {
    print('🎉 All configuration files are present and correct!');
    print('');
    print('Next steps:');
    print('1. Go to Firebase Console: https://console.firebase.google.com/');
    print('2. Select project: zoom-classroom-f77fc');
    print('3. Enable Authentication providers (Google + Phone)');
    print('4. Create Firestore database');
    print('5. Deploy security rules from firestore.rules');
    print('6. Run: flutter run -d chrome');
  } else {
    print('⚠️  Some configuration issues found.');
    print('Please fix the issues above before proceeding.');
  }

  print('');
  print('📖 For detailed setup instructions, see:');
  print('- DETAILED_SETUP_GUIDE.md');
  print('- FIRST_MILESTONE_COMPLETION.md');
}
