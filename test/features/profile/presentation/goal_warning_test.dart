import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/calorie_calculation.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/goal_warning.dart';

void main() {
  /// A calculation for a 30-year-old man of 80 kg and 180 cm.
  ///
  /// His basal rate is 10 × 80 + 6.25 × 180 − 5 × 30 + 5 = 1780 kcal, which is
  /// the line the floor warning watches.
  CalorieCalculation calculationFor({
    required ActivityLevel activityLevel,
    required WeightGoal goal,
    double weightKg = 80,
    int heightCm = 180,
  }) => CalorieCalculation(
    weightKg: weightKg,
    heightCm: heightCm,
    ageYears: 30,
    sex: BiologicalSex.male,
    activityLevel: activityLevel,
    goal: goal,
  );

  group('the rate', () {
    test('earns nothing at the four moderate steps and at holding', () {
      const moderate = [
        WeightGoal.gain200,
        WeightGoal.gain500,
        WeightGoal.maintain,
        WeightGoal.lose200,
        WeightGoal.lose500,
      ];

      for (final goal in moderate) {
        expect(goalWarnings(goal: goal), isEmpty, reason: 'for $goal');
      }
    });

    test('earns a word at the fastest gain', () {
      expect(goalWarnings(goal: WeightGoal.gain800), [
        GoalWarning.surplusTooHigh,
      ]);
    });

    test('earns a word at both of the fastest losses', () {
      expect(goalWarnings(goal: WeightGoal.lose800), [
        GoalWarning.deficitTooHigh,
      ]);
      expect(goalWarnings(goal: WeightGoal.lose1000), [
        GoalWarning.deficitTooHigh,
      ]);
    });

    test('says nothing while it was not the thing picked', () {
      // The goals screen leaves `goal` out when the activity level was what
      // changed, so a rate the user already acknowledged does not come back.
      expect(goalWarnings(), isEmpty);
    });
  });

  group('the calculated target', () {
    test('earns a word once it falls under the basal rate', () {
      // 1780 × 1.2 = 2136, minus 500 is 1636 — under the 1780 he burns lying
      // still, at a rate that is not itself aggressive.
      final calculation = calculationFor(
        activityLevel: ActivityLevel.sedentary,
        goal: WeightGoal.lose500,
      );

      expect(goalWarnings(calculation: calculation), [
        GoalWarning.belowBasalRate,
      ]);
    });

    test('stays quiet while it is above the basal rate', () {
      // 1780 × 1.55 = 2759, minus 500 is 2259.
      final calculation = calculationFor(
        activityLevel: ActivityLevel.moderatelyActive,
        goal: WeightGoal.lose500,
      );

      expect(goalWarnings(calculation: calculation), isEmpty);
    });

    test('stays quiet while there is no calculation to make', () {
      expect(goalWarnings(goal: WeightGoal.lose500), isEmpty);
    });

    test('stays quiet on a target at or below zero', () {
      // Body data that far off produces a target nothing stores, so there is
      // no target to warn about — the screens say so in their own words.
      final calculation = calculationFor(
        activityLevel: ActivityLevel.sedentary,
        goal: WeightGoal.maintain,
        weightKg: 1,
        heightCm: 1,
      );

      expect(calculation.calorieTarget, lessThanOrEqualTo(0));
      expect(goalWarnings(calculation: calculation), isEmpty);
    });
  });

  test('a single choice can earn both the rate and the floor', () {
    // 2136 − 1000 = 1136, well under the 1780 basal rate, at the steepest rate
    // on offer. Both are true and both are said, in one dialog.
    final calculation = calculationFor(
      activityLevel: ActivityLevel.sedentary,
      goal: WeightGoal.lose1000,
    );

    expect(goalWarnings(goal: WeightGoal.lose1000, calculation: calculation), [
      GoalWarning.deficitTooHigh,
      GoalWarning.belowBasalRate,
    ]);
  });

  test('every warning carries wording of its own', () {
    final messages = GoalWarning.values.map((w) => w.message).toSet();

    expect(messages, hasLength(GoalWarning.values.length));
    expect(messages.every((message) => message.isNotEmpty), isTrue);
  });
}
