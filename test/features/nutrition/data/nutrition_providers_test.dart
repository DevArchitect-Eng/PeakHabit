import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/nutrition/data/nutrition_providers.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  final day = DateTime(2026, 8, 20);

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  final rice = Food(
    name: 'Reis, roh',
    nutrientsPer100g: Nutrients(
      kcal: 350,
      proteinGrams: 7,
      carbGrams: 78,
      fatGrams: 1,
    ),
  );

  test('hands out a catalogue on the app database', () async {
    await container.read(foodRepositoryProvider).saveFood(rice);

    final rows = await database.select(database.foods).get();
    expect(rows.single.name, 'Reis, roh');
  });

  test('the foods provider follows what the catalogue saves', () async {
    final subscription = container.listen(
      foodsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(foodsProvider.future), isEmpty);

    await container.read(foodRepositoryProvider).saveFood(rice);
    await pumpEventQueue();

    expect(container.read(foodsProvider).value?.single.name, 'Reis, roh');
  });

  test('the dishes provider follows what the catalogue saves', () async {
    final subscription = container.listen(
      compositeFoodsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final catalogue = container.read(foodRepositoryProvider);
    final saved = await catalogue.saveFood(rice);
    await catalogue.saveCompositeFood(
      CompositeFood(
        name: 'Reis, gekocht',
        ingredients: [CompositeFoodIngredient(food: saved, grams: 200)],
        preparedGrams: 500,
      ),
    );
    await pumpEventQueue();

    final dishes = container.read(compositeFoodsProvider).value;
    expect(dishes?.single.name, 'Reis, gekocht');
    expect(dishes?.single.nutrientsPer100g.kcal, closeTo(140, 0.001));
  });

  test('the day provider follows what the diary saves', () async {
    final subscription = container.listen(
      dayNutritionProvider(day),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(
      (await container.read(dayNutritionProvider(day).future)).isEmpty,
      isTrue,
    );

    final saved = await container.read(foodRepositoryProvider).saveFood(rice);
    await container
        .read(mealEntryRepositoryProvider)
        .save(
          MealEntry(
            date: day,
            mealType: MealType.lunch,
            item: saved,
            grams: 100,
          ),
        );
    await pumpEventQueue();

    final nutrition = container.read(dayNutritionProvider(day)).value;
    expect(nutrition?.total.kcal, closeTo(350, 0.001));
    expect(nutrition?.entriesOf(MealType.lunch), hasLength(1));
  });

  test('another day is another query', () async {
    final subscription = container.listen(
      dayNutritionProvider(day),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final other = container.listen(
      dayNutritionProvider(DateTime(2026, 8, 21)),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(other.close);

    final saved = await container.read(foodRepositoryProvider).saveFood(rice);
    await container
        .read(mealEntryRepositoryProvider)
        .save(
          MealEntry(
            date: day,
            mealType: MealType.lunch,
            item: saved,
            grams: 100,
          ),
        );
    await pumpEventQueue();

    expect(container.read(dayNutritionProvider(day)).value?.isEmpty, isFalse);
    expect(
      container
          .read(dayNutritionProvider(DateTime(2026, 8, 21)))
          .value
          ?.isEmpty,
      isTrue,
    );
  });
}
