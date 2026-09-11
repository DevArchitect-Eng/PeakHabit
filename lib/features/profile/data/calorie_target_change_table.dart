import 'package:drift/drift.dart';

import '../../../core/database/date_only_converter.dart';

/// Every change of the calorie target, each with the day it took over.
///
/// The profile holds only the target as it stands now, which is enough for
/// today but not for a day in the past: a day is measured against the target
/// it was lived under, and a change on the goals screen should not re-mark
/// every day before it.
///
/// One row per change rather than one per day: a target holds until the next
/// row replaces it, so a day with no row of its own is on the target of the
/// last row before it.
///
/// The day is the primary key — a second change on the same day replaces the
/// first by way of an upsert, the same way a second weighing does. The target
/// a day was lived under is the one it ended on.
@DataClassName('CalorieTargetChangeRow')
class CalorieTargetChanges extends Table {
  /// The first day the target applies to, as `yyyy-MM-dd` — see
  /// [DateOnlyConverter] for why this is not a `dateTime()` column.
  TextColumn get validFrom => text().map(const DateOnlyConverter())();

  /// Daily calorie target in kcal. `NULL` when the target was cleared on that
  /// day — from then on there is none, which is a state of its own rather than
  /// a gap in the record.
  IntColumn get kcal => integer().nullable()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {validFrom};

  /// The profile already rejects a target of zero or less, but it is not the
  /// only way into the file.
  @override
  List<String> get customConstraints => ['CHECK (kcal IS NULL OR kcal > 0)'];
}
