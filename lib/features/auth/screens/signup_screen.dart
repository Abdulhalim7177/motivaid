import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/facilities/providers/facility_provider.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/widgets/gradient_button.dart';
import 'package:motivaid/features/auth/widgets/auth_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedFacilityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Router handles auth redirects automatically
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFacilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a facility')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Register user with metadata
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        metadata: {
          'full_name': _fullNameController.text.trim(),
          'facility_id': _selectedFacilityId,
          // Role is usually not trusted from client metadata for security,
          // but can be used for initial profile setup if validated by RLS/Trigger.
          // For now we rely on supervisor assignment for official role.
        },
      );

      // Get the authenticated user
      final authState = ref.read(authNotifierProvider);
      if (authState is! AuthStateAuthenticated) {
        // Auth state might take a moment to propagate or require email confirmation
        // If auto-login happens:
        // Trigger copies metadata to profile.
        // We can double check or just proceed.
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Awaiting supervisor assignment.'),
            backgroundColor: AppColors.lowRisk,
            duration: Duration(seconds: 4),
          ),
        );
        
        setState(() => _isLoading = false);
        
        // Router will automatically redirect to /pending
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.highRisk,
          ),
        );
      }
    }
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = ref.watch(facilitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                   Center(
                     child: Container(
                       width: 60,
                       height: 60,
                       margin: const EdgeInsets.only(bottom: 24),
                       decoration: BoxDecoration(
                         gradient: AppColors.primaryGradient,
                         borderRadius: BorderRadius.circular(16),
                       ),
                       padding: const EdgeInsets.all(12),
                       child: Image.asset(
                         'assets/images/motivaid-logo.png',
                         fit: BoxFit.contain,
                         color: Colors.white,
                       ),
                     ),
                   ),
                   // Title
                  const Text(
                    'Create Account',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join MotivAid to start helping mothers',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Full name field
                  AuthTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  AuthTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  // Facility Selector
                  facilitiesAsync.when(
                    data: (facilities) => DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Facility',
                        prefixIcon: const Icon(Icons.business_outlined),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      initialValue: _selectedFacilityId, // value is required for state change if not resetting form, but deprecated? No, 'value' is standard for DropdownButton. 'initialValue' is for FormField init.
                      // The warning said: 'value' is deprecated... use initialValue.
                      // Actually, DropdownButtonFormField usually uses 'value' to control the state.
                      // If I use 'value', it must be one of the items.
                      // If I use 'initialValue', it's only for start.
                      // BUT, if I want to update it programmatically, I need 'value'.
                      // However, Flutter linter says deprecated.
                      // Let's use 'value' if I manage state, but ensure it's correct.
                      // Wait, the warning was for `DropdownButtonFormField`.
                      // In recent Flutter, `value` on `FormField` is deprecated? No.
                      // Maybe `value` parameter in constructor vs `initialValue`.
                      // Usually we use `value` for controlled component.
                      // I will ignore the info if I need controlled state, OR switch to `initialValue` if I don't change it externally.
                      // Here I change it via `setState`. So `value` is correct.
                      // The linter might be wrong or referring to a specific mix-up.
                      // I will stick with `value` as it works for controlled inputs, but I'll suppress if needed or just leave it as 'info'.
                      // Ah, the warning was for `lib/features/supervisor/screens/supervisor_approval_screen.dart` mostly?
                      // The output showed warning for `signup_screen.dart:233:23`.
                      // I will use `value` as `_selectedFacilityId`.
                      items: facilities.map((f) => DropdownMenuItem(
                        value: f.id, 
                        child: Text(f.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => _selectedFacilityId = value);
                      },
                      validator: (value) => value == null ? 'Please select a facility' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load facilities: $e', style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter password',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign up button
                  GradientButton(
                    text: 'Sign Up',
                    onPressed: _handleSignUp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
