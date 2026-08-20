import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';

void main() {
  Nutrients nutrients({
    double kcal = 100,
    double protein = 10,
    double carbs = 20,
    double fat = 5,
  }) => Nutrients(
    kcal: kcal,
    proteinGrams: protein,
    carbGrams: carbs,
    fatGrams: fat,
  );

  group('construction', () {
    test('keeps what it was given', () {
      final value = nutrients();

      expect(value.kcal, 100);
      expect(value.proteinGrams, 10);
      expect(value.carbGrams, 20);
      expect(value.fatGrams, 5);
    });

    test('refuses a negative amount', () {
      expect(() => nutrients(kcal: -1), throwsArgumentError);
      expect(() => nutrients(protein: -1), throwsArgumentError);
      expect(() => nutrients(carbs: -1), throwsArgumentError);
      expect(() => nutrients(fat: -1), throwsArgumentError);
    });

    test('refuses an amount that is not a number', () {
      expect(() => nutrients(kcal: double.nan), throwsArgumentError);
      expect(() => nutrients(kcal: double.infinity), throwsArgumentError);
    });

    test('takes zero', () {
      expect(nutrients(kcal: 0, protein: 0, carbs: 0, fat: 0), Nutrients.zero);
    });
  });

  group('adding up', () {
    test('adds macronutrient by macronutrient', () {
      final sum =
          nutrients() + nutrients(kcal: 50, protein: 1, carbs: 2, fat: 3);

      expect(sum.kcal, 150);
      expect(sum.proteinGrams, 11);
      expect(sum.carbGrams, 22);
      expect(sum.fatGrams, 8);
    });

    test('zero changes nothing', () {
      expect(nutrients() + Nutrients.zero, nutrients());
      expect(Nutrients.zero + nutrients(), nutrients());
    });
  });

  group('scaling', () {
    test('takes the amount the given number of times', () {
      final scaled = nutrients().scaled(2.5);

      expect(scaled.kcal, 250);
      expect(scaled.proteinGrams, 25);
      expect(scaled.carbGrams, 50);
      expect(scaled.fatGrams, 12.5);
    });

    test('scaling by one changes nothing', () {
      expect(nutrients().scaled(1), nutrients());
    });

    test('scaling by zero leaves nothing', () {
      expect(nutrients().scaled(0), Nutrients.zero);
    });

    test('refuses a negative factor', () {
      expect(() => nutrients().scaled(-1), throwsArgumentError);
    });

    test('leaves the energy where it is instead of deriving it', () {
      // 4 kcal per gram of protein and carbohydrate, 9 per gram of fat would
      // make 165 kcal out of these macros — the label says 200, and the label
      // is what the user typed in.
      final labelled = Nutrients(
        kcal: 200,
        proteinGrams: 10,
        carbGrams: 20,
        fatGrams: 5,
      );

      expect(labelled.scaled(2).kcal, 400);
    });
  });

  group('equality', () {
    test('two equal amounts are the same value', () {
      expect(nutrients(), nutrients());
      expect(nutrients().hashCode, nutrients().hashCode);
    });

    test('a difference in any macronutrient tells them apart', () {
      expect(nutrients(), isNot(nutrients(kcal: 101)));
      expect(nutrients(), isNot(nutrients(protein: 11)));
      expect(nutrients(), isNot(nutrients(carbs: 21)));
      expect(nutrients(), isNot(nutrients(fat: 6)));
    });
  });
}
