import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  final quark = Food(
    id: 1,
    name: 'Magerquark',
    nutrientsPer100g: Nutrients(
      kcal: 67,
      proteinGrams: 12,
      carbGrams: 4,
      fatGrams: 0.3,
    ),
  );

  MealEntry entry({
    int? id,
    DateTime? date,
    MealType mealType = MealType.breakfast,
    double grams = 250,
  }) => MealEntry(
    id: id,
    date: date ?? DateTime(2026, 8, 20),
    mealType: mealType,
    item: quark,
    grams: grams,
  );

  test('carries what its amount of the item holds', () {
    final nutrients = entry().nutrients;

    expect(nutrients.kcal, closeTo(167.5, 0.001));
    expect(nutrients.proteinGrams, closeTo(30, 0.001));
  });

  test('refuses an amount of zero or less', () {
    expect(() => entry(grams: 0), throwsArgumentError);
    expect(() => entry(grams: -1), throwsArgumentError);
  });

  test('refuses an amount that is not a number', () {
    expect(() => entry(grams: double.nan), throwsArgumentError);
  });

  test('keeps only the calendar day', () {
    final withTime = entry(date: DateTime(2026, 8, 20, 7, 30));

    expect(withTime.date, DateTime(2026, 8, 20));
  });

  test('carries the row id it was saved under', () {
    expect(entry().id, isNull);
    expect(entry().withId(7).id, 7);
    expect(entry().withId(7).grams, 250);
  });

  test('takes a dish just as well as a food', () {
    final dish = CompositeFood(
      name: 'Quarkspeise',
      ingredients: [CompositeFoodIngredient(food: quark, grams: 200)],
    );

    final logged = MealEntry(
      date: DateTime(2026, 8, 20),
      mealType: MealType.snacks,
      item: dish,
      grams: 100,
    );

    expect(logged.nutrients.kcal, closeTo(67, 0.001));
  });

  test('two equal entries are the same value', () {
    expect(entry(), entry());
    expect(entry().hashCode, entry().hashCode);
    expect(entry(), isNot(entry(grams: 200)));
    expect(entry(), isNot(entry(mealType: MealType.dinner)));
    expect(entry(), isNot(entry(date: DateTime(2026, 8, 21))));
  });

  test('offers the four meals of a day', () {
    expect(MealType.values, [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snacks,
    ]);
  });
}
