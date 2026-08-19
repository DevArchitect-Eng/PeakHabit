import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

void main() {
  group('validation', () {
    test('rejects a calorie target of zero or less', () {
      // Rejected outright, not by an assert: a release build would otherwise
      // store the value and only fail later, when the grams are derived.
      expect(() => UserProfile(calorieTarget: 0), throwsArgumentError);
      expect(() => UserProfile(calorieTarget: -100), throwsArgumentError);
    });

    test('rejects a height of zero or less', () {
      expect(() => UserProfile(heightCm: 0), throwsArgumentError);
      expect(() => UserProfile(heightCm: -5), throwsArgumentError);
    });

    test('rejects a bad value passed through copyWith as well', () {
      expect(
        () => UserProfile.empty.copyWith(calorieTarget: -1),
        throwsArgumentError,
      );
    });
  });

  group('defaults', () {
    test('a fresh profile keeps the goal and the standard macro split', () {
      final profile = UserProfile();

      expect(profile.goal, WeightGoal.maintain);
      expect(profile.macros, MacroDistribution.standard);
      expect(profile.username, '');
      expect(profile.heightCm, isNull);
      expect(profile.sex, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.activityLevel, isNull);
      expect(profile.calorieTarget, isNull);
    });
  });

  group('macro targets', () {
    test('stay null while no calorie target is set', () {
      expect(UserProfile.empty.macroTargets, isNull);
    });

    test('come from the calorie target and the split', () {
      final profile = UserProfile(calorieTarget: 2000);

      expect(profile.macroTargets?.proteinGrams, 150);
      expect(profile.macroTargets?.carbGrams, 200);
    });

    test('change with the calorie target without touching the split', () {
      final profile = UserProfile(calorieTarget: 2000);

      final raised = profile.copyWith(calorieTarget: 2400);

      expect(raised.macros, profile.macros);
      expect(raised.macroTargets?.proteinGrams, 180);
    });
  });

  group('age', () {
    test('is null without a birth date', () {
      expect(UserProfile.empty.ageOn(DateTime(2026, 8, 16)), isNull);
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
        username: 'mila',
        heightCm: 182,
        sex: BiologicalSex.male,
        birthDate: DateTime(1990, 5, 17),
        activityLevel: ActivityLevel.moderatelyActive,
        goal: WeightGoal.lose500,
        calorieTarget: 2200,
      );

      final changed = profile.copyWith(goal: WeightGoal.gain200);

      expect(changed.goal, WeightGoal.gain200);
      expect(changed.username, 'mila');
      expect(changed.heightCm, 182);
      expect(changed.sex, BiologicalSex.male);
      expect(changed.birthDate, DateTime(1990, 5, 17));
      expect(changed.activityLevel, ActivityLevel.moderatelyActive);
      expect(changed.calorieTarget, 2200);
    });

    test('replaces the username when one is passed', () {
      final profile = UserProfile(username: 'mila');

      final changed = profile.copyWith(username: 'ben');

      expect(changed.username, 'ben');
    });

    test('clears a value that is passed as null', () {
      final profile = UserProfile(heightCm: 182, calorieTarget: 2200);

      final cleared = profile.copyWith(calorieTarget: null);

      expect(cleared.calorieTarget, isNull);
      expect(cleared.heightCm, 182);
    });
  });

  test('two profiles with the same values are equal', () {
    final left = UserProfile(
      username: 'mila',
      heightCm: 182,
      birthDate: DateTime(1990, 5, 17),
      calorieTarget: 2200,
    );
    final right = UserProfile(
      username: 'mila',
      heightCm: 182,
      birthDate: DateTime(1990, 5, 17),
      calorieTarget: 2200,
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
  });

  test('profiles with a different username are not equal', () {
    expect(UserProfile(username: 'mila'), isNot(UserProfile(username: 'ben')));
  });
}
