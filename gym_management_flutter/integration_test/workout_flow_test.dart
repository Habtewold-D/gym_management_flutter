import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gym_management_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Flow Tests', () {
    testWidgets('Complete workout flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Navigate to workouts
      expect(find.text('Workouts'), findsOneWidget);
      await tester.pumpAndSettle();

      // Verify workout list
      expect(find.byType(Card), findsWidgets);
      final firstWorkout = find.byType(Card).first;
      await tester.tap(firstWorkout);
      await tester.pumpAndSettle();

      // Verify workout details
      expect(find.text('Workout Details'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Test exercise list
      expect(find.byType(ListTile), findsWidgets);
      final firstExercise = find.byType(ListTile).first;
      await tester.tap(firstExercise);
      await tester.pumpAndSettle();

      // Verify exercise details
      expect(find.text('Exercise Details'), findsOneWidget);
    });

    testWidgets('Workout search and filter test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'Morning');
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);

      // Test filter functionality
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Workout bookmark and history test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Bookmark a workout
      final firstWorkout = find.byType(Card).first;
      await tester.tap(firstWorkout);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();

      // Verify bookmark
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Check workout history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });
  });
} 