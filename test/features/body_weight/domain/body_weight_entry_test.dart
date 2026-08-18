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

  group('daylight saving time', () {
    // The entry normalises its date to local midnight. On the day a zone
    // springs forward at midnight — Cairo, Santiago, Havana, Beirut — that
    // midnight does not exist; Dart moves such a value forward to 01:00 of the
    // same day rather than back onto the day before, so the entry stays on the
    // day it was meant for. Were it pulled back, two weighings on neighbouring
    // days would collide on one date and one of them would silently overwrite
    // the other.
    //
    // The CI runs on UTC, where these are ordinary days and the assertions
    // hold trivially. They bite on a machine in one of the zones named below —
    // which is what makes them worth keeping rather than a guarantee the CI
    // gives us.
    const transitionDays = <(int, int, int)>[
      (2026, 3, 29), // Europe/Berlin springs forward at 02:00
      (2026, 10, 25), // Europe/Berlin falls back at 03:00
      (2026, 4, 24), // Africa/Cairo springs forward at 00:00
      (2026, 10, 30), // Africa/Cairo falls back at 00:00
      (2026, 4, 5), // America/Santiago falls back at 00:00
      (2026, 9, 7), // America/Santiago springs forward at 00:00
    ];

    test('an entry on a transition day stays on that day', () {
      for (final (year, month, day) in transitionDays) {
        final entry = BodyWeightEntry(
          date: DateTime(year, month, day),
          weightKg: 81.4,
        );

        expect(entry.date.year, year);
        expect(entry.date.month, month);
        expect(entry.date.day, day, reason: 'for $year-$month-$day');
      }
    });

    test('a transition day stays distinct from the day before it', () {
      for (final (year, month, day) in transitionDays) {
        final eve = BodyWeightEntry(
          date: DateTime(year, month, day - 1),
          weightKg: 82.0,
        );
        final transition = BodyWeightEntry(
          date: DateTime(year, month, day),
          weightKg: 81.4,
        );

        expect(eve.date, isNot(transition.date));
      }
    });

    test('a weighing late on the eve of a transition keeps its own day', () {
      for (final (year, month, day) in transitionDays) {
        final eve = DateTime(year, month, day - 1);
        final entry = BodyWeightEntry(
          date: DateTime(eve.year, eve.month, eve.day, 23, 30),
          weightKg: 82.0,
        );

        expect(entry.date.day, eve.day, reason: 'for $year-$month-$day');
      }
    });
  });

  test('copyWith replaces only what it is given', () {
    final entry = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 81.4);

    expect(
      entry.copyWith(weightKg: 80.2),
      BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 80.2),
    );
  });
}
