import '../domain/user_profile.dart';

/// The German labels and number formats the profile screens share.
///
/// Kept in one place because the profile, the goals and the nutrition targets
/// all name the same enums and print the same kinds of numbers — a second copy
/// of a label is one that gets changed in one screen and forgotten in the
/// other.

/// A date the way it is written in German: `18.08.2026`.
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${date.year}';

/// A decimal number with a comma, the way it is written in German.
///
/// Trailing zeros of a shorter number are dropped: 1,375 but 1,2 rather than
/// 1,200.
String formatDecimal(double value, int maxDecimals) {
  final text = value.toStringAsFixed(maxDecimals);
  // Only zeros behind the point go — the same pattern on a number without one
  // would eat the zeros of 100.
  final trimmed = text.contains('.')
      ? text.replaceFirst(RegExp(r'\.?0+$'), '')
      : text;
  return trimmed.replaceFirst('.', ',');
}

extension BiologicalSexLabel on BiologicalSex {
  String get label => switch (this) {
    BiologicalSex.female => 'weiblich',
    BiologicalSex.male => 'männlich',
  };
}

extension ActivityLevelLabel on ActivityLevel {
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sitzend, kaum Bewegung',
    ActivityLevel.lightlyActive => 'Leicht aktiv, 1–2× Sport pro Woche',
    ActivityLevel.moderatelyActive => 'Mäßig aktiv, 3–4× Sport pro Woche',
    ActivityLevel.veryActive => 'Sehr aktiv, 5–6× Sport pro Woche',
    ActivityLevel.extraActive => 'Extrem aktiv, täglich hart oder körperlich',
  };
}

extension WeightGoalLabel on WeightGoal {
  String get label => switch (this) {
    WeightGoal.lose => 'Abnehmen',
    WeightGoal.maintain => 'Gewicht halten',
    WeightGoal.gain => 'Zunehmen',
  };
}
