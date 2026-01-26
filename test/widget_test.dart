// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';

import 'package:motivaid/app.dart';

void main() {
  testWidgets('MotivAid app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MotivAidApp());

    // Verify that splash screen loads
    expect(find.text('MotivAid'), findsOneWidget);
    expect(find.text('Saving Lives, One Delivery at a Time'), findsOneWidget);
  });
}
