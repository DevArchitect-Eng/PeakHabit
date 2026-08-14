import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/app.dart';

void main() {
  testWidgets('starts on the home tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PeakHabitApp()));
    await tester.pumpAndSettle();

    expect(find.text('Startseite'), findsOneWidget);
  });

  testWidgets('switches to each tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PeakHabitApp()));
    await tester.pumpAndSettle();

    for (final (label, content) in const [
      ('Ernährung', 'Ernährung'),
      ('Training', 'Trainingspläne'),
      ('Statistik', 'Statistik'),
    ]) {
      await tester.tap(find.widgetWithText(NavigationDestination, label));
      await tester.pumpAndSettle();

      expect(find.text(content), findsWidgets);
    }
  });
}
