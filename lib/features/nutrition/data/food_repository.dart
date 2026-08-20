import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/food.dart';
import '../domain/nutrients.dart';

/// Thrown when a food or a dish cannot be deleted because something still
/// refers to it — a meal entry, or a dish it is an ingredient of.
///
/// Deleting it would take that history with it, so the repository refuses
/// before the database does. Carrying the name means the screen can say which
/// one without looking it up again.
class FoodItemInUseException implements Exception {
  const FoodItemInUseException(this.name);

  final String name;

  @override
  String toString() => 'FoodItemInUseException: "$name" is still in use';
}

/// Reads and writes the catalogue: the foods and the dishes made from them.
///
/// A dish is always handed out complete, with its ingredients and the foods
/// behind them, because its nutrients only exist once those are known.
class FoodRepository {
  FoodRepository(this._database);

  final AppDatabase _database;

  /// Every food, by name. With [ids] given, only those — and nothing at all
  /// for an empty [ids].
  Future<List<Food>> readFoods({Iterable<int>? ids}) async {
    if (ids != null && ids.isEmpty) return const [];
    final rows = await _foodsQuery(ids).get();
    return rows.map(_toFood).toList();
  }

  /// Emits every food, by name, and re-emits on every change.
  Stream<List<Food>> watchFoods() =>
      _foodsQuery(null).watch().map((rows) => rows.map(_toFood).toList());

