#!/usr/bin/env dart

import 'dart:io';

/// Script to verify Flutter project setup
void main(List<String> args) async {
  print('🔍 Verifying Flutter Zoom Firebase App Setup...\n');

  bool allGood = true;

  // Check Flutter installation
  print('📱 Checking Flutter installation...');
  try {
    final result = await Process.run('flutter', ['--version']);
    if (result.exitCode == 0) {
      print('✅ Flutter is installed');
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.contains('Flutter')) {
          print('   $line');
          break;
        }
      }
    } else {
      print('❌ Flutter is not installed or not in PATH');
      allGood = false;
    }
  } catch (e) {
    print('❌ Error checking Flutter: $e');
    allGood = false;
  }

  print('');

  // Check Firebase configuration files
  print('🔥 Checking Firebase configuration...');
  
  final androidConfig = File('android/app/google-services.json');
  final iosConfig = File('ios/Runner/GoogleService-Info.plist');
  
  if (await androidConfig.exists()) {
    print('✅ Android Firebase config found: google-services.json');
  } else {
    print('❌ Android Firebase config missing: google-services.json');
    allGood = false;
  }
  
  if (await iosConfig.exists()) {
    print('✅ iOS Firebase config found: GoogleService-Info.plist');
  } else {
    print('❌ iOS Firebase config missing: GoogleService-Info.plist');
    allGood = false;
  }

  print('');

  // Check project dependencies
  print('📦 Checking project dependencies...');
  try {
    final result = await Process.run('flutter', ['pub', 'get']);
    if (result.exitCode == 0) {
      print('✅ Dependencies installed successfully');
    } else {
      print('❌ Failed to install dependencies');
      print('   Error: ${result.stderr}');
      allGood = false;
    }
  } catch (e) {
    print('❌ Error installing dependencies: $e');
    allGood = false;
  }

  print('');

  // Check for common issues
  print('🔧 Checking for common issues...');
  
  // Check if assets exist
  final googleIcon = File('assets/icons/google.png');
  if (await googleIcon.exists()) {
    print('✅ Google icon asset found');
  } else {
    print('❌ Google icon asset missing: assets/icons/google.png');
    allGood = false;
  }

  // Check pubspec.yaml
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();
    if (content.contains('firebase_core')) {
      print('✅ Firebase dependencies found in pubspec.yaml');
    } else {
      print('❌ Firebase dependencies missing in pubspec.yaml');
      allGood = false;
    }
  } else {
    print('❌ pubspec.yaml not found');
    allGood = false;
  }

  print('');

  // Summary
  print('📋 Setup Verification Summary:');
  if (allGood) {
    print('🎉 All checks passed! Your project is ready to run.');
    print('');
    print('Next steps:');
    print('1. Run: flutter run');
    print('2. Test Google Sign-In');
    print('3. Test Phone authentication');
    print('4. Verify Firestore operations');
  } else {
    print('⚠️  Some issues were found. Please fix them before running the app.');
    print('');
    print('Common fixes:');
    print('1. Install Flutter: https://flutter.dev/docs/get-started/install');
    print('2. Add Firebase config files to the correct locations');
    print('3. Run: flutter pub get');
    print('4. Add missing assets to assets/icons/');
  }

  print('');
  print('For detailed setup instructions, see:');
  print('- README.md');
  print('- PROJECT_SETUP_GUIDE.md');
  print('- SETUP.md');
}
