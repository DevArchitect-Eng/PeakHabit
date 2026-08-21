import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

/// 100 g of raw rice: 350 kcal, 7 g protein, 78 g carbohydrate, 1 g fat.
final rawRice = Food(
  id: 1,
  name: 'Reis, roh',
  nutrientsPer100g: Nutrients(
    kcal: 350,
    proteinGrams: 7,
    carbGrams: 78,
    fatGrams: 1,
  ),
);

/// 100 g of oil: 900 kcal, nothing but fat.
final oil = Food(
  id: 2,
  name: 'Rapsöl',
  nutrientsPer100g: Nutrients(
    kcal: 900,
    proteinGrams: 0,
    carbGrams: 0,
    fatGrams: 100,
  ),
);

void main() {
  group('Food', () {
    test('starts out manual and without an id', () {
      final food = Food(name: 'Quark', nutrientsPer100g: Nutrients.zero);

      expect(food.id, isNull);
      expect(food.source, FoodSource.manual);
      expect(food.barcode, isNull);
    });

    test('trims the name', () {
      final food = Food(name: '  Quark ', nutrientsPer100g: Nutrients.zero);

      expect(food.name, 'Quark');
    });

    test('refuses a blank name', () {
      expect(
        () => Food(name: '   ', nutrientsPer100g: Nutrients.zero),
        throwsArgumentError,
      );
    });

    test('refuses a portion of zero or less', () {
      expect(
        () => Food(
          name: 'Riegel',
          nutrientsPer100g: Nutrients.zero,
          portionGrams: 0,
        ),
        throwsArgumentError,
      );
    });

    test('takes a blank brand and barcode for no answer', () {
      final food = Food(
        name: 'Quark',
        brand: '  ',
        barcode: '',
        nutrientsPer100g: Nutrients.zero,
      );

      expect(food.brand, isNull);
      expect(food.barcode, isNull);
    });

    test('keeps a brand and a barcode it was given', () {
      final food = Food(
        name: 'Vollmilch',
        brand: ' Weihenstephan ',
        barcode: ' 4008100097216 ',
        source: FoodSource.scanned,
        nutrientsPer100g: Nutrients.zero,
      );

      expect(food.brand, 'Weihenstephan');
      expect(food.barcode, '4008100097216');
      expect(food.source, FoodSource.scanned);
    });

    test('scales its nutrients to an amount', () {
      final eaten = rawRice.nutrientsFor(50);

      expect(eaten.kcal, 175);
      expect(eaten.proteinGrams, 3.5);
      expect(eaten.carbGrams, 39);
      expect(eaten.fatGrams, 0.5);
    });

    test('refuses a negative amount', () {
      expect(() => rawRice.nutrientsFor(-1), throwsArgumentError);
    });

    test('carries the row id it was saved under', () {
      final food = Food(name: 'Quark', nutrientsPer100g: Nutrients.zero);

      expect(food.withId(7).id, 7);
      expect(food.withId(7).name, 'Quark');
    });

    test('two equal foods are the same value', () {
      expect(
        rawRice,
        Food(
          id: 1,
          name: 'Reis, roh',
          nutrientsPer100g: rawRice.nutrientsPer100g,
        ),
      );
      expect(rawRice, isNot(oil));
    });
  });

  group('CompositeFoodIngredient', () {
    test('contributes what its amount of the food carries', () {
      final ingredient = CompositeFoodIngredient(food: rawRice, grams: 200);

      expect(ingredient.nutrients.kcal, 700);
      expect(ingredient.nutrients.carbGrams, 156);
    });

    test('refuses an amount of zero or less', () {
      expect(
        () => CompositeFoodIngredient(food: rawRice, grams: 0),
        throwsArgumentError,
      );
      expect(
        () => CompositeFoodIngredient(food: rawRice, grams: -1),
        throwsArgumentError,
      );
    });
  });

  group('CompositeFood', () {
    CompositeFood dish({double? preparedGrams}) => CompositeFood(
      name: 'Reis mit Öl',
      ingredients: [
        CompositeFoodIngredient(food: rawRice, grams: 100),
        CompositeFoodIngredient(food: oil, grams: 10),
      ],
      preparedGrams: preparedGrams,
    );

    test('adds its ingredients up', () {
      final total = dish().totalNutrients;

      expect(total.kcal, 350 + 90);
      expect(total.proteinGrams, 7);
      expect(total.carbGrams, 78);
      expect(total.fatGrams, 1 + 10);
    });

    test('weighs as much as its ingredients unless it was weighed', () {
      expect(dish().totalGrams, 110);
      expect(dish(preparedGrams: 300).totalGrams, 300);
    });

    test('spreads its nutrients over the raw weight by default', () {
      final per100g = dish().nutrientsPer100g;

      expect(per100g.kcal, closeTo(400, 0.001));
      expect(per100g.fatGrams, closeTo(10, 0.001));
    });

    test(
      'spreads its nutrients over the prepared weight when it was weighed',
      () {
        // 100 g of raw rice come out of the pot as roughly 260 g; with the 10 g
        // of oil the dish weighs 270 g. The same 440 kcal are then spread over
        // more than twice the weight.
        final per100g = dish(preparedGrams: 270).nutrientsPer100g;

        expect(per100g.kcal, closeTo(440 / 2.7, 0.001));
      },
    );

    test('an amount off the plate counts what it really carries', () {
      // Weighing 200 g of the cooked dish is not 200 g of raw ingredients.
      final eaten = dish(preparedGrams: 270).nutrientsFor(200);

      expect(eaten.kcal, closeTo(440 * 200 / 270, 0.001));
    });

    test('refuses a dish without ingredients', () {
      expect(
        () => CompositeFood(name: 'Nichts', ingredients: const []),
        throwsArgumentError,
      );
    });

    test('refuses a blank name', () {
      expect(
        () => CompositeFood(
          name: ' ',
          ingredients: [CompositeFoodIngredient(food: rawRice, grams: 100)],
        ),
        throwsArgumentError,
      );
    });

    test('refuses the same food twice', () {
      expect(
        () => CompositeFood(
          name: 'Reis',
          ingredients: [
            CompositeFoodIngredient(food: rawRice, grams: 100),
            CompositeFoodIngredient(food: rawRice, grams: 50),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('refuses a prepared weight of zero or less', () {
      expect(() => dish(preparedGrams: 0), throwsArgumentError);
      expect(() => dish(preparedGrams: -1), throwsArgumentError);
    });

    test('does not let its ingredients be changed from outside', () {
      expect(
        () => dish().ingredients.add(
          CompositeFoodIngredient(food: oil, grams: 1),
        ),
        throwsUnsupportedError,
      );
    });

    test('carries the row id it was saved under', () {
      expect(dish().withId(7).id, 7);
      expect(dish().withId(7).ingredients, dish().ingredients);
    });

    test('keeps its ingredients by name, whatever order they came in', () {
      final asListed = CompositeFood(
        name: 'Reis mit Öl',
        ingredients: [
          CompositeFoodIngredient(food: rawRice, grams: 100),
          CompositeFoodIngredient(food: oil, grams: 10),
        ],
      );
      final theOtherWayRound = CompositeFood(
        name: 'Reis mit Öl',
        ingredients: [
          CompositeFoodIngredient(food: oil, grams: 10),
          CompositeFoodIngredient(food: rawRice, grams: 100),
        ],
      );

      expect(asListed.ingredients.map((it) => it.food.name), [
        'Rapsöl',
        'Reis, roh',
      ]);
      expect(asListed, theOtherWayRound);
    });

    test('two equal dishes are the same value', () {
      expect(dish(), dish());
      expect(dish().hashCode, dish().hashCode);
      expect(dish(), isNot(dish(preparedGrams: 300)));
    });

    test('a different ingredient tells two dishes apart', () {
      final other = CompositeFood(
        name: 'Reis mit Öl',
        ingredients: [
          CompositeFoodIngredient(food: rawRice, grams: 100),
          CompositeFoodIngredient(food: oil, grams: 20),
        ],
      );

      expect(dish(), isNot(other));
    });
  });
}
