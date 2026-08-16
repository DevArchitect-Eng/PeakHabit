import 'macro_distribution.dart';

/// What the user wants their body weight to do.
enum WeightGoal { lose, maintain, gain }

/// Needed by the calorie formulas, which use a different constant for women
/// and men. `diverse` has no formula of its own — the feature that calculates
/// the calorie target decides how to treat it.
enum BiologicalSex { female, male, diverse }

/// How much the user moves on an average day, from a desk job without sport up
/// to daily hard training or physical work.
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

/// The single user profile of the app.
///
/// Body weight is deliberately not part of it: it changes constantly and is
/// kept as its own series of dated entries.
///
/// Everything the user has not filled in yet is `null`, because the onboarding
/// may be skipped. Only the goal and the macro split start with a value, so a
/// fresh profile is already usable.
class UserProfile {
  const UserProfile._({
    this.heightCm,
    this.sex,
    this.birthDate,
    this.activityLevel,
    this.goal = WeightGoal.maintain,
    this.calorieTarget,
    this.macros = MacroDistribution.standard,
  });

  /// Throws an [ArgumentError] on a height or calorie target that cannot be
  /// meant seriously.
  ///
  /// Checked here rather than by an `assert`, which only holds in debug builds:
  /// a release build would take a negative calorie target, store it, and then
  /// fail somewhere entirely different when the gram targets are derived from
  /// it. Rejecting it right at the entry point puts the error where the value
  /// comes from, which is where the UI can react to it.
  factory UserProfile({
    int? heightCm,
    BiologicalSex? sex,
    DateTime? birthDate,
    ActivityLevel? activityLevel,
    WeightGoal goal = WeightGoal.maintain,
    int? calorieTarget,
    MacroDistribution macros = MacroDistribution.standard,
  }) {
    if (heightCm != null && heightCm <= 0) {
      throw ArgumentError.value(heightCm, 'heightCm', 'must be positive');
    }
    if (calorieTarget != null && calorieTarget <= 0) {
      throw ArgumentError.value(
        calorieTarget,
        'calorieTarget',
        'must be positive',
      );
    }

    return UserProfile._(
      heightCm: heightCm,
      sex: sex,
      birthDate: birthDate,
      activityLevel: activityLevel,
      goal: goal,
      calorieTarget: calorieTarget,
      macros: macros,
    );
  }

  /// A profile with nothing filled in — what the app starts on before the user
  /// has entered anything.
  static const empty = UserProfile._();

  /// Body height in centimetres.
  final int? heightCm;

  final BiologicalSex? sex;

  /// Kept instead of an age so the age stays right as time passes.
  final DateTime? birthDate;

  final ActivityLevel? activityLevel;

  final WeightGoal goal;

  /// Daily calorie target in kcal — `null` until it is entered or calculated.
  final int? calorieTarget;

  final MacroDistribution macros;

  /// Age in full years on [reference], `null` without a birth date.
  int? ageOn(DateTime reference) {
    final birthDate = this.birthDate;
    if (birthDate == null) return null;

    final hadBirthdayThisYear =
        reference.month > birthDate.month ||
        (reference.month == birthDate.month && reference.day >= birthDate.day);
    return reference.year - birthDate.year - (hadBirthdayThisYear ? 0 : 1);
  }

  /// The gram targets per macronutrient, `null` while no calorie target is set.
  MacroTargets? get macroTargets {
    final calorieTarget = this.calorieTarget;
    return calorieTarget == null ? null : macros.gramsFor(calorieTarget);
  }

  /// A copy with individual values replaced.
  ///
  /// Passing `null` clears a value, leaving the argument out keeps it — a plain
  /// `null` default could not tell those two apart.
  UserProfile copyWith({
    Object? heightCm = _keep,
    Object? sex = _keep,
    Object? birthDate = _keep,
    Object? activityLevel = _keep,
    WeightGoal? goal,
    Object? calorieTarget = _keep,
    MacroDistribution? macros,
  }) {
    return UserProfile(
      heightCm: identical(heightCm, _keep) ? this.heightCm : heightCm as int?,
      sex: identical(sex, _keep) ? this.sex : sex as BiologicalSex?,
      birthDate: identical(birthDate, _keep)
          ? this.birthDate
          : birthDate as DateTime?,
      activityLevel: identical(activityLevel, _keep)
          ? this.activityLevel
          : activityLevel as ActivityLevel?,
      goal: goal ?? this.goal,
      calorieTarget: identical(calorieTarget, _keep)
          ? this.calorieTarget
          : calorieTarget as int?,
      macros: macros ?? this.macros,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.heightCm == heightCm &&
      other.sex == sex &&
      other.birthDate == birthDate &&
      other.activityLevel == activityLevel &&
      other.goal == goal &&
      other.calorieTarget == calorieTarget &&
      other.macros == macros;

  @override
  int get hashCode => Object.hash(
    heightCm,
    sex,
    birthDate,
    activityLevel,
    goal,
    calorieTarget,
    macros,
  );

  @override
  String toString() =>
      'UserProfile(heightCm: $heightCm, sex: $sex, birthDate: $birthDate, '
      'activityLevel: $activityLevel, goal: $goal, '
      'calorieTarget: $calorieTarget, macros: $macros)';
}

/// Stands for "argument not given" in [UserProfile.copyWith].
const Object _keep = Object();
