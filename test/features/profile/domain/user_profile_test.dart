import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

void main() {
  group('defaults', () {
    test('a fresh profile keeps the goal and the standard macro split', () {
      const profile = UserProfile();

      expect(profile.goal, WeightGoal.maintain);
      expect(profile.macros, MacroDistribution.standard);
      expect(profile.heightCm, isNull);
      expect(profile.sex, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.activityLevel, isNull);
      expect(profile.calorieTarget, isNull);
    });
  });

  group('macro targets', () {
    test('stay null while no calorie target is set', () {
      expect(const UserProfile().macroTargets, isNull);
    });

    test('come from the calorie target and the split', () {
      const profile = UserProfile(calorieTarget: 2000);

      expect(profile.macroTargets?.proteinGrams, 150);
      expect(profile.macroTargets?.carbGrams, 200);
    });

    test('change with the calorie target without touching the split', () {
      const profile = UserProfile(calorieTarget: 2000);

      final raised = profile.copyWith(calorieTarget: 2400);

      expect(raised.macros, profile.macros);
      expect(raised.macroTargets?.proteinGrams, 180);
    });
  });

  group('age', () {
    test('is null without a birth date', () {
      expect(const UserProfile().ageOn(DateTime(2026, 8, 16)), isNull);
    });

    test('counts full years after the birthday', () {
      final profile = UserProfile(birthDate: DateTime(1990, 5, 17));

      expect(profile.ageOn(DateTime(2026, 8, 16)), 36);
    });

    test('does not count the year before the birthday', () {
      final profile = UserProfile(birthDate: DateTime(1990, 11, 17));

      expect(profile.ageOn(DateTime(2026, 8, 16)), 35);
    });

    test('counts the birthday itself', () {
      final profile = UserProfile(birthDate: DateTime(1990, 8, 16));

      expect(profile.ageOn(DateTime(2026, 8, 16)), 36);
    });
  });

  group('copyWith', () {
    test('keeps values that are not passed', () {
      final profile = UserProfile(
        heightCm: 182,
        sex: BiologicalSex.male,
        birthDate: DateTime(1990, 5, 17),
        activityLevel: ActivityLevel.moderatelyActive,
        goal: WeightGoal.lose,
        calorieTarget: 2200,
      );

      final changed = profile.copyWith(goal: WeightGoal.gain);

      expect(changed.goal, WeightGoal.gain);
      expect(changed.heightCm, 182);
      expect(changed.sex, BiologicalSex.male);
      expect(changed.birthDate, DateTime(1990, 5, 17));
      expect(changed.activityLevel, ActivityLevel.moderatelyActive);
      expect(changed.calorieTarget, 2200);
    });

    test('clears a value that is passed as null', () {
      const profile = UserProfile(heightCm: 182, calorieTarget: 2200);

      final cleared = profile.copyWith(calorieTarget: null);

      expect(cleared.calorieTarget, isNull);
      expect(cleared.heightCm, 182);
    });
  });

  test('two profiles with the same values are equal', () {
    final left = UserProfile(
      heightCm: 182,
      birthDate: DateTime(1990, 5, 17),
      calorieTarget: 2200,
    );
    final right = UserProfile(
      heightCm: 182,
      birthDate: DateTime(1990, 5, 17),
      calorieTarget: 2200,
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
  });
}
