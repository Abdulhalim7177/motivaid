import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/widgets/gradient_button.dart';
import 'package:motivaid/features/auth/widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final canCheck = await biometricService.isDeviceSupported();
    if (mounted) {
      setState(() => _canCheckBiometrics = canCheck);
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final biometricService = ref.read(biometricAuthServiceProvider);
      
      await authNotifier.loginWithBiometrics(biometricService);
      
      if (mounted) {
        setState(() => _isLoading = false);
        // If state is authenticated, router will redirect.
        // If error, it's in the state, but we might want to show snackbar
        final authState = ref.read(authNotifierProvider);
        if (authState is AuthStateError) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.message), backgroundColor: AppColors.highRisk),
          );
        } else if (authState is AuthStateAuthenticated) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric login successful!'), backgroundColor: AppColors.lowRisk),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric auth failed: $e'), backgroundColor: AppColors.highRisk),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Success! Show message
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Login successful! Redirecting...'),
              ],
            ),
            backgroundColor: AppColors.lowRisk,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Give user time to see the message before router redirects
        await Future.delayed(const Duration(milliseconds: 800));
        // Router will automatically redirect based on membership status
      }
    } catch (e) {
      // Reset loading on error
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

  void _navigateToSignUp() {
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/splash');
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/motivaid-logo.png',
                        fit: BoxFit.contain,
                        color: Colors.white, // Assuming logo can take tint, or remove if original colors preferred
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Welcome Text
                  const Text(
                    'Welcome Back',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    labelText: 'Email or Phone',
                    hintText: 'Enter your email or phone',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person_outline,
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

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                  
                  // Remember me & Forgot Password
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          activeColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  GradientButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  // Social Login
                  if (_canCheckBiometrics) ...[
                    const SizedBox(height: 4),
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('or continue with'),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.fingerprint, 
                          onTap: _handleBiometricLogin,
                          label: 'Biometrics',
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: Text(
                          'Sign Up',
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
  
  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap, String? label}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: AppColors.textDark),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
