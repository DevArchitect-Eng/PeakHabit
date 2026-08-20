import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/home/presentation/weight_chart.dart';

void main() {
  final from = DateTime(2026, 5, 20);
  final to = DateTime(2026, 8, 20);

  Future<void> pumpChart(
    WidgetTester tester,
    List<BodyWeightEntry> entries,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightChart(entries: entries, from: from, to: to),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('draws a series without complaint', (tester) async {
    await pumpChart(tester, [
      BodyWeightEntry(date: DateTime(2026, 6, 1), weightKg: 84),
      BodyWeightEntry(date: DateTime(2026, 7, 1), weightKg: 83.2),
      BodyWeightEntry(date: DateTime(2026, 8, 19), weightKg: 82.5),
    ]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty series draws nothing rather than throwing', (
    tester,
  ) async {
    // The painter already skips an empty series; the widget around it has to
    // agree, or a caller handing one over gets a blank chart from the one and
    // a crash from the other.
    await pumpChart(tester, const []);

    expect(tester.takeException(), isNull);
    expect(find.byType(WeightChart), findsOneWidget);
  });

  testWidgets('a series that never moves draws without dividing by zero', (
    tester,
  ) async {
    await pumpChart(tester, [
      BodyWeightEntry(date: DateTime(2026, 6, 1), weightKg: 82.5),
      BodyWeightEntry(date: DateTime(2026, 8, 1), weightKg: 82.5),
    ]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('tells a screen reader what the drawing shows', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpChart(tester, [
      BodyWeightEntry(date: DateTime(2026, 6, 1), weightKg: 84),
      BodyWeightEntry(date: DateTime(2026, 8, 19), weightKg: 82.5),
    ]);

    expect(
      find.bySemanticsLabel(
        'Gewichtsverlauf vom 01.06.26 bis 19.08.26: '
        'von 84 kg auf 82,5 kg, 2 Wiegungen',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a single weighing is named as one', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpChart(tester, [
      BodyWeightEntry(date: DateTime(2026, 8, 19), weightKg: 82.5),
    ]);

    expect(
      find.bySemanticsLabel(
        'Gewichtsverlauf: eine Wiegung, 82,5 kg am 19.08.26',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
