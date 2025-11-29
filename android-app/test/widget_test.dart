import 'package:android_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Provide minimal env for tests with biometric disabled
    dotenv.testLoad(fileInput: 'DISABLE_BIOMETRIC=true');
  });

  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Pass a dummy observer to avoid Firebase initialization
    await tester.pumpWidget(ProviderScope(
      child: MyApp(navigatorObserver: NavigatorObserver()),
    ));
    await tester.pump();

    // Initial frame (splash) - only logo is visible
    expect(find.byWidgetPredicate((widget) => widget is Image), findsAtLeastNWidgets(1));

    // Verify app loaded successfully
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));

    // Let timers and navigation complete
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}