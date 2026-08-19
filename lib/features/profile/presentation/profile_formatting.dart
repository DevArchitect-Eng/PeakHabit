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

/// A date with a two-digit year: `18.08.26`.
///
/// For a place where the date rides along with something else — the weighing
/// a starting weight comes from — and the long form would push the line into
/// a second one.
String formatShortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${(date.year % 100).toString().padLeft(2, '0')}';

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
  /// The explaining form, for a picker with room for it.
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sitzend, kaum Bewegung',
    ActivityLevel.lightlyActive => 'Leicht aktiv, 1–2× Sport pro Woche',
    ActivityLevel.moderatelyActive => 'Mäßig aktiv, 3–4× Sport pro Woche',
    ActivityLevel.veryActive => 'Sehr aktiv, 5–6× Sport pro Woche',
    ActivityLevel.extraActive => 'Extrem aktiv, täglich hart oder körperlich',
  };

  /// The form a settings row shows, where the explaining one would push the
  /// label of the row into a broken word.
  String get shortLabel => switch (this) {
    ActivityLevel.sedentary => 'Sitzend',
    ActivityLevel.lightlyActive => 'Leicht aktiv',
    ActivityLevel.moderatelyActive => 'Mäßig aktiv',
    ActivityLevel.veryActive => 'Sehr aktiv',
    ActivityLevel.extraActive => 'Extrem aktiv',
  };
}

extension WeightGoalLabel on WeightGoal {
  String get label => switch (this) {
    WeightGoal.lose => 'Abnehmen',
    WeightGoal.maintain => 'Gewicht halten',
    WeightGoal.gain => 'Zunehmen',
  };
}
