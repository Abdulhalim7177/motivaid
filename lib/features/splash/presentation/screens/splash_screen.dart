import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// Splash Screen - First screen shown when app launches
/// Features:
/// - Rose pink gradient background
/// - Animated logo with elastic bounce
/// - App name and tagline
/// - Animated loader (pulsing circles)
/// - Authentication buttons (appear after loader)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loaderAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonFadeAnimation;

  bool _showLoader = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Loader animation controller (continuous)
    _loaderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoAnimationController.forward();
  }

  void _startSequence() {
    // Show loader after logo animation
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showLoader = true;
        });
      }
    });

    // Show buttons after loader displays for a bit
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        setState(() {
          _showLoader = false;
          _showButtons = true;
        });
      }
    });
  }

  void _handleLogin() {
    // TODO: Navigate to login screen
    debugPrint('Navigate to Login');
  }

  void _handleRegister() {
    // TODO: Navigate to registration screen
    debugPrint('Navigate to Register');
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loaderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.roseGradient,
          ),
        ),
        child: SafeArea(
          child: _showLoader && !_showButtons
              ? // Show only centered loader
              Center(
                  child: _buildAnimatedLoader(),
                )
              : // Show all content together
              LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(height: 20),

                                // Top section: Logo, Name, Tagline
                                Expanded(
                                  flex: 3,
                                  child: FadeTransition(
                                    opacity: _buttonFadeAnimation,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Animated Logo
                                        _buildLogo(),

                                        SizedBox(height: screenHeight * 0.03),

                                        // App Name
                                        Text(
                                          'MotivAid',
                                          style: AppTextStyles.h1.copyWith(
                                            color: AppColors.textOnPrimary,
                                            fontSize: screenWidth * 0.1,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),

                                        SizedBox(height: screenHeight * 0.015),

                                        // Tagline
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0,
                                          ),
                                          child: Text(
                                            'Saving Lives, One Delivery at a Time',
                                            style: AppTextStyles.subtitle1.copyWith(
                                              color: AppColors.textOnPrimary
                                                  .withOpacity(0.95),
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Bottom section: Buttons
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_showButtons)
                                        FadeTransition(
                                          opacity: _buttonFadeAnimation,
                                          child: _buildAuthButtons(screenWidth),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.favorite,
          size: 60,
          color: AppColors.primaryRose,
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing circle (background glow effect)
          AnimatedBuilder(
            animation: _loaderAnimationController,
            builder: (context, child) {
              final pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(
                  parent: _loaderAnimationController,
                  curve: Curves.easeInOut,
                ),
              );
              
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textOnPrimary.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
          
          // Main circular loader with gradient
          AnimatedBuilder(
            animation: _loaderAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _loaderAnimationController.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.textOnPrimary,
                        AppColors.textOnPrimary.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Inner circle (creates ring effect)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRose,
            ),
          ),
          
          // Center loading icon (optional heart pulse)
          AnimatedBuilder(
            animation: _loaderAnimationController,
            builder: (context, child) {
              final heartPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
                CurvedAnimation(
                  parent: _loaderAnimationController,
                  curve: Curves.easeInOut,
                ),
              );
              
              return Transform.scale(
                scale: heartPulse.value,
                child: Icon(
                  Icons.favorite,
                  size: 24,
                  color: AppColors.textOnPrimary.withOpacity(0.9),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButtons(double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.primaryRose,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Login',
              style: AppTextStyles.button.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Register Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _handleRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textOnPrimary,
              side: const BorderSide(
                color: AppColors.textOnPrimary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Register',
              style: AppTextStyles.button.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
