import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/settings/presentation/settings_screen.dart';

import '../../../support/pump_app.dart';

void main() {
  /// What the app actually renders in, not just what was stored.
  Brightness renderedBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness;

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
  }

  testWidgets('the settings tab is reachable from the navigation bar', (
    tester,
  ) async {
    await pumpApp(tester);

    await openSettings(tester);

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Darstellung'), findsOneWidget);
  });

  testWidgets('switching to light repaints the app right away', (tester) async {
    await pumpApp(tester);
    await openSettings(tester);

    expect(renderedBrightness(tester), Brightness.dark);

    await tester.tap(find.text('Hell'));
    await tester.pumpAndSettle();

    expect(renderedBrightness(tester), Brightness.light);
  });

  testWidgets('switching back to dark repaints the app right away', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSettings(tester);
    await tester.tap(find.text('Hell'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();

    expect(renderedBrightness(tester), Brightness.dark);
  });

  testWidgets('the app starts in the theme that was chosen before', (
    tester,
  ) async {
    final stores = await pumpApp(tester);
    await openSettings(tester);
    await tester.tap(find.text('Hell'));
    await tester.pumpAndSettle();

    // Same stored values, fresh app — what a restart looks like from here.
    await pumpApp(tester, on: stores);
    await openSettings(tester);

    expect(renderedBrightness(tester), Brightness.light);
  });
}
