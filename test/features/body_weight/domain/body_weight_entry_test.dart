import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';

void main() {
  group('date', () {
    test('drops the time of day', () {
      final entry = BodyWeightEntry(
        date: DateTime(2026, 8, 18, 7, 42, 13),
        weightKg: 81.4,
      );

      expect(entry.date, DateTime(2026, 8, 18));
    });

    test('two weighings on one day land on the same date', () {
      final morning = BodyWeightEntry(
        date: DateTime(2026, 8, 18, 6),
        weightKg: 80.9,
      );
      final evening = BodyWeightEntry(
        date: DateTime(2026, 8, 18, 21),
        weightKg: 82.1,
      );

      expect(morning.date, evening.date);
    });
  });

  group('weight', () {
    test('rejects zero', () {
      expect(
        () => BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 0),
        throwsArgumentError,
      );
    });

    test('rejects a negative weight', () {
      expect(
        () => BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: -1),
        throwsArgumentError,
      );
    });

    test('rejects a value that is not a number', () {
      expect(
        () =>
            BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: double.nan),
        throwsArgumentError,
      );
    });

    test('rejects infinity', () {
      expect(
        () => BodyWeightEntry(
          date: DateTime(2026, 8, 18),
          weightKg: double.infinity,
        ),
        throwsArgumentError,
      );
    });
  });

  test('entries with the same day and weight are equal', () {
    expect(
      BodyWeightEntry(date: DateTime(2026, 8, 18, 6), weightKg: 81.4),
      BodyWeightEntry(date: DateTime(2026, 8, 18, 20), weightKg: 81.4),
    );
  });

  test('copyWith replaces only what it is given', () {
    final entry = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 81.4);

    expect(
      entry.copyWith(weightKg: 80.2),
      BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 80.2),
    );
  });
}
