import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../data/user_profile_providers.dart';
import '../domain/calorie_calculation.dart';
import '../domain/user_profile.dart';
import 'goal_warning.dart';
import 'profile_formatting.dart';
import 'setting_row.dart';
import 'value_editor.dart';

const _logger = AppLogger('profile');

/// What the user is working towards: the weight goal and the activity level it
/// is calculated with.
///
/// Reached from the settings tab, one level above the nutrition targets. Split
/// off the profile screen because the profile answers "who is this" while this
/// one answers "where is this going" — and the starting and current weight
/// only mean something next to a goal.
///
/// Both weights only report: weighing happens on the home screen, and a second
/// place to enter it would be a second place to get it wrong.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ziele')),
      body: switch (profile) {
        AsyncData(:final value) => _GoalsList(profile: value),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Die Ziele konnten nicht geladen werden.'),
          ),
        ),
        // Reading one row from a local database takes about a frame, so a
        // spinner would only flicker. It would also never stop spinning for
        // `pumpAndSettle`, which is what a widget test waits on.
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _GoalsList extends ConsumerWidget {
  const _GoalsList({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = ref.watch(firstBodyWeightProvider);
    final latest = ref.watch(latestBodyWeightProvider);

    return ListView(
      children: [
        SettingRow(
          label: 'Startgewicht',
          value: _weightValue(first, withDate: true),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Aktuelles Gewicht',
          value: _weightValue(latest, withDate: false),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Ziel',
          value: profile.goal.shortLabel,
          onTap: () => _editGoal(context, ref),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Aktivitätslevel',
          value: profile.activityLevel?.shortLabel ?? 'Keine Angabe',
          onTap: () => _editActivityLevel(context, ref),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),
        const _NutritionTargetsTile(),
      ],
    );
  }

  /// The weighing behind a row, or what stands in for it.
  ///
  /// A failed read is told apart from an empty series: the user cannot fix the
  /// former by stepping on the scale.
  String _weightValue(
    AsyncValue<BodyWeightEntry?> weighing, {
    required bool withDate,
  }) {
    if (weighing.hasError) return 'Nicht lesbar';

    final entry = weighing.value;
    if (entry == null) return 'Kein Eintrag';

    final weight = '${formatDecimal(entry.weightKg, 1)} kg';
    return withDate ? '$weight am ${formatShortDate(entry.date)}' : weight;
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref) async {
    final chosen = await showChoiceEditor<WeightGoal>(
      context,
      title: 'Ziel',
      value: profile.goal,
      options: WeightGoal.values,
      labelOf: (goal) => goal.label,
    );
    // The goal always has a value, so an empty choice cannot come back.
    final goal = chosen?.value;
    // Confirming what was already set writes nothing: the save recalculates
    // the calorie target, and a target the user typed themselves must not go
    // just because they opened the picker to look at it.
    if (goal == null || goal == profile.goal || !context.mounted) return;

    final calculation = await _save(context, ref, profile.copyWith(goal: goal));
    if (!context.mounted) return;

    await showGoalWarnings(
      context,
      goalWarnings(goal: goal, calculation: calculation),
    );
  }

  Future<void> _editActivityLevel(BuildContext context, WidgetRef ref) async {
    final chosen = await showChoiceEditor<ActivityLevel>(
      context,
      title: 'Aktivitätslevel',
      value: profile.activityLevel,
      options: ActivityLevel.values,
      labelOf: (level) => level.label,
      noneLabel: 'Keine Angabe',
    );
    if (chosen == null ||
        chosen.value == profile.activityLevel ||
        !context.mounted) {
      return;
    }

    final calculation = await _save(
      context,
      ref,
      profile.copyWith(activityLevel: chosen.value),
    );
    if (!context.mounted) return;

    // No `goal:` here: the rate did not change, and a warning about it would
    // return every time something else on this screen is saved. What a lower
    // activity level can do is push the recalculated target under the basal
    // rate, and that is worth saying.
    await showGoalWarnings(context, goalWarnings(calculation: calculation));
  }

  /// Writes [updated], with the calorie target brought along, and hands back
  /// the calculation behind it — `null` where there was none to make, or where
  /// the write failed.
  ///
  /// Both values on this screen go into the calorie calculation, so leaving the
  /// target where it was would leave the user with a number that no longer
  /// matches what they just asked for. This overrules the earlier decision to
  /// never touch a target by itself (#4): back then the profile screen offered
  /// a button to take the calculation over, and that button is gone.
  ///
  /// The calculation goes back to the caller because the warnings are drawn
  /// from it, and recomputing it there would be the same numbers twice.
  Future<CalorieCalculation?> _save(
    BuildContext context,
    WidgetRef ref,
    UserProfile updated,
  ) async {
    final weight = ref.read(latestBodyWeightProvider).value;
    final calculation = CalorieCalculation.forProfile(
      updated,
      weightKg: weight?.weightKg,
      today: DateTime.now(),
    );
    // A target at or below zero is one the profile refuses; body data that is
    // off by enough produces one, and it is no better than the old value.
    final recalculated = calculation != null && calculation.calorieTarget > 0
        ? calculation.calorieTarget
        : null;

    try {
      await ref
          .read(userProfileRepositoryProvider)
          .save(
            recalculated == null
                ? updated
                : updated.copyWith(calorieTarget: recalculated),
          );
    } catch (error, stackTrace) {
      // Without this the write fails silently: the callback drops the error
      // and the screen looks exactly as it does after a success.
      _logger.error('Saving the goals failed', error, stackTrace);
      if (!context.mounted) return null;
      _show(context, 'Die Ziele konnten nicht gespeichert werden.');
      return null;
    }

    if (context.mounted && recalculated != null) {
      // Said out loud: the number the user may have typed themselves has just
      // been replaced.
      _show(context, 'Kalorienziel auf $recalculated kcal angepasst');
    }
    return calculation;
  }

  void _show(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// Way into the nutrition targets, which divide up what the goal above adds
/// up to.
class _NutritionTargetsTile extends StatelessWidget {
  const _NutritionTargetsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restaurant_outlined),
      title: const Text('Ernährungsziele'),
      subtitle: const Text('Kalorienziel und Makroverteilung'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/settings/goals/nutrition'),
    );
  }
}
