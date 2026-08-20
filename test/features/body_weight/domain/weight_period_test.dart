import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/weight_period.dart';

void main() {
  group('startFrom', () {
    test('a month back keeps the day of the month', () {
      expect(
        WeightPeriod.month.startFrom(DateTime(2026, 8, 20)),
        DateTime(2026, 7, 20),
      );
    });

    test('three months back keeps the day of the month', () {
      expect(
        WeightPeriod.threeMonths.startFrom(DateTime(2026, 8, 20)),
        DateTime(2026, 5, 20),
      );
    });

    test('a year back keeps the day and the month', () {
      expect(
        WeightPeriod.year.startFrom(DateTime(2026, 8, 20)),
        DateTime(2025, 8, 20),
      );
    });

    test('reaches into the previous year', () {
      expect(
        WeightPeriod.threeMonths.startFrom(DateTime(2026, 2, 10)),
        DateTime(2025, 11, 10),
      );
    });

    test('a month back from a day the shorter month has not overflows', () {
      // February has no 31st, so the window is a few days shorter than a
      // month rather than landing on a day that does not exist.
      expect(
        WeightPeriod.month.startFrom(DateTime(2026, 3, 31)),
        DateTime(2026, 3, 3),
      );
    });

    test('a year back from 29 February overflows into March', () {
      expect(
        WeightPeriod.year.startFrom(DateTime(2024, 2, 29)),
        DateTime(2023, 3, 1),
      );
    });

    test('drops the time of day of the day it counts from', () {
      expect(
        WeightPeriod.month.startFrom(DateTime(2026, 8, 20, 22, 45)),
        DateTime(2026, 7, 20),
      );
    });
  });
}
