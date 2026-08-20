import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/day_nutrition.dart';
import '../domain/food.dart';
import '../domain/meal_entry.dart';
import 'food_repository.dart';

/// Reads and writes the meal diary.
///
/// Hands out whole days rather than single entries: the nutrition tab asks
/// what stands under each meal and what the day adds up to, and both answers
/// come from the same read.
///
/// The entries carry the food they point at, resolved through the
/// [FoodRepository] — an entry on its own says only how many grams of
/// something, which is not enough to add anything up.
class MealEntryRepository {
  MealEntryRepository(this._database, this._foods);

  final AppDatabase _database;
  final FoodRepository _foods;

  /// Everything logged on [day], and what it adds up to.
  Future<DayNutrition> readDay(DateTime day) async {
    final date = _dayOf(day);
    final rows = await _dayQuery(date).get();
    return DayNutrition(date: date, entries: await _toEntries(rows));
  }

  /// Emits [day] and re-emits it on every change that can move its numbers.
  ///
  /// That is more than the entries themselves: a correction to a food, or to
  /// the ingredients of a dish, changes what a past day carried — which is
  /// the point of pointing at the food instead of copying its nutrients. A
  /// plain `watch()` on the entries would not see it, so the day is read
  /// again whenever any of the four tables it draws from is written to.
  /// Delegated with `yield*` rather than looped over with `await for`: an
  /// `await for` inside a generator only notices a cancelled subscription at
  /// its next event, and the stream of writes has no last one — closing the
  /// day would then wait forever.
  Stream<DayNutrition> watchDay(DateTime day) async* {
    yield await readDay(day);
    yield* _database
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _database.mealEntries,
            _database.foods,
            _database.compositeFoods,
            _database.compositeFoodIngredients,
          ]),
        )
        .asyncMap((_) => readDay(day));
  }

  /// Writes [entry] — adding it when it has no id yet, updating it otherwise —
  /// and hands it back carrying the id it was saved under.
  ///
  /// Throws an [ArgumentError] on an item that has not been saved yet, or on
  /// an entry id that is not in the diary.
  Future<MealEntry> save(MealEntry entry) async {
    final item = entry.item;
    final itemId = item.id;
    if (itemId == null) {
      throw ArgumentError.value(
        item,
        'entry.item',
        'has to be saved before it can be logged',
      );
    }
    // The sealed [FoodItem] is what makes this exhaustive: a third kind of
    // item would not compile until it had a column here.
    final (foodId, compositeFoodId) = switch (item) {
      Food() => (Value<int?>(itemId), const Value<int?>(null)),
      CompositeFood() => (const Value<int?>(null), Value<int?>(itemId)),
    };
    final now = DateTime.now();
    final id = entry.id;

    if (id == null) {
      final newId = await _database
          .into(_database.mealEntries)
          .insert(
            MealEntriesCompanion.insert(
              date: entry.date,
              mealType: entry.mealType,
              foodId: foodId,
              compositeFoodId: compositeFoodId,
              grams: entry.grams,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return entry.withId(newId);
    }

    final updated =
        await (_database.update(
          _database.mealEntries,
        )..where((row) => row.id.equals(id))).write(
          MealEntriesCompanion(
            date: Value(entry.date),
            mealType: Value(entry.mealType),
            foodId: foodId,
            compositeFoodId: compositeFoodId,
            grams: Value(entry.grams),
            updatedAt: Value(now),
          ),
        );
    if (updated == 0) {
      throw ArgumentError.value(id, 'entry.id', 'no entry with this id');
    }
    return entry;
  }

  /// Removes the entry of [id]. Doing so twice is not an error — it is gone
  /// either way.
  Future<void> delete(int id) async {
    await (_database.delete(
      _database.mealEntries,
    )..where((row) => row.id.equals(id))).go();
  }

  SimpleSelectStatement<$MealEntriesTable, MealEntryRow> _dayQuery(
    DateTime date,
  ) => _database.select(_database.mealEntries)
    ..where((row) => row.date.equalsValue(date))
    // By id, so entries stay in the order they were logged in.
    ..orderBy([(row) => OrderingTerm.asc(row.id)]);

  /// Resolves the rows of a day into entries, reading the foods and dishes
  /// they point at in one query each rather than one per row.
  Future<List<MealEntry>> _toEntries(List<MealEntryRow> rows) async {
    if (rows.isEmpty) return const [];

    final foods = await _foods.readFoods(
      ids: rows.map((row) => row.foodId).whereType<int>().toSet(),
    );
    final dishes = await _foods.readCompositeFoods(
      ids: rows.map((row) => row.compositeFoodId).whereType<int>().toSet(),
    );
    final byId = <int, Food>{for (final food in foods) food.id!: food};
    final dishesById = <int, CompositeFood>{
      for (final dish in dishes) dish.id!: dish,
    };

    return [
      for (final row in rows)
        MealEntry(
          id: row.id,
          date: row.date,
          mealType: row.mealType,
          // The row points at exactly one of the two — the check constraint
          // on the table says so — and the foreign keys guarantee the item is
          // still there, so neither lookup can come back empty.
          item: row.foodId != null
              ? byId[row.foodId]!
              : dishesById[row.compositeFoodId]!,
          grams: row.grams,
        ),
    ];
  }

  DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
}
