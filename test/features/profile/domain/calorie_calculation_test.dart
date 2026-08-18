import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/calorie_calculation.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

void main() {
  CalorieCalculation calculationFor({
    double weightKg = 80,
    int heightCm = 180,
    int ageYears = 30,
    BiologicalSex sex = BiologicalSex.male,
    ActivityLevel activityLevel = ActivityLevel.moderatelyActive,
    WeightGoal goal = WeightGoal.maintain,
  }) => CalorieCalculation(
    weightKg: weightKg,
    heightCm: heightCm,
    ageYears: ageYears,
    sex: sex,
    activityLevel: activityLevel,
    goal: goal,
  );

  group('basal metabolic rate', () {
    // 10 × 80 + 6.25 × 180 − 5 × 30 + 5
    test('follows Mifflin-St Jeor for a man', () {
      expect(calculationFor().basalMetabolicRate, 1780);
    });

    // 10 × 65 + 6.25 × 165 − 5 × 30 − 161
    test('follows Mifflin-St Jeor for a woman', () {
      final calculation = calculationFor(
        weightKg: 65,
        heightCm: 165,
        sex: BiologicalSex.female,
      );

      expect(calculation.basalMetabolicRate, 1370.25);
    });

    test('falls with age', () {
      final younger = calculationFor(ageYears: 30).basalMetabolicRate;
      final older = calculationFor(ageYears: 50).basalMetabolicRate;

      expect(younger - older, 100);
    });
  });

  group('total energy expenditure', () {
    test('multiplies the basal rate by the activity factor', () {
      final calculation = calculationFor(
        activityLevel: ActivityLevel.sedentary,
      );

      expect(calculation.totalEnergyExpenditure, closeTo(1780 * 1.2, 0.001));
    });

    test('rises from one activity level to the next', () {
      final factors = ActivityLevel.values
          .map((level) => level.calorieFactor)
          .toList();

      expect(factors, [1.2, 1.375, 1.55, 1.725, 1.9]);
    });
  });

  group('goal adjustment', () {
    test('takes 500 kcal a day off for losing half a kilo a week', () {
      expect(WeightGoal.lose.weeklyWeightChangeGrams, -500);
      expect(WeightGoal.lose.dailyCalorieAdjustment, -500);
    });

    test('changes nothing for maintaining', () {
      expect(WeightGoal.maintain.dailyCalorieAdjustment, 0);
    });

    test('adds 200 kcal a day for gaining 200 grams a week', () {
      expect(WeightGoal.gain.weeklyWeightChangeGrams, 200);
      expect(WeightGoal.gain.dailyCalorieAdjustment, 200);
    });
  });

  group('calorie target', () {
    // 1780 × 1.55 = 2759
    test('is the total expenditure while the weight is to stay', () {
      expect(calculationFor().calorieTarget, 2759);
    });

    test('is the total expenditure minus the deficit while losing', () {
      expect(calculationFor(goal: WeightGoal.lose).calorieTarget, 2259);
    });

    test('is the total expenditure plus the surplus while gaining', () {
      expect(calculationFor(goal: WeightGoal.gain).calorieTarget, 2959);
    });

    test('is a whole number of kcal', () {
      // 1370.25 × 1.375 = 1884.09375
      final calculation = calculationFor(
        weightKg: 65,
        heightCm: 165,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.lightlyActive,
      );

      expect(calculation.calorieTarget, 1884);
    });
  });

  group('validation', () {
    test('refuses a weight of zero', () {
      expect(() => calculationFor(weightKg: 0), throwsArgumentError);
    });

    test('refuses a weight that is not a number', () {
      expect(() => calculationFor(weightKg: double.nan), throwsArgumentError);
    });

    test('refuses a height of zero', () {
      expect(() => calculationFor(heightCm: 0), throwsArgumentError);
    });

    test('refuses a negative age', () {
      expect(() => calculationFor(ageYears: -1), throwsArgumentError);
    });
  });

  group('for a profile', () {
    final today = DateTime(2026, 8, 18);
    final complete = UserProfile(
      heightCm: 180,
      sex: BiologicalSex.male,
      birthDate: DateTime(1996, 8, 18),
      activityLevel: ActivityLevel.moderatelyActive,
      goal: WeightGoal.lose,
    );

    test('takes its age from the birth date', () {
      final calculation = CalorieCalculation.forProfile(
        complete,
        weightKg: 80,
        today: today,
      );

      expect(calculation?.ageYears, 30);
      expect(calculation?.calorieTarget, 2259);
    });

    test('is nothing without a weight entry', () {
      expect(
        CalorieCalculation.forProfile(complete, weightKg: null, today: today),
        isNull,
      );
    });

    test('is nothing while a profile value is missing', () {
      final incomplete = {
        'height': complete.copyWith(heightCm: null),
        'sex': complete.copyWith(sex: null),
        'birth date': complete.copyWith(birthDate: null),
        'activity level': complete.copyWith(activityLevel: null),
      };

      for (final entry in incomplete.entries) {
        expect(
          CalorieCalculation.forProfile(
            entry.value,
            weightKg: 80,
            today: today,
          ),
          isNull,
          reason: 'a profile without a ${entry.key} cannot be calculated',
        );
      }
    });

    test('carries the goal of the profile', () {
      final calculation = CalorieCalculation.forProfile(
        complete.copyWith(goal: WeightGoal.gain),
        weightKg: 80,
        today: today,
      );

      expect(calculation?.goal, WeightGoal.gain);
    });
  });
}
