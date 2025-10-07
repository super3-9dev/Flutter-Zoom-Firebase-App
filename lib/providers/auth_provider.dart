import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication provider for managing user authentication state
class AuthProvider with ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isTeacher => _userModel?.role == UserRole.teacher;
  bool get isStudent => _userModel?.role == UserRole.student;

  /// Initialize authentication provider
  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    try {
      // Listen to Firebase auth state changes for all platforms
      AuthService.authStateChanges.listen((User? user) {
        _firebaseUser = user;
        if (user != null) {
          _loadUserModel(user.uid);
        } else {
          _userModel = null;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      // Initialize with null state if Firebase is not available
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
    }
  }

  /// Load user model from Firestore
  Future<void> _loadUserModel(String userId) async {
    try {
      _userModel = await AuthService.getUserDocument(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      
      debugPrint('AuthProvider: Starting Google Sign-In...');
      final userCredential = await AuthService.signInWithGoogle();
      
      if (userCredential != null) {
        debugPrint('AuthProvider: Google Sign-In successful');
        _firebaseUser = userCredential.user;
        if (userCredential.user != null) {
          await _loadUserModel(userCredential.user!.uid);
        }
        _setLoading(false);
        return true;
      }
      
      debugPrint('AuthProvider: Google Sign-In returned null');
      _setError('Google sign-in was cancelled or failed');
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('AuthProvider: Google Sign-In error: $e');
      _setError('Error signing in with Google: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          _setLoading(false);
          onCodeSent(verificationId);
        },
        onError: (error) {
          _setError(error);
          _setLoading(false);
          onError(error);
        },
      );
    } catch (e) {
      _setError('Error sending verification code: $e');
      _setLoading(false);
      onError('Error sending verification code: $e');
    }
  }

  /// Verify phone number
  Future<bool> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final userCredential = await AuthService.verifyPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      if (userCredential != null) {
        _firebaseUser = userCredential.user;
        if (userCredential.user != null) {
          await _loadUserModel(userCredential.user!.uid);
        }
        _setLoading(false);
        return true;
      }
      
      _setError('Invalid verification code');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error verifying code: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _firebaseUser = null;
      _userModel = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error signing out: $e');
      _setLoading(false);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      await AuthService.deleteAccount();
      _firebaseUser = null;
      _userModel = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error deleting account: $e');
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_userModel != null && _firebaseUser != null) {
      try {
        _setLoading(true);
        
        // Update Firebase user profile
        await _firebaseUser!.updateDisplayName(displayName);
        if (photoUrl != null) {
          await _firebaseUser!.updatePhotoURL(photoUrl);
        }
        
        // Update user model
        _userModel = _userModel!.copyWith(
          displayName: displayName ?? _userModel!.displayName,
          photoUrl: photoUrl ?? _userModel!.photoUrl,
        );
        
        _setLoading(false);
        notifyListeners();
      } catch (e) {
        _setError('Error updating profile: $e');
        _setLoading(false);
      }
    }
  }

  /// Update user role
  Future<void> updateUserRole(UserRole role) async {
    if (_userModel != null && _firebaseUser != null) {
      try {
        _setLoading(true);
        
        await AuthService.updateUserRole(_firebaseUser!.uid, role);
        
        _userModel = _userModel!.copyWith(role: role);
        _setLoading(false);
        notifyListeners();
      } catch (e) {
        _setError('Error updating user role: $e');
        _setLoading(false);
      }
    }
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Properties for compatibility
  String get email => _userModel?.email ?? '';
  String get roleDisplayName => _userModel?.role.toString().split('.').last ?? 'student';
  String get displayName => _userModel?.displayName ?? 'User';
  String? get photoUrl => _userModel?.photoUrl;
}