  /// The food of [id], or `null` when there is none.
  Future<Food?> readFood(int id) async {
    final rows = await readFoods(ids: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  /// Writes [food] — adding it when it has no id yet, updating it otherwise —
  /// and hands it back carrying the id it was saved under.
  ///
  /// Throws an [ArgumentError] on an id that is not in the catalogue: an
  /// update that matched nothing would otherwise look like it had been saved.
  Future<Food> saveFood(Food food) async {
    final now = DateTime.now();
    final nutrients = food.nutrientsPer100g;
    final id = food.id;

    if (id == null) {
      final newId = await _database
          .into(_database.foods)
          .insert(
            FoodsCompanion.insert(
              name: food.name,
              brand: Value.absentIfNull(food.brand),
              kcalPer100g: nutrients.kcal,
              proteinPer100g: nutrients.proteinGrams,
              carbsPer100g: nutrients.carbGrams,
              fatPer100g: nutrients.fatGrams,
              portionGrams: Value.absentIfNull(food.portionGrams),
              source: food.source,
              barcode: Value.absentIfNull(food.barcode),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return food.withId(newId);
    }

    final updated =
        await (_database.update(
          _database.foods,
        )..where((row) => row.id.equals(id))).write(
          FoodsCompanion(
            name: Value(food.name),
            brand: Value(food.brand),
            kcalPer100g: Value(nutrients.kcal),
            proteinPer100g: Value(nutrients.proteinGrams),
            carbsPer100g: Value(nutrients.carbGrams),
            fatPer100g: Value(nutrients.fatGrams),
            portionGrams: Value(food.portionGrams),
            source: Value(food.source),
            barcode: Value(food.barcode),
            updatedAt: Value(now),
          ),
        );
    if (updated == 0) {
      throw ArgumentError.value(id, 'food.id', 'no food with this id');
    }
    return food;
  }

  /// Removes the food of [id].
  ///
  /// Throws a [FoodItemInUseException] while a meal entry or a dish still
  /// refers to it — see `docs/ARCHITECTURE.md` for why history wins over the
  /// deletion. Deleting a food that is not there is not an error; it is gone
  /// either way.
  Future<void> deleteFood(int id) => _database.transaction(() async {
    final food = await readFood(id);
    if (food == null) return;
    if (await _isFoodInUse(id)) {
      throw FoodItemInUseException(food.name);
    }
    await (_database.delete(
      _database.foods,
    )..where((row) => row.id.equals(id))).go();
  });

  /// Every dish, by name, each with its ingredients. With [ids] given, only
  /// those — and nothing at all for an empty [ids].
  Future<List<CompositeFood>> readCompositeFoods({Iterable<int>? ids}) async {
    if (ids != null && ids.isEmpty) return const [];
    return _groupIntoDishes(await _compositeFoodsQuery(ids).get());
  }

  /// Emits every dish, by name, and re-emits on every change — to a dish, to
  /// its ingredients, or to one of the foods behind them.
  Stream<List<CompositeFood>> watchCompositeFoods() =>
      _compositeFoodsQuery(null).watch().map(_groupIntoDishes);

  /// The dish of [id], or `null` when there is none.
  Future<CompositeFood?> readCompositeFood(int id) async {
    final dishes = await readCompositeFoods(ids: [id]);
    return dishes.isEmpty ? null : dishes.first;
  }

  /// Writes [dish] together with its ingredients, and hands it back carrying
  /// the id it was saved under.
  ///
  /// The ingredient list is replaced as a whole rather than compared row by
  /// row: it is short, and a diff would be more moving parts than the write
  /// it saves. All of it happens in one transaction, so a dish is never left
  /// standing without ingredients.
  ///
  /// Throws an [ArgumentError] on an ingredient that has not been saved yet,
  /// or on a dish id that is not in the catalogue.
  Future<CompositeFood> saveCompositeFood(CompositeFood dish) {
    for (final ingredient in dish.ingredients) {
      if (ingredient.food.id == null) {
        throw ArgumentError.value(
          ingredient.food,
          'dish.ingredients',
          'every ingredient has to be saved before the dish',
        );
      }
    }

    return _database.transaction(() async {
      final now = DateTime.now();
      final existingId = dish.id;
      final int id;

      if (existingId == null) {
        id = await _database
            .into(_database.compositeFoods)
            .insert(
              CompositeFoodsCompanion.insert(
                name: dish.name,
                preparedGrams: Value.absentIfNull(dish.preparedGrams),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        id = existingId;
        final updated =
            await (_database.update(
              _database.compositeFoods,
            )..where((row) => row.id.equals(id))).write(
              CompositeFoodsCompanion(
                name: Value(dish.name),
                preparedGrams: Value(dish.preparedGrams),
                updatedAt: Value(now),
              ),
            );
        if (updated == 0) {
          throw ArgumentError.value(id, 'dish.id', 'no dish with this id');
        }
        await (_database.delete(
          _database.compositeFoodIngredients,
        )..where((row) => row.compositeFoodId.equals(id))).go();
      }

      await _database.batch((batch) {
        batch.insertAll(_database.compositeFoodIngredients, [
          for (final ingredient in dish.ingredients)
            CompositeFoodIngredientsCompanion.insert(
              compositeFoodId: id,
              foodId: ingredient.food.id!,
              grams: ingredient.grams,
            ),
        ]);
      });

      return dish.withId(id);
    });
  }

  /// Removes the dish of [id] together with its ingredient rows.
  ///
  /// Throws a [FoodItemInUseException] while a meal entry still refers to it.
  /// Deleting a dish that is not there is not an error.
  Future<void> deleteCompositeFood(int id) => _database.transaction(() async {
    final dish = await readCompositeFood(id);
    if (dish == null) return;
    if (await _isCompositeFoodInUse(id)) {
      throw FoodItemInUseException(dish.name);
    }
    // The ingredient rows go with it — the foreign key is on `CASCADE`.
    await (_database.delete(
      _database.compositeFoods,
    )..where((row) => row.id.equals(id))).go();
  });

  SimpleSelectStatement<$FoodsTable, FoodRow> _foodsQuery(Iterable<int>? ids) {
    final query = _database.select(_database.foods)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    if (ids != null) {
      query.where((row) => row.id.isIn(ids.toList()));
    }
    return query;
  }

  /// A dish and its ingredients in one query, one row per ingredient.
  ///
  /// Inner joins: a dish always has at least one ingredient — the domain
  /// model refuses one without, and [saveCompositeFood] writes both in one
  /// transaction — so nothing is dropped by joining that way. Reading it as
  /// one query rather than one per dish is also what lets [watchCompositeFoods]
  /// be a single stream that reacts to all three tables.
  JoinedSelectStatement<HasResultSet, dynamic> _compositeFoodsQuery(
    Iterable<int>? ids,
  ) {
    final dishes = _database.compositeFoods;
    final ingredients = _database.compositeFoodIngredients;
    final foods = _database.foods;

    final query = _database.select(dishes).join([
      innerJoin(ingredients, ingredients.compositeFoodId.equalsExp(dishes.id)),
      innerJoin(foods, foods.id.equalsExp(ingredients.foodId)),
    ]);
    if (ids != null) {
      query.where(dishes.id.isIn(ids.toList()));
    }
    query.orderBy([
      OrderingTerm.asc(dishes.name),
      OrderingTerm.asc(dishes.id),
      OrderingTerm.asc(foods.name),
    ]);
    return query;
  }

  List<CompositeFood> _groupIntoDishes(List<TypedResult> rows) {
    // Insertion order follows the query's order by name, and so does the
    // result — a `Map` in Dart keeps the order things were put in.
    final dishRows = <int, CompositeFoodRow>{};
    final ingredients = <int, List<CompositeFoodIngredient>>{};

    for (final row in rows) {
      final dish = row.readTable(_database.compositeFoods);
      final ingredient = row.readTable(_database.compositeFoodIngredients);
      dishRows[dish.id] = dish;
      (ingredients[dish.id] ??= []).add(
        CompositeFoodIngredient(
          food: _toFood(row.readTable(_database.foods)),
          grams: ingredient.grams,
        ),
      );
    }

    return [
      for (final dish in dishRows.values)
        CompositeFood(
          id: dish.id,
          name: dish.name,
          ingredients: ingredients[dish.id]!,
          preparedGrams: dish.preparedGrams,
        ),
    ];
  }

  Future<bool> _isFoodInUse(int id) async {
    final logged =
        await (_database.select(_database.mealEntries)
              ..where((row) => row.foodId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (logged != null) return true;

    final cooked =
        await (_database.select(_database.compositeFoodIngredients)
              ..where((row) => row.foodId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return cooked != null;
  }

  Future<bool> _isCompositeFoodInUse(int id) async {
    final logged =
        await (_database.select(_database.mealEntries)
              ..where((row) => row.compositeFoodId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return logged != null;
  }

  Food _toFood(FoodRow row) => Food(
    id: row.id,
    name: row.name,
    brand: row.brand,
    nutrientsPer100g: Nutrients(
      kcal: row.kcalPer100g,
      proteinGrams: row.proteinPer100g,
      carbGrams: row.carbsPer100g,
      fatGrams: row.fatPer100g,
    ),
    portionGrams: row.portionGrams,
    source: row.source,
    barcode: row.barcode,
  );
}
