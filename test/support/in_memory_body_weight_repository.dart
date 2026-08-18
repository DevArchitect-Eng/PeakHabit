import 'dart:async';

import 'package:peakhabit/features/body_weight/data/body_weight_repository.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';

/// A [BodyWeightRepository] that keeps the entries in memory.
///
/// Same reason as the other fakes next to it: a widget test cannot drive the
/// real database, and what the database does with the entries is covered by
/// the repository tests.
class InMemoryBodyWeightRepository implements BodyWeightRepository {
  InMemoryBodyWeightRepository([Iterable<BodyWeightEntry> entries = const []]) {
    for (final entry in entries) {
      _entries[entry.date] = entry;
    }
  }

  final _entries = <DateTime, BodyWeightEntry>{};
  final _changes = StreamController<List<BodyWeightEntry>>.broadcast();

  /// The entries as they currently stand, oldest first.
  List<BodyWeightEntry> get entries {
    final sorted = _entries.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  @override
  Future<BodyWeightEntry?> readLatest() async =>
      entries.isEmpty ? null : entries.last;

  @override
  Stream<BodyWeightEntry?> watchLatest() =>
      _watch().map((entries) => entries.isEmpty ? null : entries.last);

  @override
  Future<List<BodyWeightEntry>> readRange(DateTime from, DateTime to) async =>
      _inRange(from, to);

  @override
  Stream<List<BodyWeightEntry>> watchRange(DateTime from, DateTime to) =>
      _watch().map((_) => _inRange(from, to));

  @override
  Future<void> save(BodyWeightEntry entry) async {
    _entries[entry.date] = entry;
    _changes.add(entries);
  }

  @override
  Future<void> delete(DateTime date) async {
    _entries.remove(DateTime(date.year, date.month, date.day));
    _changes.add(entries);
  }

  Future<void> dispose() => _changes.close();

  Stream<List<BodyWeightEntry>> _watch() async* {
    yield entries;
    yield* _changes.stream;
  }

  List<BodyWeightEntry> _inRange(DateTime from, DateTime to) {
    final firstDay = DateTime(from.year, from.month, from.day);
    final lastDay = DateTime(to.year, to.month, to.day);
    return entries
        .where(
          (entry) =>
              !entry.date.isBefore(firstDay) && !entry.date.isAfter(lastDay),
        )
        .toList();
  }
}
