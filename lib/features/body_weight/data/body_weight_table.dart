import 'package:drift/drift.dart';

import '../../../core/database/date_only_converter.dart';

/// The series of body weight entries.
///
/// The day is the primary key rather than a surrogate id: at most one entry
/// exists per calendar day, and making that the key lets SQLite enforce it
/// instead of leaving it to whoever writes. A second weighing on the same day
/// then replaces the first by way of an upsert.
///
/// That also gives a later cloud sync a stable, meaningful key — the day a
/// weight belongs to does not change, whereas a generated id would have to be
/// kept in step across devices.
@DataClassName('BodyWeightRow')
class BodyWeightEntries extends Table {
  /// The day of the weighing, as `yyyy-MM-dd` — see [DateOnlyConverter] for
  /// why this is not a `dateTime()` column.
  TextColumn get date => text().map(const DateOnlyConverter())();

  /// Body weight in kilograms.
  RealColumn get weightKg => real()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};

  /// The domain model already rejects an impossible weight, but it is not the
  /// only way into the file — a later migration or a hand-written statement
  /// gets here too.
  @override
  List<String> get customConstraints => ['CHECK (weight_kg > 0)'];
}
