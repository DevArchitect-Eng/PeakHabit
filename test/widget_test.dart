import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('starts on the home tab', (tester) async {
    await pumpApp(tester);

    expect(find.text('Startseite'), findsOneWidget);
  });

  testWidgets('switches to each tab', (tester) async {
    await pumpApp(tester);

    for (final (label, content) in const [
      ('Ernährung', 'Ernährung'),
      ('Training', 'Trainingspläne'),
      ('Statistik', 'Statistik'),
      ('Einstellungen', 'Darstellung'),
    ]) {
      await tester.tap(find.widgetWithText(NavigationDestination, label));
      await tester.pumpAndSettle();

      expect(find.text(content), findsWidgets);
    }
  });
}
