import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/calorie_target_history.dart';

void main() {
  final history = CalorieTargetHistory([
    // Out of order on purpose: the record sorts what it is given.
    (validFrom: DateTime(2026, 9, 8), kcal: 2200),
    (validFrom: DateTime(2026, 9, 1), kcal: 2000),
    (validFrom: DateTime(2026, 9, 10), kcal: null),
  ]);

  test('knows no target while nothing was ever recorded', () {
    expect(CalorieTargetHistory.empty.targetOn(DateTime(2026, 9, 1)), isNull);
  });

  test('gives a change day the target it brought', () {
    expect(history.targetOn(DateTime(2026, 9, 1)), 2000);
    expect(history.targetOn(DateTime(2026, 9, 8)), 2200);
  });

  test('keeps a day between two changes on the earlier one', () {
    expect(history.targetOn(DateTime(2026, 9, 7)), 2000);
  });

  test('ignores the time of day', () {
    expect(history.targetOn(DateTime(2026, 9, 7, 23, 59)), 2000);
    expect(history.targetOn(DateTime(2026, 9, 8, 0, 1)), 2200);
  });

  test('falls back to the first target before the record began', () {
    expect(history.targetOn(DateTime(2026, 8, 20)), 2000);
  });

  test('knows no target after it was cleared', () {
    expect(history.targetOn(DateTime(2026, 9, 10)), isNull);
    expect(history.targetOn(DateTime(2026, 12, 24)), isNull);
  });
}
