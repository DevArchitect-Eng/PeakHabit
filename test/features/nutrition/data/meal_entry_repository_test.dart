import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/nutrition/data/food_repository.dart';
import 'package:peakhabit/features/nutrition/data/meal_entry_repository.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  late AppDatabase database;
  late FoodRepository catalogue;
  late MealEntryRepository repository;
  late Food rice;

  final day = DateTime(2026, 8, 20);

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    catalogue = FoodRepository(database);
    repository = MealEntryRepository(database, catalogue);
    rice = await catalogue.saveFood(
      Food(
        name: 'Reis, roh',
        nutrientsPer100g: Nutrients(
          kcal: 350,
          proteinGrams: 7,
          carbGrams: 78,
          fatGrams: 1,
        ),
      ),
    );
  });

  tearDown(() => database.close());

  Future<MealEntry> log({
    FoodItem? item,
    DateTime? date,
    MealType mealType = MealType.lunch,
    double grams = 100,
  }) => repository.save(
    MealEntry(
      date: date ?? day,
      mealType: mealType,
      item: item ?? rice,
      grams: grams,
    ),
  );

  group('reading a day', () {
    test('a day nothing was logged on comes back empty', () async {
      final nutrition = await repository.readDay(day);

      expect(nutrition.date, day);
      expect(nutrition.isEmpty, isTrue);
      expect(nutrition.total, Nutrients.zero);
    });

    test('gives back what was logged, with the food behind it', () async {
      final saved = await log(grams: 60);

      final nutrition = await repository.readDay(day);

      expect(nutrition.entriesOf(MealType.lunch), [saved]);
      expect(nutrition.entriesOf(MealType.lunch).single.item, rice);
      expect(nutrition.total.kcal, closeTo(210, 0.001));
    });

    test('ignores the time of day it is asked with', () async {
      await log(date: DateTime(2026, 8, 20, 7, 30));

      final nutrition = await repository.readDay(DateTime(2026, 8, 20, 23));

      expect(nutrition.entries, hasLength(1));
    });

    test('leaves the other days out', () async {
      await log(grams: 100);
      await log(date: DateTime(2026, 8, 21), grams: 200);

      expect((await repository.readDay(day)).total.kcal, closeTo(350, 0.001));
      expect(
        (await repository.readDay(DateTime(2026, 8, 21))).total.kcal,
        closeTo(700, 0.001),
      );
    });

    test(
      'sorts the entries into the four meals and adds each one up',
      () async {
        await log(mealType: MealType.breakfast, grams: 100);
        await log(mealType: MealType.breakfast, grams: 50);
        await log(mealType: MealType.dinner, grams: 200);

        final nutrition = await repository.readDay(day);

        expect(nutrition.entriesOf(MealType.breakfast), hasLength(2));
        expect(nutrition.totalOf(MealType.breakfast).kcal, closeTo(525, 0.001));
        expect(nutrition.totalOf(MealType.dinner).kcal, closeTo(700, 0.001));
        expect(nutrition.totalOf(MealType.lunch), Nutrients.zero);
        expect(nutrition.total.kcal, closeTo(1225, 0.001));
      },
    );

    test(
      'keeps the entries of a meal in the order they were logged in',
      () async {
        final first = await log(mealType: MealType.snacks, grams: 10);
        final second = await log(mealType: MealType.snacks, grams: 20);

        final nutrition = await repository.readDay(day);

        expect(nutrition.entriesOf(MealType.snacks), [first, second]);
      },
    );

    test('counts a dish by what the prepared weight says it carries', () async {
      final cooked = await catalogue.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
          preparedGrams: 500,
        ),
      );

      await log(item: cooked, grams: 250);

      // Half the pot: 700 kcal went in, 350 come out.
      expect((await repository.readDay(day)).total.kcal, closeTo(350, 0.001));
    });

    test('adds a food and a dish up in one day', () async {
      final cooked = await catalogue.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
          preparedGrams: 500,
        ),
      );

      await log(mealType: MealType.lunch, item: cooked, grams: 250);
      await log(mealType: MealType.dinner, grams: 100);

      expect((await repository.readDay(day)).total.kcal, closeTo(700, 0.001));
    });

    test('a correction to a food reaches the days it was eaten on', () async {
      await log(grams: 100);

      await catalogue.saveFood(
        Food(
          id: rice.id,
          name: 'Reis, roh',
          nutrientsPer100g: Nutrients(
            kcal: 300,
            proteinGrams: 7,
            carbGrams: 78,
            fatGrams: 1,
          ),
        ),
      );

      expect((await repository.readDay(day)).total.kcal, closeTo(300, 0.001));
    });
  });

  group('writing', () {
    test('an entry gets an id when it is added', () async {
      final saved = await log();

      expect(saved.id, isNotNull);
    });

    test('an update replaces the values and keeps the id', () async {
      final saved = await log(mealType: MealType.lunch, grams: 100);

      final corrected = await repository.save(
        MealEntry(
          id: saved.id,
          date: day,
          mealType: MealType.dinner,
          item: rice,
          grams: 150,
        ),
      );

      final nutrition = await repository.readDay(day);
      expect(nutrition.entriesOf(MealType.lunch), isEmpty);
      expect(nutrition.entriesOf(MealType.dinner), [corrected]);
      expect(corrected.id, saved.id);
    });

    test('an update can move an entry to another day', () async {
      final saved = await log();

      await repository.save(
        MealEntry(
          id: saved.id,
          date: DateTime(2026, 8, 21),
          mealType: MealType.lunch,
          item: rice,
          grams: 100,
        ),
      );

      expect((await repository.readDay(day)).isEmpty, isTrue);
      expect(
        (await repository.readDay(DateTime(2026, 8, 21))).entries,
        hasLength(1),
      );
    });

    test('an update can swap a food for a dish', () async {
      final saved = await log();
      final cooked = await catalogue.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
          preparedGrams: 500,
        ),
      );

      await repository.save(
        MealEntry(
          id: saved.id,
          date: day,
          mealType: MealType.lunch,
          item: cooked,
          grams: 250,
        ),
      );

      final entry = (await repository.readDay(day)).entries.single;
      expect(entry.item, cooked);
      final row = await database.select(database.mealEntries).getSingle();
      expect(row.foodId, isNull);
      expect(row.compositeFoodId, cooked.id);
    });

    test('an update of an entry that is not there is an error', () async {
      expect(
        () => repository.save(
          MealEntry(
            id: 404,
            date: day,
            mealType: MealType.lunch,
            item: rice,
            grams: 100,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('refuses an item that has not been saved yet', () async {
      expect(
        () => log(
          item: Food(name: 'Unbekannt', nutrientsPer100g: Nutrients.zero),
        ),
        throwsArgumentError,
      );
    });

    test('removes an entry again', () async {
      final saved = await log();

      await repository.delete(saved.id!);

      expect((await repository.readDay(day)).isEmpty, isTrue);
    });

    test('deleting an entry that is not there is not an error', () async {
      await repository.delete(404);
    });
  });

  group('watching a day', () {
    test('emits the day and then every change to its entries', () async {
      final seen = <double>[];
      final subscription = repository
          .watchDay(day)
          .listen((nutrition) => seen.add(nutrition.total.kcal));
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      final saved = await log(grams: 100);
      await pumpEventQueue();
      await repository.delete(saved.id!);
      await pumpEventQueue();

      expect(seen.first, 0);
      expect(seen, contains(closeTo(350, 0.001)));
      expect(seen.last, 0);
    });

    test('emits again when a food it counts is corrected', () async {
      await log(grams: 100);
      final seen = <double>[];
      final subscription = repository
          .watchDay(day)
          .listen((nutrition) => seen.add(nutrition.total.kcal));
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await catalogue.saveFood(
        Food(
          id: rice.id,
          name: 'Reis, roh',
          nutrientsPer100g: Nutrients(
            kcal: 300,
            proteinGrams: 7,
            carbGrams: 78,
            fatGrams: 1,
          ),
        ),
      );
      await pumpEventQueue();

      expect(seen.first, closeTo(350, 0.001));
      expect(seen.last, closeTo(300, 0.001));
    });

    test(
      'emits again when the ingredients of a dish it counts change',
      () async {
        final cooked = await catalogue.saveCompositeFood(
          CompositeFood(
            name: 'Reis, gekocht',
            ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
            preparedGrams: 500,
          ),
        );
        await log(item: cooked, grams: 250);
        final seen = <double>[];
        final subscription = repository
            .watchDay(day)
            .listen((nutrition) => seen.add(nutrition.total.kcal));
        addTearDown(subscription.cancel);

        await pumpEventQueue();
        await catalogue.saveCompositeFood(
          CompositeFood(
            id: cooked.id,
            name: 'Reis, gekocht',
            ingredients: [CompositeFoodIngredient(food: rice, grams: 100)],
            preparedGrams: 500,
          ),
        );
        await pumpEventQueue();

        expect(seen.first, closeTo(350, 0.001));
        expect(seen.last, closeTo(175, 0.001));
      },
    );
  });

  group('the database itself', () {
    // The repository already sees to this, so a raw statement stands in for
    // the ways past it — a later migration, or someone editing the file.
    Future<void> insertEntry(String foodId, String compositeFoodId) =>
        database.customStatement(
          'INSERT INTO meal_entries (date, meal_type, food_id, '
          'composite_food_id, grams, created_at, updated_at) '
          "VALUES ('2026-08-20', 'lunch', $foodId, $compositeFoodId, 100, "
          '0, 0)',
        );

    test('refuses an entry that points at nothing', () {
      expect(
        () => insertEntry('NULL', 'NULL'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('CHECK constraint failed'),
          ),
        ),
      );
    });

    test('refuses an entry that points at both', () async {
      final cooked = await catalogue.saveCompositeFood(
        CompositeFood(
          name: 'Reis, gekocht',
          ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
        ),
      );

      expect(
        () => insertEntry('${rice.id}', '${cooked.id}'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('CHECK constraint failed'),
          ),
        ),
      );
    });

    test('refuses an entry pointing at a food that is not there', () {
      expect(
        () => insertEntry('404', 'NULL'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('FOREIGN KEY constraint failed'),
          ),
        ),
      );
    });
  });
}
