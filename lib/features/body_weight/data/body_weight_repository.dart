import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/date_only_converter.dart';
import '../domain/body_weight_entry.dart';

/// Reads and writes the body weight entries.
///
/// The series is the data behind the home screen widget and the weight part of
/// the statistics; both read it here rather than querying the database
/// themselves.
///
/// Ranges are given as calendar days and are inclusive at both ends: asking
/// for 1 August to 31 August returns an entry made on either of those days.
/// Only the day of a bound is used, so a bound carrying a time of day makes no
/// difference.
class BodyWeightRepository {
  BodyWeightRepository(this._database);

  final AppDatabase _database;

  /// The most recent entry, or `null` while nothing has been recorded.
  Future<BodyWeightEntry?> readLatest() async {
    final row = await _latestQuery().getSingleOrNull();
    return row == null ? null : _toEntry(row);
  }

  /// Emits the most recent entry and every later change to it.
  Stream<BodyWeightEntry?> watchLatest() => _latestQuery()
      .watchSingleOrNull()
      .map((row) => row == null ? null : _toEntry(row));

  /// The entries from [from] to [to], oldest first.
  Future<List<BodyWeightEntry>> readRange(DateTime from, DateTime to) async {
    final rows = await _rangeQuery(from, to).get();
    return rows.map(_toEntry).toList();
  }

  /// Emits the entries from [from] to [to], oldest first, and re-emits them on
  /// every change.
  Stream<List<BodyWeightEntry>> watchRange(DateTime from, DateTime to) =>
      _rangeQuery(from, to).watch().map((rows) => rows.map(_toEntry).toList());

  /// Writes [entry] — adding it, or replacing the entry of the same day.
  ///
  /// Weighing again on one day corrects that day rather than adding a second
  /// value, so there is one method for both cases instead of an insert and an
  /// update the caller would have to choose between.
  Future<void> save(BodyWeightEntry entry) async {
    await _database
        .into(_database.bodyWeightEntries)
        .insertOnConflictUpdate(
          BodyWeightEntriesCompanion.insert(
            date: entry.date,
            weightKg: entry.weightKg,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Removes the entry of [date]. Doing so on a day without an entry is not an
  /// error — the day ends up without one either way.
  Future<void> delete(DateTime date) async {
    await (_database.delete(
      _database.bodyWeightEntries,
    )..where((row) => row.date.equalsValue(_dayOf(date)))).go();
  }

  SimpleSelectStatement<$BodyWeightEntriesTable, BodyWeightRow>
  _latestQuery() => _database.select(_database.bodyWeightEntries)
    ..orderBy([(row) => OrderingTerm.desc(row.date)])
    ..limit(1);

  SimpleSelectStatement<$BodyWeightEntriesTable, BodyWeightRow> _rangeQuery(
    DateTime from,
    DateTime to,
  ) {
    // Compared as the stored `yyyy-MM-dd` text, which sorts and orders exactly
    // like the dates it stands for — that is what the fixed-width ISO form
    // buys us.
    const converter = DateOnlyConverter();
    final firstDay = converter.toSql(_dayOf(from));
    final lastDay = converter.toSql(_dayOf(to));
    return _database.select(_database.bodyWeightEntries)
      ..where((row) => row.date.isBetweenValues(firstDay, lastDay))
      ..orderBy([(row) => OrderingTerm.asc(row.date)]);
  }

  DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

  BodyWeightEntry _toEntry(BodyWeightRow row) =>
      BodyWeightEntry(date: row.date, weightKg: row.weightKg);
}
