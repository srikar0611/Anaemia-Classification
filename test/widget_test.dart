// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  group('Login Page Widget Tests', () {
    testWidgets('Login with valid credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find the username and password fields
      final usernameField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Enter valid credentials
      await tester.enterText(usernameField, 'testuser');
      await tester.enterText(passwordField, 'Test@123');

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify navigation to PatientDetailsPage
      expect(find.byType(PatientDetailsPage), findsOneWidget);
    });

    testWidgets('Login with invalid credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find the username and password fields
      final usernameField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Enter invalid credentials
      await tester.enterText(usernameField, 'invaliduser');
      await tester.enterText(passwordField, 'invalidpassword');

      // Find and tap the login button
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify that an error message is displayed or the user remains on the login page
      // (You'll need to adapt this assertion based on your app's behavior)
      expect(find.byType(LoginPage), findsOneWidget); // Example: User remains on login page
    });
  });

  group('PatientDetailsPage Widget Tests', () {
    testWidgets('Displays patient details', (WidgetTester tester) async {
      const username = 'testuser';
      await tester.pumpWidget(const MaterialApp(
        home: PatientDetailsPage(username: username),
      ));

      // Verify that the username is displayed
      expect(find.text('Welcome, $username'), findsOneWidget);
    });

    // Add more tests for other functionalities of PatientDetailsPage
  });
}