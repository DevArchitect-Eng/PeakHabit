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
}
