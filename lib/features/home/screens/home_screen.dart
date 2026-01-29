import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/profile/providers/profile_provider.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/features/profile/screens/profile_view_screen.dart';
import 'package:motivaid/features/settings/screens/settings_screen.dart';
import 'package:motivaid/features/dashboard/screens/midwife_dashboard.dart';
import 'package:motivaid/features/dashboard/screens/supervisor_dashboard.dart';
import 'package:motivaid/features/supervisor/screens/my_facilities_screen.dart';
import 'package:motivaid/features/supervisor/screens/supervisor_approval_screen.dart';
import 'package:motivaid/features/patients/screens/patients_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const Scaffold(body: Center(child: Text('Profile not found')));

        final isSupervisor = profile.role.toString().contains('supervisor') || 
                           profile.role.toString().contains('admin');

        // Define tabs based on role
        final List<Widget> screens;
        final List<BottomNavigationBarItem> items;

        if (isSupervisor) {
          screens = const [
            SupervisorDashboard(),
            MyFacilitiesScreen(),
            SupervisorApprovalScreen(),
            ProfileViewScreen(),
            SettingsScreen(),
          ];
          items = const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Facilities'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Approvals'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ];
        } else {
          screens = const [
            MidwifeDashboard(),
            PatientsListScreen(),
            ProfileViewScreen(),
            SettingsScreen(),
          ];
          items = const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ];
        }

        // Ensure index is valid
        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            
            if (_currentIndex != 0) {
              _onTabTapped(0);
              return;
            }
            
            // Show exit confirmation dialog
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            
            if (shouldExit == true) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              selectedItemColor: AppColors.primaryPurple,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: items,
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
