// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_vehicle_monitor/main.dart';

void main() {
  testWidgets('Smart Vehicle Monitor app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartVehicleApp());

    // Verify that the app title is displayed
    expect(find.text('Smart Vehicle Health Monitor'), findsOneWidget);

    // Verify that the splash screen shows initially
    expect(find.text('Smart Vehicle'), findsOneWidget);
    expect(find.text('Health Monitor'), findsOneWidget);

    // Wait for splash screen to complete (3 seconds)
    await tester.pump(const Duration(seconds: 3));

    // After splash, we should see the dashboard
    await tester.pumpAndSettle();

    // Verify dashboard elements are present
    expect(find.text('Vehicle Health'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
