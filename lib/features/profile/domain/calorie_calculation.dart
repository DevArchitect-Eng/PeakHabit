import 'user_profile.dart';

/// How the daily calorie target is derived from the profile and the current
/// body weight.
///
/// The chain is the one every calorie calculator uses: a basal metabolic rate
/// from body data, multiplied by an activity factor into the total energy
/// expenditure, plus an adjustment for the weight goal.
///
/// The whole thing is kept as a value object rather than a single function
/// because the intermediate steps are shown to the user — a bare number nobody
/// can retrace is easy to distrust and impossible to correct.
class CalorieCalculation {
  const CalorieCalculation._({
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    required this.sex,
    required this.activityLevel,
    required this.goal,
  });

  /// Throws an [ArgumentError] on body data that cannot be meant seriously.
  ///
  /// Same reasoning as in [UserProfile]: a release build would otherwise carry
  /// a negative weight through the formula and produce a calorie target that
  /// looks like a number but means nothing.
  factory CalorieCalculation({
    required double weightKg,
    required int heightCm,
    required int ageYears,
    required BiologicalSex sex,
    required ActivityLevel activityLevel,
    required WeightGoal goal,
  }) {
    if (!weightKg.isFinite || weightKg <= 0) {
      throw ArgumentError.value(weightKg, 'weightKg', 'must be positive');
    }
    if (heightCm <= 0) {
      throw ArgumentError.value(heightCm, 'heightCm', 'must be positive');
    }
    if (ageYears < 0) {
      throw ArgumentError.value(ageYears, 'ageYears', 'must not be negative');
    }

    return CalorieCalculation._(
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      sex: sex,
      activityLevel: activityLevel,
      goal: goal,
    );
  }

  /// The calculation for [profile] at [weightKg], or `null` while anything it
  /// needs is still missing.
  ///
  /// Body weight is not part of the profile — it comes from the weight entries
  /// and is passed in, which is also why it may be `null` here.
  ///
  /// [today] is what the age is counted against; passing it in keeps the
  /// result reproducible in a test instead of depending on the clock.
  static CalorieCalculation? forProfile(
    UserProfile profile, {
    required double? weightKg,
    required DateTime today,
  }) {
    final heightCm = profile.heightCm;
    final sex = profile.sex;
    final activityLevel = profile.activityLevel;
    final ageYears = profile.ageOn(today);

    if (weightKg == null ||
        heightCm == null ||
        sex == null ||
        activityLevel == null ||
        ageYears == null) {
      return null;
    }

    return CalorieCalculation(
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      sex: sex,
      activityLevel: activityLevel,
      goal: profile.goal,
    );
  }

  final double weightKg;
  final int heightCm;
  final int ageYears;
  final BiologicalSex sex;
  final ActivityLevel activityLevel;
  final WeightGoal goal;

  /// The basal metabolic rate in kcal per day, after Mifflin-St Jeor.
  ///
  /// `10 × kg + 6.25 × cm − 5 × years`, plus 5 for men and minus 161 for
  /// women. Picked over Harris-Benedict because it is the more accurate of the
  /// two for people who are not lean, which is most of the ones who track.
  double get basalMetabolicRate =>
      10 * weightKg +
      6.25 * heightCm -
      5 * ageYears +
      switch (sex) {
        BiologicalSex.male => 5,
        BiologicalSex.female => -161,
      };

  /// The basal rate times the factor of the activity level.
  double get totalEnergyExpenditure =>
      basalMetabolicRate * activityLevel.calorieFactor;

  /// What the goal adds to or takes off the total expenditure, in kcal.
  int get goalAdjustment => goal.dailyCalorieAdjustment;

  /// The daily calorie target in kcal, rounded to a whole one.
  int get calorieTarget => (totalEnergyExpenditure + goalAdjustment).round();

  @override
  bool operator ==(Object other) =>
      other is CalorieCalculation &&
      other.weightKg == weightKg &&
      other.heightCm == heightCm &&
      other.ageYears == ageYears &&
      other.sex == sex &&
      other.activityLevel == activityLevel &&
      other.goal == goal;

  @override
  int get hashCode =>
      Object.hash(weightKg, heightCm, ageYears, sex, activityLevel, goal);

  @override
  String toString() =>
      'CalorieCalculation(weightKg: $weightKg, heightCm: $heightCm, '
      'ageYears: $ageYears, sex: $sex, activityLevel: $activityLevel, '
      'goal: $goal)';
}

extension ActivityFactor on ActivityLevel {
  /// What the basal rate is multiplied by to reach the total expenditure.
  ///
  /// The usual ladder from 1.2 to 1.9 that goes with Mifflin-St Jeor.
  double get calorieFactor => switch (this) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.lightlyActive => 1.375,
    ActivityLevel.moderatelyActive => 1.55,
    ActivityLevel.veryActive => 1.725,
    ActivityLevel.extraActive => 1.9,
  };
}

extension GoalAdjustment on WeightGoal {
  /// The weight change per week this goal aims for, in grams.
  ///
  /// Selectable, where this used to be one fixed rate per direction (#43). The
  /// old argument was that a rate the user can crank up invites a deficit
  /// nobody keeps up — but a rate the user cannot touch invites the mirror
  /// image of that: somebody with 30 kg to lose creeping off 500 g a week and
  /// giving up long before the end, and somebody 2 kg from their target
  /// overshooting it. The pace is the user's to pick; what the app owes them
  /// is a word where the pace gets hard on the body, which is what
  /// `GoalWarning` is for.
  ///
  /// The ladder stops at −1000 and +800 g. Past those the number stops
  /// describing fat: a faster loss comes out of muscle as well, and a faster
  /// gain goes back on as fat rather than as anything the training built.
  /// Losing reaches one step further than gaining because a body can give up
  /// stored energy faster than it can build new tissue.
  int get weeklyWeightChangeGrams => switch (this) {
    WeightGoal.gain200 => 200,
    WeightGoal.gain500 => 500,
    WeightGoal.gain800 => 800,
    WeightGoal.maintain => 0,
    WeightGoal.lose200 => -200,
    WeightGoal.lose500 => -500,
    WeightGoal.lose800 => -800,
    WeightGoal.lose1000 => -1000,
  };

  /// What that rate costs or adds per day, in kcal.
  ///
  /// Converted with the usual convention of about 7000 kcal per kilogram of
  /// body fat: 500 g per week is 3500 kcal over seven days, so 500 kcal a day.
  /// The two numbers come out equal for every rate — 7000 divided by 7 days is
  /// 1000, the same thousand the grams are divided by — which is why the
  /// steepest rate on offer is exactly the 1000 kcal a day the warning names.
  int get dailyCalorieAdjustment =>
      (weeklyWeightChangeGrams * _kcalPerKilogramOfFat / 1000 / 7).round();
}

/// Energy stored in a kilogram of body fat, the conversion between a weekly
/// rate and a daily calorie adjustment.
const int _kcalPerKilogramOfFat = 7000;
