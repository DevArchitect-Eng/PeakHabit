import 'package:drift/drift.dart';

/// Stores a calendar date as an ISO-8601 `yyyy-MM-dd` string.
///
/// Drift's `dateTime()` column holds a point in time. For values that are a
/// date and nothing else — a birthday, the day a weight was recorded — that is
/// misleading: the stored instant moves by hours between time zones and can
/// end up on the neighbouring day. The text form has no such ambiguity and
/// stays readable when looking into the database directly.
///
/// Only the calendar day of a value survives, and it comes back as **local
/// midnight** — the form `DateTime(2026, 8, 16)` and every date picker
/// produce. Writing a value that carries a time of day, or a UTC one, stores
/// its day and hands back local midnight for it, so the result is no longer
/// `==` to what went in. Compare stored dates with each other, never with an
/// unnormalised `DateTime`.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb);

  @override
  String toSql(DateTime value) {
    // Read straight off the value instead of shifting it into another time
    // zone first: `toLocal()` on a UTC midnight would land on the day before
    // west of Greenwich and store the wrong date.
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
