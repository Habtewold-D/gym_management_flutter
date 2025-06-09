import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gym_management_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Login flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Workouts'), findsOneWidget);
    });

    testWidgets('Workout list and detail flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify workout list is shown
      expect(find.byType(Card), findsWidgets);

      // Tap on first workout
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify workout details are shown
      expect(find.text('Workout Details'), findsOneWidget);
    });
  });
} 