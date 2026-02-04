import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motivaid/core/navigation/app_router.dart';
import 'package:motivaid/core/theme/app_theme.dart';
import 'package:motivaid/core/data/sync/sync_provider.dart';

class MotivAidApp extends ConsumerWidget {
  const MotivAidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Initialize SyncService
    ref.watch(syncServiceProvider);
    
    return MaterialApp.router(
      title: 'MotivAid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
