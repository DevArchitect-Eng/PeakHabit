import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/date_only_converter.dart';

void main() {
  const converter = DateOnlyConverter();

  test('writes an ISO date and reads it back unchanged', () {
    final date = DateTime(1990, 5, 17);

    expect(converter.toSql(date), '1990-05-17');
    expect(converter.fromSql(converter.toSql(date)), date);
  });

  test('pads month and day to two digits', () {
    expect(converter.toSql(DateTime(2026, 8, 6)), '2026-08-06');
  });

  test('drops a time of day and normalises to midnight', () {
    final date = DateTime(2026, 8, 16, 23, 45);

    expect(converter.fromSql(converter.toSql(date)), DateTime(2026, 8, 16));
  });

  test('keeps the calendar day of a UTC value instead of shifting it', () {
    // `toLocal()` first would move UTC midnight onto the previous day west of
    // Greenwich, which would store the wrong date.
    expect(converter.toSql(DateTime.utc(1990, 5, 17)), '1990-05-17');
  });

  test('two values on the same day end up identical', () {
    final morning = DateTime(2026, 8, 16, 7);
    final evening = DateTime(2026, 8, 16, 21);

    expect(
      converter.fromSql(converter.toSql(morning)),
      converter.fromSql(converter.toSql(evening)),
    );
  });

  group('daylight saving time', () {
    // A date carries no time zone, but `DateTime` does: `fromSql` hands back
    // local midnight. In zones that move the clock at midnight — Cairo,
    // Santiago, Havana, Beirut — that midnight does not exist on the day the
    // clock springs forward. Dart normalises such a value **forward**, to
    // 01:00 of the same day, and never back onto the day before, so the
    // calendar day survives. That is the property these tests hold in place:
    // a `toLocal()` inside `fromSql`, or a comparison of instants rather than
    // of calendar components, would break it.
    //
    // On a machine in a zone without daylight saving — the CI runs on UTC —
    // these dates are ordinary days and the assertions hold trivially. The
    // sweep below is what stays meaningful there, and on a developer machine
    // in Europe/Berlin it covers that zone's transitions on its own.
    const transitionDays = <(int, int, int)>[
      (2026, 3, 29), // Europe/Berlin springs forward at 02:00
      (2026, 10, 25), // Europe/Berlin falls back at 03:00
      (2026, 4, 24), // Africa/Cairo springs forward at 00:00
      (2026, 10, 30), // Africa/Cairo falls back at 00:00
      (2026, 4, 5), // America/Santiago falls back at 00:00
      (2026, 9, 7), // America/Santiago springs forward at 00:00
    ];

    test('a transition day keeps its own date', () {
      for (final (year, month, day) in transitionDays) {
        final stored = converter.toSql(DateTime(year, month, day));

        expect(stored, converter.toSql(converter.fromSql(stored)));
        expect(converter.fromSql(stored).day, day, reason: 'for $stored');
        expect(converter.fromSql(stored).month, month, reason: 'for $stored');
      }
    });

    test('the day before a transition is not pulled along', () {
      for (final (year, month, day) in transitionDays) {
        final eve = DateTime(year, month, day - 1);

        expect(
          converter.toSql(eve),
          isNot(converter.toSql(DateTime(year, month, day))),
        );
        expect(converter.fromSql(converter.toSql(eve)).day, eve.day);
      }
    });

    test('every day of three years survives the round trip', () {
      // Stepped through the constructor rather than `add(Duration(days: 1))`:
      // a day is 23 or 25 hours long around a transition, so adding 24 hours
      // to local midnight can land back on the same day or skip one. The
      // constructor normalises an overflowing day number and has no such
      // problem.
      var date = DateTime(2025, 1, 1);
      final last = DateTime(2027, 12, 31);

      while (!date.isAfter(last)) {
        final stored = converter.toSql(date);

        expect(
          converter.toSql(converter.fromSql(stored)),
          stored,
          reason: 'round trip changed the day for $stored',
        );

        date = DateTime(date.year, date.month, date.day + 1);
      }
    });
  });
}
