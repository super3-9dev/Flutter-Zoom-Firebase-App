import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Authentication service handling Firebase Auth, Google Sign-In, and phone authentication
/// Uses real Firebase for mobile, mock for web
class AuthService {
  // Firebase instances - available on all platforms with error handling
  static FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Error getting Firebase Auth instance: $e');
      return null;
    }
  }
  
  static FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Error getting Firestore instance: $e');
      return null;
    }
  }
  
  static GoogleSignIn? get _googleSignIn => kIsWeb ? null : GoogleSignIn(
    scopes: ['openid', 'profile', 'email'],
  );

  /// Get current user
  static User? get currentUser => _auth?.currentUser;

  /// Get current user stream
  static Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? Stream.value(null);
    } catch (e) {
      debugPrint('Error getting auth state changes: $e');
      return Stream.value(null);
    }
  }

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web implementation for Google Sign-In
      try {
        debugPrint('Starting Google Sign-In for web...');
        
        // Use the web client ID from Firebase configuration
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: '366792053793-jnpnkdegi1f27rti468ctde4um88jv1d.apps.googleusercontent.com',
          scopes: ['openid', 'profile', 'email'],
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          debugPrint('Google Sign-In was cancelled by user (web)');
          return null;
        }
        
        debugPrint('Google user signed in (web): ${googleUser.email}');
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // For web, we can use access token even if idToken is null
        if (googleAuth.accessToken == null) {
          debugPrint('Failed to obtain Google access token (web)');
          return null;
        }
        
        // Create Firebase credential - use access token and handle null idToken
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken, // This can be null on web
        );
        
        // Sign in to Firebase
        if (_auth == null) {
          debugPrint('Firebase Auth not available');
          return null;
        }
        final UserCredential userCredential = 
            await _auth!.signInWithCredential(credential);
        
        debugPrint('Firebase authentication successful (web): ${userCredential.user?.email}');
        
        // Create or update user document
        if (userCredential.user != null) {
          await _createOrUpdateUserDocumentWeb(userCredential.user!);
        }
        
        return userCredential;
      } catch (e) {
        debugPrint('Error signing in with Google (web): $e');
        return null;
      }
    }
    
    try {
      debugPrint('Starting Google Sign-In process...');
      
      // Check if Google Sign-In is available
      if (_googleSignIn == null) {
        debugPrint('Google Sign-In not available on this platform');
        return null;
      }
      
      // Trigger the authentication flow
      debugPrint('Triggering Google Sign-In authentication flow...');
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        debugPrint('Google Sign-In was cancelled by user');
        return null;
      }
      
      debugPrint('Google user signed in: ${googleUser.email}');
      
      // Obtain the auth details from the request
      debugPrint('Obtaining Google authentication details...');
      final GoogleSignInAuthentication? googleAuth = 
          await googleUser.authentication;
      
      if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
        debugPrint('Failed to obtain Google authentication tokens');
        return null;
      }
      
      debugPrint('Creating Firebase credential with Google tokens...');
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      debugPrint('Signing in to Firebase with Google credential...');
      if (_auth == null) {
        debugPrint('Firebase Auth not available');
        return null;
      }
      final UserCredential userCredential = 
          await _auth!.signInWithCredential(credential);
      
      debugPrint('Firebase authentication successful: ${userCredential.user?.email}');
      
      // Create or update user document
      if (userCredential.user != null) {
        debugPrint('Creating/updating user document in Firestore...');
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      debugPrint('Google Sign-In completed successfully');
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('Exception details: ${e.toString()}');
      }
      return null;
    }
  }

  /// Sign in with phone number
  static Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    if (kIsWeb) {
      // Mock implementation for web - phone auth not fully supported on web
      await Future.delayed(const Duration(seconds: 1));
      onCodeSent('mock_verification_id');
      return;
    }
    
    if (_auth == null) {
      onError('Firebase Auth not available');
      return;
    }
    
    try {
      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          final UserCredential userCredential = 
              await _auth!.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _createOrUpdateUserDocument(userCredential.user!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Error sending verification code: $e');
    }
  }

  /// Verify phone number with SMS code
  static Future<UserCredential?> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    if (kIsWeb) {
      // Mock implementation for web
      await Future.delayed(const Duration(seconds: 1));
      return null;
    }
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      if (_auth == null) {
        debugPrint('Firebase Auth not available for phone verification');
        return null;
      }
      final UserCredential userCredential = 
          await _auth!.signInWithCredential(credential);
      
      // Create or update user document
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error verifying SMS code: $e');
      return null;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    if (kIsWeb) {
      // Mock implementation for web
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    
    if (_auth != null) {
      await Future.wait([
        _auth!.signOut(),
        _googleSignIn?.signOut() ?? Future.value(),
      ]);
    }
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    if (kIsWeb) {
      // Mock implementation for web
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    
    if (_auth == null) {
      debugPrint('Firebase Auth not available for account deletion');
      return;
    }
    final user = _auth!.currentUser;
    if (user != null) {
      // Delete user document from Firestore
      if (_firestore != null) {
        await _firestore!.collection('users').doc(user.uid).delete();
      }
      
      // Delete user account
      await user.delete();
    }
  }

  /// Create or update user document in Firestore (Public method)
  static Future<void> createOrUpdateUserDocument(UserModel userModel) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('users')
            .doc(userModel.id)
            .set(userModel.toFirestore(), SetOptions(merge: true));
        debugPrint('User document created/updated successfully');
      }
    } catch (e) {
      debugPrint('Error creating/updating user document: $e');
      rethrow;
    }
  }

  /// Create or update user document in Firestore (Web version)
  static Future<void> _createOrUpdateUserDocumentWeb(User firebaseUser) async {
    try {
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL,
        role: UserRole.student, // Default role
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      if (_firestore != null) {
        await _firestore!.collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error creating/updating user document (web): $e');
    }
  }

  /// Create or update user document in Firestore
  static Future<void> _createOrUpdateUserDocument(User firebaseUser) async {
    if (kIsWeb) {
      // Use web version
      await _createOrUpdateUserDocumentWeb(firebaseUser);
      return;
    }
    
    try {
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        photoUrl: firebaseUser.photoURL,
        role: UserRole.student, // Default role
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      if (_firestore != null) {
        await _firestore!
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error creating/updating user document: $e');
    }
  }

  /// Get user document from Firestore
  static Future<UserModel?> getUserDocument(String userId) async {
    try {
      if (_firestore == null) {
        debugPrint('Firestore not available');
        return null;
      }
      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      debugPrint('User document does not exist for userId: $userId');
      return null;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  /// Update user role
  static Future<void> updateUserRole(String userId, UserRole role) async {
    if (kIsWeb) {
      // Mock implementation for web
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    
    try {
      if (_firestore == null) {
        debugPrint('Firestore not available for role update');
        return;
      }
      await _firestore!.collection('users').doc(userId).update({
        'role': role.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating user role: $e');
    }
  }

  /// Update user online status
  static Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    if (kIsWeb) {
      // Mock implementation for web
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    
    try {
      if (_firestore == null) {
        debugPrint('Firestore not available for status update');
        return;
      }
      await _firestore!.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating user online status: $e');
    }
  }

  /// Get user stream from Firestore
  static Stream<UserModel?> getUserStream(String userId) {
    if (kIsWeb) {
      // Mock implementation for web
      return Stream.value(null);
    }
    
    if (_firestore == null) {
      return Stream.value(null);
    }
    return _firestore!
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth?.currentUser != null;

  /// Get current user ID
  static String? get currentUserId => _auth?.currentUser?.uid;

  /// Get current user email
  static String? get currentUserEmail => _auth?.currentUser?.email;

  /// Get current user display name
  static String? get currentUserDisplayName => _auth?.currentUser?.displayName;

  /// Get current user photo URL
  static String? get currentUserPhotoUrl => _auth?.currentUser?.photoURL;
}
