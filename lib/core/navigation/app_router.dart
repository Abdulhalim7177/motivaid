import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/auth/models/auth_state.dart';
import 'package:motivaid/core/units/providers/unit_membership_provider.dart';
import 'package:motivaid/features/auth/screens/login_screen.dart';
import 'package:motivaid/features/auth/screens/signup_screen.dart';
import 'package:motivaid/features/auth/screens/pending_approval_screen.dart';
import 'package:motivaid/features/home/screens/home_screen.dart';
import 'package:motivaid/features/profile/screens/profile_view_screen.dart';
import 'package:motivaid/features/settings/screens/settings_screen.dart';
import 'package:motivaid/features/supervisor/screens/my_facilities_screen.dart';
import 'package:motivaid/features/supervisor/screens/supervisor_approval_screen.dart';
import 'package:motivaid/features/splash/screens/splash_screen.dart';
import 'package:motivaid/features/patients/screens/patients_list_screen.dart';
import 'package:motivaid/features/patients/screens/add_patient_screen.dart';
import 'package:motivaid/features/patients/screens/patient_detail_screen.dart';
import 'package:motivaid/features/patients/screens/edit_patient_screen.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;
      
      // Allow splash screen initially - but check auth and redirect if needed
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState is AuthStateAuthenticated;
      final isLoggingIn = currentPath == '/login';
      final isSigningUp = currentPath == '/signup';
      final isOnSplash = currentPath == '/splash';
      
      // If on splash and authenticated, redirect to appropriate page
      if (isOnSplash && isLoggedIn) {
        // Check membership status
        try {
          final user = authState.user;
          final membershipRepo = ref.read(unitMembershipRepositoryProvider);
          final memberships = await membershipRepo.getMembershipsByProfile(user.id);
          final hasApprovedMembership = memberships.any((m) => m.isApproved);
          
          return hasApprovedMembership ? '/dashboard' : '/pending';
        } catch (e) {
          // If check fails (e.g. offline), default to dashboard
          // This ensures offline users aren't stuck on splash
          return '/dashboard';
        }
      }
      
      // Allow splash for unauthenticated users
      if (isOnSplash) {
        return null;
      }
      
      // Not logged in - redirect to login (except for splash, login, signup)
      if (!isLoggedIn) {
        if (isLoggingIn || isSigningUp) return null;
        return '/login';
      }
      
      // Logged in - check membership status for protected routes
      try {
        final user = authState.user;
        final membershipRepo = ref.read(unitMembershipRepositoryProvider);
        final memberships = await membershipRepo.getMembershipsByProfile(user.id);
        final hasApprovedMembership = memberships.any((m) => m.isApproved);
        
        // If no approved membership, show pending screen
        if (!hasApprovedMembership) {
          if (currentPath == '/pending') return null;
          return '/pending';
        }
      } catch (e) {
        // Offline or error: Assume approved (or check local cache if we had one)
        // Default to allowing access so offline users aren't blocked
      }
      
      // Logged in with approved membership - redirect to dashboard if on auth screens
      if (isLoggingIn || isSigningUp || currentPath == '/pending') {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/pending',
        name: 'pending',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileViewScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/supervisor/approvals',
        name: 'supervisor-approvals',
        builder: (context, state) => const SupervisorApprovalScreen(),
      ),
      GoRoute(
        path: '/supervisor/facilities',
        name: 'supervisor-facilities',
        builder: (context, state) => const MyFacilitiesScreen(),
      ),
      GoRoute(
        path: '/patients',
        name: 'patients',
        builder: (context, state) => const PatientsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-patient',
            builder: (context, state) => const AddPatientScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'patient-detail',
            builder: (context, state) {
              final patientId = state.pathParameters['id']!;
              return PatientDetailScreen(patientId: patientId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-patient',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return EditPatientScreen(patientId: patientId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// A [Listenable] that notifies when a [Stream] emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}