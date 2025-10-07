import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import 'phone_verification_screen.dart';

/// Login screen with Google and phone number authentication options
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Listen to authentication state changes and navigate when authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authProvider.isAuthenticated && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        });

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                const SizedBox(height: 60),
                
                // App Logo and Title
                _buildHeader(),
                
                const SizedBox(height: 60),
                
                // Welcome Text
                _buildWelcomeText(),
                
                const SizedBox(height: 40),
                
                // Phone Number Input
                _buildPhoneInput(),
                
                const SizedBox(height: 30),
                
                // Continue with Phone Button
                _buildPhoneButton(),
                
                const SizedBox(height: 20),
                
                // Divider
                _buildDivider(),
                
                const SizedBox(height: 20),
                
                // Google Sign In Button
                _buildGoogleButton(),
                
                const SizedBox(height: 30),
                
                // Terms and Privacy
                _buildTermsText(),
                
                const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.video_call,
            size: 50,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Zoom Classroom',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Connect with your classroom',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Sign in to continue to your classroom',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        CustomTextField(
          controller: _phoneController,
          hintText: '+1 (555) 123-4567',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
          onChanged: (value) {
            setState(() {
              _isPhoneValid = _validatePhoneNumber(value);
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!_validatePhoneNumber(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'Continue with Phone',
          onPressed: _isPhoneValid && !authProvider.isLoading
              ? () => _handlePhoneSignIn(authProvider)
              : null,
          isLoading: authProvider.isLoading,
          icon: Icons.phone,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.textHintColor.withOpacity(0.3),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textHintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.textHintColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isEnabled = !authProvider.isLoading;
        
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isEnabled ? () => _handleGoogleSignIn(authProvider) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textPrimaryColor,
              elevation: isEnabled ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppTheme.textHintColor.withOpacity(0.3)),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGoogleIcon(),
                      const SizedBox(width: 8),
                      Text(
                        'Continue with Google',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      child: Image.asset(
        'assets/icons/google.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.textHintColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  bool _validatePhoneNumber(String phone) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }

  void _handlePhoneSignIn(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();
    
    authProvider.signInWithPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhoneVerificationScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      onError: (error) {
        _showErrorSnackBar(error);
      },
    );
  }

  void _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();
    if (mounted) {
      if (success) {
        _showSuccessToast('Welcome! Sign-in successful');
        // Navigation will be handled by AuthProvider state changes
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Google sign-in failed');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
