import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/home/presentation/weight_chart.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

import '../../../support/pump_app.dart';
import '../../../support/settings_rows.dart';

void main() {
  /// A weighing of [weightKg], [days] before today.
  ///
  /// Counted from the real today because the card reads its window from
  /// `DateTime.now()` — a fixed date would drop out of the period as soon as
  /// the test ran on a later day.
  BodyWeightEntry weighing(int days, double weightKg) {
    final now = DateTime.now();
    return BodyWeightEntry(
      date: DateTime(now.year, now.month, now.day - days),
      weightKg: weightKg,
    );
  }

  // Finders are lazy, so one built here resolves against whatever is on
  // screen at the moment it is used.
  final addButton = find.widgetWithIcon(IconButton, Icons.add);
  final weightField = find.widgetWithText(TextField, 'Gewicht');

  /// Opens the editor and types [text] into it, without confirming yet.
  Future<void> typeWeight(WidgetTester tester, String text) async {
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.enterText(weightField, text);
    await tester.pumpAndSettle();
  }

  group('the stored series', () {
    testWidgets('shows the latest weighing above the chart', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          weightEntries: [
            weighing(40, 84),
            weighing(20, 83.2),
            weighing(1, 82.5),
          ],
        ),
      );

      expect(find.text('82,5 kg'), findsOneWidget);
      expect(find.byType(WeightChart), findsOneWidget);
    });

    testWidgets('reports the change over the chosen period', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(40, 84), weighing(1, 82.5)]),
      );

      expect(find.text('−1,5 kg in den letzten 3 Monaten'), findsOneWidget);
    });

    testWidgets('says the weight held where it did not move', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(20, 82.5), weighing(1, 82.5)]),
      );

      expect(find.text('±0 kg in den letzten 3 Monaten'), findsOneWidget);
    });

    testWidgets('names the day instead of a change on a single weighing', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(0, 82.5)]));

      // One point has nothing to be compared against, but it is still a chart.
      expect(find.textContaining('am '), findsOneWidget);
      expect(find.byType(WeightChart), findsOneWidget);
    });
  });

  group('entering a weighing', () {
    testWidgets('a confirmed weighing shows up right away', (tester) async {
      final stores = await pumpApp(tester);
      expect(find.byType(WeightChart), findsNothing);

      await typeWeight(tester, '80,4');
      await confirmEditor(tester);

      expect(find.text('80,4 kg'), findsOneWidget);
      expect(find.byType(WeightChart), findsOneWidget);
      expect(stores.bodyWeight.entries.single.weightKg, 80.4);
    });

    testWidgets('the editor starts on the weight last recorded', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(1, 82.5)]));

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(weightField).controller?.text, '82,5');
    });

    testWidgets('a weight that cannot be meant is not confirmable', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Nothing typed yet: out of reach, but not yet scolding about it.
      expect(confirmIsOffered(tester), isFalse);
      expect(find.text('Bitte ein Gewicht wie 82,5 eintragen.'), findsNothing);

      await tester.enterText(weightField, '0');
      await tester.pumpAndSettle();

      expect(confirmIsOffered(tester), isFalse);
      expect(
        find.text('Bitte ein Gewicht wie 82,5 eintragen.'),
        findsOneWidget,
      );

      await tester.enterText(weightField, '80,4');
      await tester.pumpAndSettle();

      expect(confirmIsOffered(tester), isTrue);
    });

    testWidgets('dropping the editor records nothing', (tester) async {
      final stores = await pumpApp(tester);

      await typeWeight(tester, '80,4');
      await cancelEditor(tester);

      expect(stores.bodyWeight.entries, isEmpty);
      expect(find.byType(WeightChart), findsNothing);
    });

    testWidgets('weighing again on the same day corrects that day', (
      tester,
    ) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(0, 82.5)]),
      );

      await typeWeight(tester, '82,1');
      await confirmEditor(tester);

      expect(stores.bodyWeight.entries.single.weightKg, 82.1);
      expect(find.text('82,1 kg'), findsOneWidget);
    });
  });

  group('nothing to draw', () {
    testWidgets('without a weighing a hint stands in for the chart', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(WeightChart), findsNothing);
      expect(
        find.text(
          'Noch keine Wiegung. Der Verlauf beginnt mit dem ersten Wert.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Gewicht eintragen'),
        findsOneWidget,
      );
    });

    testWidgets('a failed read is told apart from an empty series', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntriesUnreadable: true));

      expect(
        find.text('Der Gewichtsverlauf konnte nicht geladen werden.'),
        findsOneWidget,
      );
      expect(find.byType(WeightChart), findsNothing);
      // Nothing to add to: the entry would land where nobody can see it.
      expect(tester.widget<IconButton>(addButton).onPressed, isNull);
    });
  });

  group('the period', () {
    testWidgets('a shorter one drops what falls outside it', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(200, 84)]));

      // Three months to start with, and the weighing is older than that.
      expect(find.text('Im gewählten Zeitraum keine Wiegung.'), findsOneWidget);
      expect(find.byType(WeightChart), findsNothing);
      // The weight itself is still the latest one on record.
      expect(find.text('84 kg'), findsOneWidget);

      await tester.tap(find.text('1 Jahr'));
      await tester.pumpAndSettle();

      expect(find.byType(WeightChart), findsOneWidget);
      expect(find.text('Im gewählten Zeitraum keine Wiegung.'), findsNothing);
    });

    testWidgets('switching it changes what the change is measured over', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          weightEntries: [
            weighing(60, 85),
            weighing(10, 83),
            weighing(1, 82.5),
          ],
        ),
      );

      expect(find.text('−2,5 kg in den letzten 3 Monaten'), findsOneWidget);

      await tester.tap(find.text('1 Monat'));
      await tester.pumpAndSettle();

      // Only the last two weighings are inside a month.
      expect(find.text('−0,5 kg im letzten Monat'), findsOneWidget);
    });
  });

  group('both themes', () {
    for (final mode in [AppThemeMode.dark, AppThemeMode.light]) {
      testWidgets('the chart draws under the ${mode.name} theme', (
        tester,
      ) async {
        await pumpApp(
          tester,
          on: storesWith(
            themeMode: mode,
            weightEntries: [weighing(30, 84), weighing(1, 82.5)],
          ),
        );

        // Every colour in the chart comes from the colour scheme, so reaching
        // it under both brightnesses is what there is to check here — that it
        // then reads well is the theme's job. A card that overflowed would
        // fail the test on its own.
        final context = tester.element(find.byType(WeightChart));
        expect(
          Theme.of(context).brightness,
          mode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
        );
        expect(find.text('82,5 kg'), findsOneWidget);
      });
    }
  });
}
