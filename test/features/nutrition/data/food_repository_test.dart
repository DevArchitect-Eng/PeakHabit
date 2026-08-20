import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/nutrition/data/food_repository.dart';
import 'package:peakhabit/features/nutrition/data/meal_entry_repository.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  late AppDatabase database;
  late FoodRepository repository;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    repository = FoodRepository(database);
  });

  tearDown(() => database.close());

  Nutrients per100g({
    double kcal = 350,
    double protein = 7,
    double carbs = 78,
    double fat = 1,
  }) => Nutrients(
    kcal: kcal,
    proteinGrams: protein,
    carbGrams: carbs,
    fatGrams: fat,
  );

  Food food(String name) => Food(name: name, nutrientsPer100g: per100g());

  group('foods', () {
    test('reports nothing before anything was saved', () async {
      expect(await repository.readFoods(), isEmpty);
      expect(await repository.readFood(1), isNull);
    });

    test('gives back a saved food, with an id', () async {
      final saved = await repository.saveFood(
        Food(
          name: 'Vollmilch',
          brand: 'Weihenstephan',
          nutrientsPer100g: per100g(
            kcal: 64,
            protein: 3.4,
            carbs: 4.8,
            fat: 3.5,
          ),
          portionGrams: 250,
          source: FoodSource.scanned,
          barcode: '4008100097216',
        ),
      );

      expect(saved.id, isNotNull);
      expect(await repository.readFood(saved.id!), saved);
    });

    test('lists the foods by name', () async {
      await repository.saveFood(food('Reis'));
      await repository.saveFood(food('Apfel'));
      await repository.saveFood(food('Quark'));

      expect((await repository.readFoods()).map((food) => food.name), [
        'Apfel',
        'Quark',
        'Reis',
      ]);
    });

    test('reads only the ids it was asked for', () async {
      final apple = await repository.saveFood(food('Apfel'));
      await repository.saveFood(food('Quark'));

      expect(await repository.readFoods(ids: [apple.id!]), [apple]);
      expect(await repository.readFoods(ids: const []), isEmpty);
    });

    test('an update replaces the values and keeps the id', () async {
      final saved = await repository.saveFood(food('Reis'));

      final corrected = await repository.saveFood(
        Food(
          id: saved.id,
          name: 'Reis, roh',
          nutrientsPer100g: per100g(kcal: 349),
        ),
      );

      expect(corrected.id, saved.id);
      expect(await repository.readFoods(), [corrected]);
    });

    test('an update can clear an optional value again', () async {
      final saved = await repository.saveFood(
        Food(
          name: 'Riegel',
          brand: 'Marke',
          nutrientsPer100g: per100g(),
          portionGrams: 60,
        ),
      );

      await repository.saveFood(
        Food(id: saved.id, name: 'Riegel', nutrientsPer100g: per100g()),
      );

      final read = await repository.readFood(saved.id!);
      expect(read?.brand, isNull);
      expect(read?.portionGrams, isNull);
    });

    test('an update of a food that is not there is an error', () async {
      expect(
        () => repository.saveFood(
          Food(id: 404, name: 'Reis', nutrientsPer100g: per100g()),
        ),
        throwsArgumentError,
      );
    });

    test('deletes a food nothing refers to', () async {
      final saved = await repository.saveFood(food('Reis'));

      await repository.deleteFood(saved.id!);

      expect(await repository.readFoods(), isEmpty);
    });

    test('deleting a food that is not there is not an error', () async {
      await repository.deleteFood(404);
    });

    test('refuses to delete a food that has been eaten', () async {
      final saved = await repository.saveFood(food('Reis'));
      await MealEntryRepository(database, repository).save(
        MealEntry(
          date: DateTime(2026, 8, 20),
          mealType: MealType.lunch,
          item: saved,
          grams: 100,
        ),
      );

      expect(
        () => repository.deleteFood(saved.id!),
        throwsA(
          isA<FoodItemInUseException>().having(
            (error) => error.name,
            'name',
            'Reis',
          ),
        ),
      );
      expect(await repository.readFoods(), [saved]);
    });

    test('refuses to delete a food that is part of a dish', () async {
      final saved = await repository.saveFood(food('Reis'));
      await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: saved, grams: 100)],
        ),
      );

      expect(
        () => repository.deleteFood(saved.id!),
        throwsA(isA<FoodItemInUseException>()),
      );
    });

    test('emits the foods and then every change', () async {
      final seen = <List<String>>[];
      final subscription = repository.watchFoods().listen(
        (foods) => seen.add(foods.map((f) => f.name).toList()),
      );
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      final saved = await repository.saveFood(food('Reis'));
      await pumpEventQueue();
      await repository.deleteFood(saved.id!);
      await pumpEventQueue();

      expect(seen, [
        <String>[],
        ['Reis'],
        <String>[],
      ]);
    });
  });

  group('dishes', () {
    late Food rice;
    late Food oil;

    setUp(() async {
      rice = await repository.saveFood(food('Reis, roh'));
      oil = await repository.saveFood(
        Food(
          name: 'Rapsöl',
          nutrientsPer100g: per100g(kcal: 900, protein: 0, carbs: 0, fat: 100),
        ),
      );
    });

    test('gives back a saved dish with its ingredients', () async {
      final saved = await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [
            CompositeFoodIngredient(food: rice, grams: 200),
            CompositeFoodIngredient(food: oil, grams: 10),
          ],
          preparedGrams: 500,
        ),
      );

      final read = await repository.readCompositeFood(saved.id!);
      expect(read, saved);
      expect(read?.preparedGrams, 500);
      expect(read?.ingredients.map((it) => it.food), [oil, rice]);
      expect(read?.totalNutrients.kcal, closeTo(700 + 90, 0.001));
    });

    test('lists the dishes by name', () async {
      for (final name in ['Reispfanne', 'Auflauf']) {
        await repository.saveCompositeFood(
          CompositeFood(
            name: name,
            ingredients: [CompositeFoodIngredient(food: rice, grams: 100)],
          ),
        );
      }

      expect((await repository.readCompositeFoods()).map((dish) => dish.name), [
        'Auflauf',
        'Reispfanne',
      ]);
    });

    test('an update replaces the ingredient list as a whole', () async {
      final saved = await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [
            CompositeFoodIngredient(food: rice, grams: 200),
            CompositeFoodIngredient(food: oil, grams: 10),
          ],
        ),
      );

      await repository.saveCompositeFood(
        CompositeFood(
          id: saved.id,
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 150)],
          preparedGrams: 400,
        ),
      );

      final read = await repository.readCompositeFood(saved.id!);
      expect(read?.ingredients, [
        CompositeFoodIngredient(food: rice, grams: 150),
      ]);
      expect(read?.preparedGrams, 400);
      expect(
        await database.select(database.compositeFoodIngredients).get(),
        hasLength(1),
      );
    });

    test('an update of a dish that is not there is an error', () async {
      expect(
        () => repository.saveCompositeFood(
          CompositeFood(
            id: 404,
            name: 'Reis',
            ingredients: [CompositeFoodIngredient(food: rice, grams: 100)],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('refuses an ingredient that has not been saved yet', () async {
      expect(
        () => repository.saveCompositeFood(
          CompositeFood(
            name: 'Reis',
            ingredients: [
              CompositeFoodIngredient(food: food('Unbekannt'), grams: 100),
            ],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('deleting a dish takes its ingredient rows with it', () async {
      final saved = await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
        ),
      );

      await repository.deleteCompositeFood(saved.id!);

      expect(await repository.readCompositeFoods(), isEmpty);
      expect(
        await database.select(database.compositeFoodIngredients).get(),
        isEmpty,
      );
      // The food it was made of stays.
      expect(await repository.readFood(rice.id!), rice);
    });

    test('refuses to delete a dish that has been eaten', () async {
      final saved = await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
        ),
      );
      await MealEntryRepository(database, repository).save(
        MealEntry(
          date: DateTime(2026, 8, 20),
          mealType: MealType.lunch,
          item: saved,
          grams: 250,
        ),
      );

      expect(
        () => repository.deleteCompositeFood(saved.id!),
        throwsA(isA<FoodItemInUseException>()),
      );
    });

    test('a correction to a food reaches the dishes it is part of', () async {
      final saved = await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 100)],
        ),
      );
      expect(saved.totalNutrients.kcal, 350);

      await repository.saveFood(
        Food(
          id: rice.id,
          name: 'Reis, roh',
          nutrientsPer100g: per100g(kcal: 300),
        ),
      );

      final read = await repository.readCompositeFood(saved.id!);
      expect(read?.totalNutrients.kcal, 300);
    });

    test('emits the dishes and then every change to them', () async {
      final seen = <List<double>>[];
      final subscription = repository.watchCompositeFoods().listen(
        (dishes) =>
            seen.add(dishes.map((dish) => dish.totalNutrients.kcal).toList()),
      );
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 100)],
        ),
      );
      await pumpEventQueue();
      // Not the dish itself, but the food behind it.
      await repository.saveFood(
        Food(
          id: rice.id,
          name: 'Reis, roh',
          nutrientsPer100g: per100g(kcal: 300),
        ),
      );
      await pumpEventQueue();

      expect(seen.first, isEmpty);
      expect(seen.last, [300]);
    });
  });

  group('the database itself', () {
    // The domain model already rejects these, so a raw statement stands in for
    // the ways past it — a later migration, or someone editing the file.
    Future<void> insertFood({
      String name = 'Reis',
      double kcal = 350,
      String barcode = 'NULL',
    }) => database.customStatement(
      'INSERT INTO foods (name, kcal_per_100g, protein_per_100g, '
      'carbs_per_100g, fat_per_100g, source, barcode, created_at, updated_at) '
      "VALUES ('$name', $kcal, 7, 78, 1, 'manual', $barcode, 0, 0)",
    );

    test('refuses a blank name', () {
      expect(
        () => insertFood(name: ''),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('CHECK constraint failed'),
          ),
        ),
      );
    });

    test('refuses a negative amount of energy', () {
      expect(
        () => insertFood(kcal: -1),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('CHECK constraint failed'),
          ),
        ),
      );
    });

    test('refuses the same barcode twice', () {
      expect(
        () async {
          await insertFood(name: 'Milch', barcode: "'4008100097216'");
          await insertFood(name: 'Milch, andere', barcode: "'4008100097216'");
        },
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('UNIQUE constraint failed'),
          ),
        ),
      );
    });

    test('lets two foods stand there without a barcode', () async {
      await insertFood(name: 'Reis');
      await insertFood(name: 'Quark');

      expect(await repository.readFoods(), hasLength(2));
    });
  });

  test('the catalogue survives a restart of the app', () async {
    final directory = await Directory.systemTemp.createTemp('peakhabit_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'peakhabit.sqlite'));

    final firstRun = AppDatabase.atFile(file);
    await firstRun.open();
    final firstCatalogue = FoodRepository(firstRun);
    final rice = await firstCatalogue.saveFood(food('Reis, roh'));
    await firstCatalogue.saveCompositeFood(
      CompositeFood(
        name: 'Reis, gekocht',
        ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
        preparedGrams: 500,
      ),
    );
    await firstRun.close();

    final secondRun = AppDatabase.atFile(file);
    addTearDown(secondRun.close);
    await secondRun.open();

    final dishes = await FoodRepository(secondRun).readCompositeFoods();
    expect(dishes.single.name, 'Reis, gekocht');
    expect(dishes.single.preparedGrams, 500);
    expect(dishes.single.ingredients.single.food.name, 'Reis, roh');
  });
}
