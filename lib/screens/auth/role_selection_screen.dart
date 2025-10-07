import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

/// Screen for selecting user role after authentication
class RoleSelectionScreen extends StatefulWidget {
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: 60),
              
              // Role Selection
              _buildRoleSelection(),
              
              const SizedBox(height: 40),
              
              // Continue Button
              _buildContinueButton(),
              
              const SizedBox(height: 20),
              
              // Terms
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // User Avatar
        CircleAvatar(
          radius: 50,
          backgroundImage: widget.photoUrl != null 
              ? NetworkImage(widget.photoUrl!)
              : null,
          child: widget.photoUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: AppTheme.primaryColor,
                )
              : null,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Welcome, ${widget.displayName}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Please select your role to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Teacher Option
        _buildRoleOption(
          role: UserRole.teacher,
          title: 'Teacher',
          subtitle: 'Create and manage classes and meetings',
          icon: Icons.school,
          color: AppTheme.primaryColor,
        ),
        
        const SizedBox(height: 16),
        
        // Student Option
        _buildRoleOption(
          role: UserRole.student,
          title: 'Student',
          subtitle: 'Join classes and attend meetings',
          icon: Icons.person,
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppTheme.textHintColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppTheme.textPrimaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            Radio<UserRole>(
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'Continue',
          onPressed: authProvider.isLoading
              ? null
              : () => _handleContinue(authProvider),
          isLoading: authProvider.isLoading,
        );
      },
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Your role can be changed later in profile settings',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.textHintColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleContinue(AuthProvider authProvider) async {
    try {
      // Create user document with selected role
      final userModel = UserModel(
        id: authProvider.firebaseUser!.uid,
        email: widget.email,
        phoneNumber: widget.phoneNumber,
        displayName: widget.displayName,
        photoUrl: widget.photoUrl,
        role: _selectedRole,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      // Save user to Firestore
      await authProvider.createUserDocument(userModel);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
