import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/workout_detail_screen.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/workout_provider.dart';

void main() {
  testWidgets('WorkoutDetailScreen displays workout information',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WorkoutDetailScreen(workoutId: 1),
        ),
      ),
    );

    // Verify loading indicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the data to load
    await tester.pumpAndSettle();

    // Verify workout details are displayed
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('WorkoutDetailScreen shows error message on failure',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WorkoutDetailScreen(workoutId: 999), // Non-existent ID
        ),
      ),
    );

    // Wait for the data to load
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Failed to load workout details'), findsOneWidget);
  });

  testWidgets('WorkoutDetailScreen displays workout exercises',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WorkoutDetailScreen(workoutId: 1),
        ),
      ),
    );

    // Wait for the data to load
    await tester.pumpAndSettle();

    // Verify exercises list is displayed
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
} 