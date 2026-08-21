import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/day_nutrition.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  final day = DateTime(2026, 8, 20);

  /// 100 g carry 100 kcal and 10 g of every macronutrient, so a sum is easy
  /// to read off the amounts.
  final round = Food(
    id: 1,
    name: 'Rundes',
    nutrientsPer100g: Nutrients(
      kcal: 100,
      proteinGrams: 10,
      carbGrams: 10,
      fatGrams: 10,
    ),
  );

  MealEntry entryOf(MealType mealType, double grams, {int? id}) => MealEntry(
    id: id,
    date: day,
    mealType: mealType,
    item: round,
    grams: grams,
  );

  test('a day without entries adds up to nothing', () {
    final nutrition = DayNutrition.empty(day);

    expect(nutrition.isEmpty, isTrue);
    expect(nutrition.entries, isEmpty);
    expect(nutrition.total, Nutrients.zero);
    for (final mealType in MealType.values) {
      expect(nutrition.totalOf(mealType), Nutrients.zero);
    }
  });

  test('keeps only the calendar day', () {
    expect(DayNutrition.empty(DateTime(2026, 8, 20, 22)).date, day);
  });

  test('sorts the entries into their meals', () {
    final breakfast = entryOf(MealType.breakfast, 100);
    final snack = entryOf(MealType.snacks, 50);

    final nutrition = DayNutrition(date: day, entries: [snack, breakfast]);

    expect(nutrition.entriesOf(MealType.breakfast), [breakfast]);
    expect(nutrition.entriesOf(MealType.snacks), [snack]);
    expect(nutrition.entriesOf(MealType.lunch), isEmpty);
    expect(nutrition.isEmpty, isFalse);
  });

  test('lists the entries meal by meal, whatever order they came in', () {
    final breakfast = entryOf(MealType.breakfast, 100);
    final lunch = entryOf(MealType.lunch, 200);
    final snack = entryOf(MealType.snacks, 50);

    final nutrition = DayNutrition(
      date: day,
      entries: [snack, lunch, breakfast],
    );

    expect(nutrition.entries, [breakfast, lunch, snack]);
  });

  test('adds up each meal on its own', () {
    final nutrition = DayNutrition(
      date: day,
      entries: [
        entryOf(MealType.breakfast, 100),
        entryOf(MealType.breakfast, 150),
        entryOf(MealType.dinner, 200),
      ],
    );

    expect(nutrition.totalOf(MealType.breakfast).kcal, closeTo(250, 0.001));
    expect(nutrition.totalOf(MealType.dinner).kcal, closeTo(200, 0.001));
    expect(nutrition.totalOf(MealType.lunch), Nutrients.zero);
  });

  test('adds the whole day up over all four meals', () {
    final nutrition = DayNutrition(
      date: day,
      entries: [
        entryOf(MealType.breakfast, 100),
        entryOf(MealType.lunch, 200),
        entryOf(MealType.dinner, 300),
        entryOf(MealType.snacks, 50),
      ],
    );

    expect(nutrition.total.kcal, closeTo(650, 0.001));
    expect(nutrition.total.proteinGrams, closeTo(65, 0.001));
    expect(nutrition.total.carbGrams, closeTo(65, 0.001));
    expect(nutrition.total.fatGrams, closeTo(65, 0.001));
  });

  test('counts a dish by what it really carries', () {
    // 200 g of raw rice cooked down to 500 g: whoever eats 250 g of it has
    // eaten half the pot, not 250 g of raw rice.
    final rice = Food(
      id: 2,
      name: 'Reis, roh',
      nutrientsPer100g: Nutrients(
        kcal: 350,
        proteinGrams: 7,
        carbGrams: 78,
        fatGrams: 1,
      ),
    );
    final cooked = CompositeFood(
      id: 1,
      name: 'Reis, gekocht',
      ingredients: [CompositeFoodIngredient(food: rice, grams: 200)],
      preparedGrams: 500,
    );

    final nutrition = DayNutrition(
      date: day,
      entries: [
        MealEntry(
          date: day,
          mealType: MealType.lunch,
          item: cooked,
          grams: 250,
        ),
      ],
    );

    expect(nutrition.total.kcal, closeTo(350, 0.001));
    expect(nutrition.totalOf(MealType.lunch).kcal, closeTo(350, 0.001));
  });

  test('refuses an entry from another day', () {
    expect(
      () => DayNutrition(
        date: day,
        entries: [
          MealEntry(
            date: DateTime(2026, 8, 21),
            mealType: MealType.lunch,
            item: round,
            grams: 100,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('does not let its entries be changed from outside', () {
    final nutrition = DayNutrition.empty(day);

    expect(
      () =>
          nutrition.entriesOf(MealType.lunch).add(entryOf(MealType.lunch, 100)),
      throwsUnsupportedError,
    );
  });
}
