import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management_flutter/features/member/presentation/screens/member_workouts_screen.dart';
import 'package:gym_management_flutter/features/member/presentation/providers/workout_provider.dart';

void main() {
  testWidgets('MemberWorkoutsScreen displays loading indicator initially',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MemberWorkoutsScreen(),
        ),
      ),
    );

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MemberWorkoutsScreen displays workout cards when data is loaded',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MemberWorkoutsScreen(),
        ),
      ),
    );

    // Wait for the data to load
    await tester.pumpAndSettle();

    // Verify workout cards are displayed
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('MemberWorkoutsScreen shows error message on failure',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MemberWorkoutsScreen(),
        ),
      ),
    );

    // Wait for the data to load
    await tester.pumpAndSettle();

    // Verify error message is shown if there's an error
    expect(find.text('Failed to load workouts'), findsOneWidget);
  });
} 