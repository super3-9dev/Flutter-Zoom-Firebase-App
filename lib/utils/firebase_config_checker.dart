import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to check Firebase configuration and connectivity
class FirebaseConfigChecker {
  static bool _isConfigured = false;
  static String? _lastError;

  /// Check if Firebase is properly configured
  static Future<bool> isFirebaseConfigured() async {
    try {
      // Check if Firebase is initialized
      final app = Firebase.app();
      debugPrint('Firebase app initialized: ${app.name}');

      // Check Firebase Auth
      final auth = FirebaseAuth.instance;
      debugPrint('Firebase Auth available: ${auth.app.name}');

      // Check Firestore
      final firestore = FirebaseFirestore.instance;
      debugPrint('Firestore available: ${firestore.app.name}');

      _isConfigured = true;
      _lastError = null;
      return true;
    } catch (e) {
      _isConfigured = false;
      _lastError = e.toString();
      debugPrint('Firebase configuration error: $e');
      return false;
    }
  }

  /// Test Firestore connectivity
  static Future<bool> testFirestoreConnection() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to read a test document
      await firestore.collection('_test').doc('connection').get();
      
      debugPrint('Firestore connection test successful');
      return true;
    } catch (e) {
      debugPrint('Firestore connection test failed: $e');
      return false;
    }
  }

  /// Test Firebase Auth
  static Future<bool> testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      
      // Check current user
      final user = auth.currentUser;
      debugPrint('Firebase Auth test successful. Current user: ${user?.uid ?? 'None'}');
      
      return true;
    } catch (e) {
      debugPrint('Firebase Auth test failed: $e');
      return false;
    }
  }

  /// Get configuration status
  static bool get isConfigured => _isConfigured;
  
  /// Get last error
  static String? get lastError => _lastError;

  /// Run all configuration checks
  static Future<Map<String, bool>> runAllChecks() async {
    final results = <String, bool>{};
    
    results['firebase_configured'] = await isFirebaseConfigured();
    results['firestore_connection'] = await testFirestoreConnection();
    results['firebase_auth'] = await testFirebaseAuth();
    
    return results;
  }

  /// Print configuration status
  static Future<void> printStatus() async {
    debugPrint('=== Firebase Configuration Status ===');
    
    final results = await runAllChecks();
    
    for (final entry in results.entries) {
      final status = entry.value ? '✅' : '❌';
      debugPrint('$status ${entry.key}: ${entry.value}');
    }
    
    if (_lastError != null) {
      debugPrint('❌ Last Error: $_lastError');
    }
    
    debugPrint('=====================================');
  }
}
