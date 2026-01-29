// This is a basic Flutter widget test.
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motivaid/app.dart';
import 'package:motivaid/core/auth/models/auth_user.dart';
import 'package:motivaid/core/auth/repositories/auth_repository.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<AuthUser> signInWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUpWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('MotivAid app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MotivAidApp(),
      ),
    );
    
    // Wait for splash animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify that splash screen loads
    expect(find.text('MotivAid'), findsOneWidget);
    // Use a text matcher that handles potential line breaks or partial matches if needed,
    // but here we just match the tagline seen in SplashScreen.
    expect(find.text('Empowering Maternal Healthcare'), findsOneWidget);
  });
}
