import 'package:flutter/material.dart';

import '../domain/calorie_calculation.dart';
import '../domain/user_profile.dart';

/// The warnings a chosen rate — or the calorie target it works out to — is
/// worth a word about, and the dialog that carries them.
///
/// In one place because the goal is picked in two: the goals screen and the
/// onboarding. A warning that only shows up in one of them is one the user
/// walks past on the very day they set their rate.
///
/// None of these block anything. The pace is the user's decision (see
/// `GoalAdjustment.weeklyWeightChangeGrams`); what the app owes them is the
/// chance to make it knowingly.
enum GoalWarning {
  /// The fastest gain on offer, +0,8 kg a week.
  surplusTooHigh,

  /// The two fastest losses on offer, −0,8 and −1 kg a week.
  deficitTooHigh,

  /// A calculated target below what the body burns lying still.
  belowBasalRate;

  /// What the dialog says for it.
  String get message => switch (this) {
    GoalWarning.surplusTooHigh =>
      '0,8 kg pro Woche ist über längere Zeit eine sehr hohe Zunahmerate. '
          'Mehr als etwa ein halbes Kilo pro Woche kommt kaum noch als '
          'Muskulatur dazu, sondern überwiegend als Fett.',
    GoalWarning.deficitTooHigh =>
      'Ein so hohes Defizit ist über längere Zeit ungesund: Der Körper holt '
          'sich einen wachsenden Teil davon aus der Muskulatur, und eine '
          'entsprechend kleine Portion deckt den Bedarf an Nährstoffen kaum '
          'noch.',
    GoalWarning.belowBasalRate =>
      'Das berechnete Kalorienziel liegt unter deinem Grundumsatz — unter '
          'dem also, was dein Körper allein in Ruhe verbraucht. Dauerhaft ist '
          'das ungesund.',
  };
}

/// What [goal] earns on its own, plus what the [calculation] it leads to earns
/// on top of that.
///
/// Both are optional and independent. [goal] is left out where the rate was
/// not the thing just picked — it warns when it is chosen, not again on every
/// unrelated save. [calculation] is left out where there is none to make,
/// which is the normal state of a profile that has not filled in enough for
/// one.
///
/// A target at or below zero counts as no target rather than as one below the
/// basal rate: nothing stores such a number, so there is nothing to warn
/// about.
List<GoalWarning> goalWarnings({
  WeightGoal? goal,
  CalorieCalculation? calculation,
}) => [
  if (goal == WeightGoal.gain800) GoalWarning.surplusTooHigh,
  if (goal == WeightGoal.lose800 || goal == WeightGoal.lose1000)
    GoalWarning.deficitTooHigh,
  if (calculation != null &&
      calculation.calorieTarget > 0 &&
      calculation.calorieTarget < calculation.basalMetabolicRate)
    GoalWarning.belowBasalRate,
];

/// Shows [warnings] as one dialog, or returns right away when there are none.
///
/// One dialog for however many apply rather than one each: a single rate can
/// earn two of them, and a second dialog opening the moment the first is
/// dismissed reads as a bug rather than as a second point.
Future<void> showGoalWarnings(
  BuildContext context,
  List<GoalWarning> warnings,
) async {
  if (warnings.isEmpty) return;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.warning_amber_outlined),
      title: const Text('Hinweis'),
      // Scrollable because two of these paragraphs at a large system text
      // size reach past a small phone, and a dialog that overflows cuts off
      // the very sentence it exists for.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, warning) in warnings.indexed) ...[
              if (index > 0) const SizedBox(height: 16),
              Text(warning.message),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Verstanden'),
        ),
      ],
    ),
  );
}
