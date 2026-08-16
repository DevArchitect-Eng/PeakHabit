import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';

void main() {
  group('validation', () {
    test('accepts a split that adds up to 100 percent', () {
      final split = MacroDistribution(
        proteinPercent: 25,
        carbPercent: 45,
        fatPercent: 30,
      );

      expect(split.proteinPercent, 25);
      expect(split.carbPercent, 45);
      expect(split.fatPercent, 30);
    });

    test('rejects a split below 100 percent', () {
      expect(
        () => MacroDistribution(
          proteinPercent: 30,
          carbPercent: 30,
          fatPercent: 30,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a split above 100 percent', () {
      expect(
        () => MacroDistribution(
          proteinPercent: 40,
          carbPercent: 40,
          fatPercent: 40,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a negative share even when the total is 100 percent', () {
      expect(
        () => MacroDistribution(
          proteinPercent: -10,
          carbPercent: 60,
          fatPercent: 50,
        ),
        throwsArgumentError,
      );
    });

    test('starts at 30 percent protein, 40 carbs, 30 fat', () {
      expect(MacroDistribution.standard.proteinPercent, 30);
      expect(MacroDistribution.standard.carbPercent, 40);
      expect(MacroDistribution.standard.fatPercent, 30);
    });
  });

  group('gram targets', () {
    test('splits the calorie target at 4, 4 and 9 kcal per gram', () {
      final targets = MacroDistribution.standard.gramsFor(2000);

      // 30% of 2000 kcal = 600 kcal / 4 = 150 g protein
      expect(targets.proteinGrams, 150);
      // 40% of 2000 kcal = 800 kcal / 4 = 200 g carbohydrates
      expect(targets.carbGrams, 200);
      // 30% of 2000 kcal = 600 kcal / 9 = 66.67 g fat
      expect(targets.fatGrams, closeTo(66.67, 0.01));
    });

    test('follows the calorie target when it changes', () {
      final before = MacroDistribution.standard.gramsFor(2000);
      final after = MacroDistribution.standard.gramsFor(2500);

      expect(after.proteinGrams, 187.5);
      expect(after.proteinGrams, greaterThan(before.proteinGrams));
      expect(after.carbGrams, greaterThan(before.carbGrams));
      expect(after.fatGrams, greaterThan(before.fatGrams));
    });

    test('follows the split when it changes', () {
      final highProtein = MacroDistribution(
        proteinPercent: 50,
        carbPercent: 20,
        fatPercent: 30,
      ).gramsFor(2000);

      expect(highProtein.proteinGrams, 250);
      expect(highProtein.carbGrams, 100);
    });

    test('adds back up to the calorie target', () {
      final targets = MacroDistribution(
        proteinPercent: 35,
        carbPercent: 40,
        fatPercent: 25,
      ).gramsFor(1800);

      final kcal =
          targets.proteinGrams * 4 +
          targets.carbGrams * 4 +
          targets.fatGrams * 9;
      expect(kcal, closeTo(1800, 0.001));
    });

    test('rejects a negative calorie target', () {
      expect(
        () => MacroDistribution.standard.gramsFor(-100),
        throwsArgumentError,
      );
    });
  });

  test('two splits with the same shares are equal', () {
    expect(
      MacroDistribution(proteinPercent: 30, carbPercent: 40, fatPercent: 30),
      MacroDistribution.standard,
    );
  });
}
