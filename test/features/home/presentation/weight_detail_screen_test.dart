import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/body_weight/domain/weight_period.dart';
import 'package:peakhabit/features/home/presentation/body_weight_card.dart';
import 'package:peakhabit/features/home/presentation/weight_chart.dart';
import 'package:peakhabit/features/home/presentation/weight_detail_screen.dart';
import 'package:peakhabit/features/home/presentation/weight_period_picker.dart';
import 'package:peakhabit/features/profile/presentation/profile_formatting.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

import '../../../support/pump_app.dart';
import '../../../support/settings_rows.dart';

void main() {
  /// A weighing of [weightKg], [days] before today.
  ///
  /// Counted from the real today because the screen reads its window from
  /// `DateTime.now()` — a fixed date would drop out of the period as soon as
  /// the test ran on a later day.
  BodyWeightEntry weighing(int days, double weightKg) {
    final now = DateTime.now();
    return BodyWeightEntry(
      date: DateTime(now.year, now.month, now.day - days),
      weightKg: weightKg,
    );
  }

  final addButton = find.widgetWithIcon(IconButton, Icons.add);
  final weightField = find.widgetWithText(TextField, 'Gewicht');
  final dateRow = find.widgetWithText(ListTile, 'Datum');

  /// Taps the weight card of the home screen, which is the way in.
  ///
  /// Tapped on its title rather than in the middle, where the period picker
  /// sits and would take the tap for itself.
  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(find.text('Körpergewicht'));
    await tester.pumpAndSettle();
  }

  /// Opens the period sheet, picks the option labelled [label] and confirms.
  ///
  /// The option is found by its tile rather than by text alone: the label the
  /// picker already shows carries the same words, so a bare text finder would
  /// have two of them to choose between once the sheet is open.
  Future<void> selectPeriod(WidgetTester tester, String label) async {
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<WeightPeriod?>, label));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bestätigen'));
    await tester.pumpAndSettle();
  }

  /// What the summary over the chart says, scoped to it: the weights it names
  /// show up in the list below as well.
  Finder inSummary(String text) => find.descendant(
    of: find.byType(PeriodSummary),
    matching: find.text(text),
  );

  /// The trend icon of the summary — the only icon in it.
  Icon trendIcon(WidgetTester tester) => tester.widget<Icon>(
    find.descendant(
      of: find.byType(PeriodSummary),
      matching: find.byType(Icon),
    ),
  );

  /// The weights of the entry list, in the order they stand on screen.
  List<String> listedWeights(WidgetTester tester) => tester
      .widgetList<Dismissible>(find.byType(Dismissible))
      .map((row) => ((row.child as ListTile).title! as Text).data!)
      .toList();

  /// The day as the rows write it — the app's own locale rather than a form
  /// spelled out here, so the test asks for what the screen actually renders.
  String fullDate(WidgetTester tester, DateTime date) =>
      MaterialLocalizations.of(
        tester.element(find.byType(WeightDetailScreen)),
      ).formatFullDate(date);

  group('getting there and back', () {
    testWidgets('the weight card opens the detail screen', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(1, 82.5)]));

      await openDetail(tester);

      expect(find.byType(WeightDetailScreen), findsOneWidget);
      // The screen sits inside the home branch, so the tabs stay where they
      // are instead of the screen covering them.
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('the back arrow leads to the home screen', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(1, 82.5)]));
      await openDetail(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(WeightDetailScreen), findsNothing);
      expect(find.byType(BodyWeightCard), findsOneWidget);
    });

    testWidgets('it opens on the period the card was showing', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(200, 84)]));

      await selectPeriod(tester, '1 Jahr');
      await openDetail(tester);

      expect(find.text('1 Jahr'), findsOneWidget);
      expect(find.byType(WeightChart), findsOneWidget);
    });
  });

  group('the figures over the chart', () {
    testWidgets('start, current and difference come from the period', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          weightEntries: [
            // Outside the three months the screen opens on: the starting
            // weight is the first weighing *in the window*, not the first one
            // ever recorded.
            weighing(300, 90),
            weighing(60, 85),
            weighing(10, 83),
            weighing(1, 82.5),
          ],
        ),
      );

      await openDetail(tester);

      expect(inSummary('85 kg'), findsOneWidget);
      expect(inSummary('82,5 kg'), findsOneWidget);
      expect(inSummary('−2,5 kg'), findsOneWidget);
      expect(inSummary('−2,9 %'), findsOneWidget);
      // Out of the window, so out of the figures — but still on record, so
      // still in the list below.
      expect(inSummary('90 kg'), findsNothing);
      expect(listedWeights(tester), contains('90 kg'));
    });

    testWidgets('a gain points up and is green', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 80), weighing(1, 82)]),
      );

      await openDetail(tester);

      expect(inSummary('+2 kg'), findsOneWidget);
      expect(inSummary('+2,5 %'), findsOneWidget);
      final icon = trendIcon(tester);
      expect(icon.icon, Icons.trending_up);
      expect(icon.color, const Color(0xFF4ADE80));
    });

    testWidgets('a loss points down and is red', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 84), weighing(1, 82.5)]),
      );

      await openDetail(tester);

      expect(inSummary('−1,5 kg'), findsOneWidget);
      final icon = trendIcon(tester);
      expect(icon.icon, Icons.trending_down);
      expect(icon.color, const Color(0xFFF87171));
    });

    testWidgets('a weight that held is neutral, in neither colour', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 82.5), weighing(1, 82.5)]),
      );

      await openDetail(tester);

      expect(inSummary('±0 kg'), findsOneWidget);
      expect(inSummary('±0 %'), findsOneWidget);
      final icon = trendIcon(tester);
      expect(icon.icon, Icons.trending_flat);
      expect(
        icon.color,
        Theme.of(
          tester.element(find.byType(PeriodSummary)),
        ).colorScheme.onSurfaceVariant,
      );
    });

    testWidgets('a single weighing is its own start and current', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(3, 82.5)]));

      await openDetail(tester);

      // Start and current are the same value, so the summary names it twice.
      expect(inSummary('82,5 kg'), findsNWidgets(2));
      expect(inSummary('±0 kg'), findsOneWidget);
      expect(trendIcon(tester).icon, Icons.trending_flat);
      expect(find.byType(WeightChart), findsOneWidget);
    });

    testWidgets('the colours reach both themes', (tester) async {
      for (final mode in [AppThemeMode.dark, AppThemeMode.light]) {
        await pumpApp(
          tester,
          on: storesWith(
            themeMode: mode,
            weightEntries: [weighing(30, 84), weighing(1, 82.5)],
          ),
        );
        await openDetail(tester);

        final dark = mode == AppThemeMode.dark;
        expect(
          trendIcon(tester).color,
          dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
        );
      }
    });
  });

  group('the head', () {
    testWidgets('the picker sits beside the heading on the chart card', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(1, 82.5)]));

      await openDetail(tester);

      // Inside the card, next to what it changes — not spanning the top of the
      // screen, where it would read as a filter for everything below it.
      final card = find.ancestor(
        of: find.byType(WeightPeriodPicker),
        matching: find.byType(Card),
      );
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('Verlauf')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.byType(WeightChart)),
        findsOneWidget,
      );
      // The weighings below are outside it: the card is what separates them.
      expect(
        find.descendant(of: card, matching: find.byType(Dismissible)),
        findsNothing,
      );
    });

    testWidgets('the head survives the largest system text size', (
      tester,
    ) async {
      // A control laid out with no width limit cannot give way, and the period
      // labels are long. An overflow here fails the test on its own — the
      // framework reports it as an exception.
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 84), weighing(1, 82.5)]),
      );

      await openDetail(tester);
      await selectPeriod(tester, 'Seit Beginn');

      // Narrowed to a phone only now: `pumpApp` runs on a window wide enough
      // that nothing here could overflow, which would leave this test passing
      // on a layout that breaks on every real device.
      tester.view.physicalSize = const Size(393, 852);
      // A single frame rather than `pumpAndSettle`, so a broken layout throws
      // once instead of once per frame.
      //
      // Green, this test costs a second. **Red, it takes minutes to report**:
      // a `RenderFlex` overflow carries a full widget-tree dump, and the test
      // harness is slow to push one of that size. Measured at ~6 minutes with
      // the guard removed — slow, but it does finish, which is the line
      // `CLAUDE.md` draws around hanging tests. If this one ever goes red,
      // wait for it rather than assuming it hung.
      await tester.pump();

      // Asserted on the geometry rather than left to the overflow error alone,
      // so a regression fails on a measurement instead of on a framework
      // exception — the two agree, but only one of them says by how much.
      final card = tester.getRect(
        find.ancestor(
          of: find.byType(WeightPeriodPicker),
          matching: find.byType(Card),
        ),
      );
      final picker = tester.getRect(find.byType(WeightPeriodPicker));
      expect(picker.left, greaterThanOrEqualTo(card.left));
      expect(picker.right, lessThanOrEqualTo(card.right));
    });
  });

  group('the list of weighings', () {
    testWidgets('every weighing on record stands there, newest first', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          weightEntries: [
            // Older than the three months the screen opens on, and listed all
            // the same: the list is the record, not the window.
            weighing(300, 90),
            weighing(30, 84),
            weighing(1, 82.5),
          ],
        ),
      );

      await openDetail(tester);

      expect(listedWeights(tester), ['82,5 kg', '84 kg', '90 kg']);
      expect(find.text('Alle Wiegungen'), findsOneWidget);
      expect(
        find.text(fullDate(tester, weighing(1, 82.5).date)),
        findsOneWidget,
      );
    });

    testWidgets('a row is corrected on its own day', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 84), weighing(1, 82.5)]),
      );
      await openDetail(tester);

      await tester.tap(find.widgetWithText(ListTile, '84 kg'));
      await tester.pumpAndSettle();

      // Opened on the day of that row, and on that row's weight — and the day
      // is not up for changing, so a correction cannot quietly move the entry.
      expect(tester.widget<TextField>(weightField).controller?.text, '84');
      expect(find.text(formatDate(weighing(30, 84).date)), findsOneWidget);
      expect(tester.widget<ListTile>(dateRow).enabled, isFalse);

      await tester.enterText(weightField, '83,2');
      await tester.pumpAndSettle();
      await confirmEditor(tester);

      // Through to the figures, the chart and the list at once.
      expect(inSummary('83,2 kg'), findsOneWidget);
      expect(inSummary('−0,7 kg'), findsOneWidget);
      expect(listedWeights(tester), ['82,5 kg', '83,2 kg']);
      expect(stores.bodyWeight.entries.first.weightKg, 83.2);
      expect(stores.bodyWeight.entries.first.date, weighing(30, 84).date);
    });

    testWidgets('a row swiped away is gone, on the card as well', (
      tester,
    ) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 84), weighing(1, 82.5)]),
      );
      await openDetail(tester);

      await tester.drag(
        find.byKey(ValueKey(weighing(1, 82.5).date)),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();

      expect(listedWeights(tester), ['84 kg']);
      expect(stores.bodyWeight.entries.single.weightKg, 84);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // The card reads the same series, so it has lost the weighing too.
      expect(find.text('84 kg'), findsOneWidget);
      expect(find.text('82,5 kg'), findsNothing);
    });
  });

  group('adding a weighing', () {
    testWidgets('the plus in the app bar records one', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(weightEntries: [weighing(30, 84)]),
      );
      await openDetail(tester);

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Empty, unlike the editor a row opens: adding is a new reading, not a
      // correction of the one before it.
      expect(tester.widget<TextField>(weightField).controller?.text, '');

      await tester.enterText(weightField, '82,5');
      await tester.pumpAndSettle();
      await confirmEditor(tester);

      expect(listedWeights(tester), ['82,5 kg', '84 kg']);
      expect(stores.bodyWeight.entries.last.weightKg, 82.5);
      // Adding still picks its own day, unlike correcting a row.
      expect(stores.bodyWeight.entries.last.date, weighing(0, 1).date);
    });
  });

  group('nothing to show', () {
    testWidgets('without a weighing a hint stands in for everything', (
      tester,
    ) async {
      await pumpApp(tester);

      await openDetail(tester);

      expect(
        find.text(
          'Noch keine Wiegung. Der Verlauf beginnt mit dem ersten Wert.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PeriodSummary), findsNothing);
      expect(find.byType(WeightChart), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      // The way in is still there.
      expect(tester.widget<IconButton>(addButton).onPressed, isNotNull);
    });

    testWidgets('a period without a weighing keeps the picker', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [weighing(200, 84)]));

      await openDetail(tester);

      expect(find.text('Im gewählten Zeitraum keine Wiegung.'), findsOneWidget);
      expect(find.byType(PeriodSummary), findsNothing);
      // The chart has nothing to draw, but the weighing is still on record and
      // still reachable for correcting or deleting.
      expect(listedWeights(tester), ['84 kg']);

      // Widening the window is the way out, so the picker has to stay.
      await selectPeriod(tester, '1 Jahr');

      expect(find.text('Im gewählten Zeitraum keine Wiegung.'), findsNothing);
      expect(find.byType(WeightChart), findsOneWidget);
      expect(listedWeights(tester), ['84 kg']);
    });

    testWidgets('a failed read is told apart from an empty series', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntriesUnreadable: true));

      await openDetail(tester);

      expect(
        find.text('Der Gewichtsverlauf konnte nicht geladen werden.'),
        findsOneWidget,
      );
      expect(find.byType(WeightChart), findsNothing);
      // Nothing to add to: the entry would land where nobody can see it.
      expect(tester.widget<IconButton>(addButton).onPressed, isNull);
    });
  });

  group('switching the period', () {
    testWidgets('the figures and the chart follow it', (tester) async {
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
      await openDetail(tester);

      expect(inSummary('85 kg'), findsOneWidget);
      expect(inSummary('−2,5 kg'), findsOneWidget);

      await selectPeriod(tester, '1 Monat');

      // Only the last two weighings are inside a month, so they are the whole
      // period — its start and its difference.
      expect(inSummary('83 kg'), findsOneWidget);
      expect(inSummary('−0,5 kg'), findsOneWidget);
      expect(find.byType(WeightChart), findsOneWidget);
    });

    testWidgets('the list does not follow it', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          weightEntries: [
            weighing(400, 90),
            weighing(60, 85),
            weighing(1, 82.5),
          ],
        ),
      );
      await openDetail(tester);

      final onRecord = ['82,5 kg', '85 kg', '90 kg'];
      expect(listedWeights(tester), onRecord);

      // Down to a week, where the figures have one weighing to work with and
      // the chart draws a dot — the record underneath is untouched.
      await selectPeriod(tester, '1 Woche');
      expect(listedWeights(tester), onRecord);

      await selectPeriod(tester, 'Seit Beginn');
      expect(listedWeights(tester), onRecord);
    });
  });
}
