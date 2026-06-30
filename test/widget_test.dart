import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badwallet_app/main.dart';

void main() {
  testWidgets('BadWallet app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BadWalletApp());
    // Verify that SplashScreen loads (logo BW is present)
    expect(find.text('BW'), findsOneWidget);
  });
}
