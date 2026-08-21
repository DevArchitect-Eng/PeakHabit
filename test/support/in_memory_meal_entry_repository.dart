import 'dart:async';

import 'package:peakhabit/features/nutrition/data/meal_entry_repository.dart';
import 'package:peakhabit/features/nutrition/domain/day_nutrition.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';

/// A [MealEntryRepository] that keeps the diary in memory.
///
/// Same reason as the other fakes next to it: a widget test cannot drive the
/// real database, and what the database does with the rows is covered by the
/// repository tests.
class InMemoryMealEntryRepository implements MealEntryRepository {
  InMemoryMealEntryRepository({
    Iterable<MealEntry> entries = const [],
    this.failing = false,
  }) {
    for (final entry in entries) {
      final saved = entry.id == null ? entry.withId(_nextId++) : entry;
      _nextId = saved.id! >= _nextId ? saved.id! + 1 : _nextId;
      _entries.add(saved);
    }
  }

  /// Lets every read fail, for the case a screen has to tell "could not be
  /// read" apart from "nothing logged yet".
  final bool failing;

  /// Lets every write fail, for the case a screen has to report a failed save.
  bool unwritable = false;

  final _entries = <MealEntry>[];
  final _changes = StreamController<void>.broadcast();
  int _nextId = 1;

  /// The diary as it currently stands, in the order the entries were logged.
  List<MealEntry> get entries => List.unmodifiable(_entries);

  @override
  Future<DayNutrition> readDay(DateTime day) async {
    _failIfAsked();
    final date = _dayOf(day);
    return DayNutrition(
      date: date,
      entries: _entries.where((entry) => entry.date == date).toList(),
    );
  }

  @override
  Stream<DayNutrition> watchDay(DateTime day) =>
      _watch().asyncMap((_) => readDay(day));

  @override
  Future<MealEntry> save(MealEntry entry) async {
    if (unwritable) throw StateError('the entry cannot be saved');
    final id = entry.id;
    if (id == null) {
      final saved = entry.withId(_nextId++);
      _entries.add(saved);
      _changes.add(null);
      return saved;
    }

    final index = _entries.indexWhere((existing) => existing.id == id);
    if (index < 0) throw ArgumentError.value(id, 'entry.id', 'no such entry');
    _entries[index] = entry;
    _changes.add(null);
    return entry;
  }

  @override
  Future<int> copyMeal({
    required MealType mealType,
    required DateTime from,
    required DateTime to,
  }) async {
    if (unwritable) throw StateError('the meal cannot be copied');
    final source = _dayOf(from);
    final target = _dayOf(to);
    final copied = _entries
        .where((entry) => entry.date == source && entry.mealType == mealType)
        .toList();
    for (final entry in copied) {
      _entries.add(
        MealEntry(
          id: _nextId++,
          date: target,
          mealType: mealType,
          item: entry.item,
          grams: entry.grams,
        ),
      );
    }
    if (copied.isNotEmpty) _changes.add(null);
    return copied.length;
  }

  @override
  Future<void> delete(int id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();

  Stream<void> _watch() async* {
    _failIfAsked();
    yield null;
    yield* _changes.stream;
  }

  void _failIfAsked() {
    if (failing) throw StateError('the meal entries cannot be read');
  }

  DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
}
