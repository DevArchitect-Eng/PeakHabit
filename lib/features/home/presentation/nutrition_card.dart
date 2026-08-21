import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nutrition/data/nutrition_providers.dart';
import '../../nutrition/domain/day_nutrition.dart';
import '../../nutrition/domain/nutrients.dart';
import '../../nutrition/presentation/nutrition_formatting.dart';
import '../../profile/data/user_profile_providers.dart';
import '../../profile/domain/user_profile.dart';

/// The nutrition widget of the home screen: how far today has come against the
/// calorie target, and the three macronutrients under it.
///
/// The same figures the nutrition tab opens on, in the form a home screen wants
/// them. Rings rather than the tab's bars: this is a glance at whether the day
/// is on track, while the tab is where the day is actually worked on — and a
/// ring says "how full" at a size a bar would need the whole card's width for.
///
/// Always today, never the day the nutrition tab happens to be showing. The tab
/// carries a day because it logs one; the home screen answers where today
/// stands, and a card that silently showed last Tuesday would answer a question
/// nobody asked here.
///
/// Not a way into the tab: the nutrition tab is one tap away in the navigation
/// bar, and a card that jumped tabs would leave the home stack from underneath
/// the user.
class NutritionCard extends ConsumerWidget {
  const NutritionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateUtils.dateOnly(DateTime.now());
    final day = ref.watch(dayNutritionProvider(today));
    // The targets come from the profile rather than from anything this card
    // stores — the same source the nutrition tab measures its day against.
    final profile = ref.watch(userProfileProvider).value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ernährung heute',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _body(day, profile),
          ],
        ),
      ),
    );
  }

  Widget _body(AsyncValue<DayNutrition> day, UserProfile? profile) {
    if (day.hasError) {
      return const _Message('Die Tagessumme konnte nicht geladen werden.');
    }
    // Reading from a local database takes about a frame, so there is nothing to
    // show in the meantime — and a spinner would never settle for a widget test
    // waiting on it.
    if (!day.hasValue) return const SizedBox.shrink();

    final total = day.value!.total;
    final calorieTarget = profile?.calorieTarget;
    final macroTargets = profile?.macroTargets;

    // A sum without anything to measure it against is not a mistake to hide —
    // it says where the target is set instead of drawing a ring around a
    // fraction of nothing.
    if (calorieTarget == null || macroTargets == null) {
      return _WithoutTarget(total: total);
    }

    return Column(
      children: [
        _CalorieRing(kcal: total.kcal, target: calorieTarget),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroRing(
                label: 'Protein',
                grams: total.proteinGrams,
                target: macroTargets.proteinGrams,
              ),
            ),
            Expanded(
              child: _MacroRing(
                label: 'Kohlenhydrate',
                grams: total.carbGrams,
                target: macroTargets.carbGrams,
              ),
            ),
            Expanded(
              child: _MacroRing(
                label: 'Fett',
                grams: total.fatGrams,
                target: macroTargets.fatGrams,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The day's energy, drawn as a ring around what has been eaten.
class _CalorieRing extends StatelessWidget {
  const _CalorieRing({required this.kcal, required this.target});

  final double kcal;
  final int target;

  static const _diameter = 132.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: _diameter,
          height: _diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Ring(value: kcal, target: target.toDouble(), strokeWidth: 10),
              // The eaten figure sits in the ring and the target rides along
              // under it: the question is how much has been eaten, and the
              // target is what makes that number mean something.
              _RingLabel(
                inset: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${kcal.round()}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      'von $target kcal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Remaining(remaining: target - kcal, unit: 'kcal'),
      ],
    );
  }
}

/// One of the three macronutrients, against its gram target from the profile.
class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.label,
    required this.grams,
    required this.target,
  });

  final String label;
  final double grams;
  final double target;

  static const _diameter = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: _diameter,
          height: _diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Ring(value: grams, target: target, strokeWidth: 6),
              _RingLabel(
                inset: 10,
                child: Text(
                  formatGrams(grams),
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        _Remaining(remaining: target - grams, unit: 'g'),
      ],
    );
  }
}

/// How far a figure has come towards its target, drawn as a ring.
///
/// Fills completely once the target is passed and switches colour there, so the
/// overrun is visible without reading the numbers — but the ring alone is never
/// the only sign of it: [_Remaining] spells it out in words underneath.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.value,
    required this.target,
    required this.strokeWidth,
  });

  final double value;
  final double target;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A target of zero cannot come out of the profile — a calorie target is
    // positive and the shares add up to it — but dividing by it would paint a
    // NaN rather than fail, so the guard stays.
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return CircularProgressIndicator(
      // Always a value, never null: an indeterminate indicator animates
      // forever, and `pumpAndSettle` would never settle against it.
      value: progress,
      strokeWidth: strokeWidth,
      strokeCap: StrokeCap.round,
      backgroundColor: scheme.surfaceContainerHighest,
      // Not `error`: going past a protein target is not a fault, and the same
      // ring serves all four figures. `tertiary` is simply the other accent the
      // scheme brings — the nutrition tab's bars use it for the same thing.
      color: value > target ? scheme.tertiary : scheme.primary,
    );
  }
}

/// What stands inside a ring, kept off the stroke and shrunk rather than
/// clipped.
///
/// A ring is a fixed box, and what goes in it is not: a five-digit day or a
/// large system text size would paint straight over the stroke. [inset] is the
/// room the stroke and its rounded cap need, and the text gives way inside what
/// is left — scaled down rather than ellipsised, because cutting a figure short
/// is worse than printing it small.
class _RingLabel extends StatelessWidget {
  const _RingLabel({required this.inset, required this.child});

  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(inset),
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }
}

/// What is still open, or by how much the target was passed.
///
/// Named in words next to the colour, never by the colour alone — the same
/// rule the nutrition tab's figures follow.
class _Remaining extends StatelessWidget {
  const _Remaining({required this.remaining, required this.unit});

  final double remaining;

  /// `kcal` or `g` — printed after the number.
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Below half a unit there is nothing left worth reporting, and "0 kcal
    // übrig" next to a full ring reads as if something were still open.
    final over = remaining < -0.5;
    final amount = remaining.abs().round();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        over ? '$amount $unit zu viel' : '$amount $unit übrig',
        style: theme.textTheme.bodySmall?.copyWith(
          color: over
              ? theme.colorScheme.tertiary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// The day's figures on a profile that has no calorie target yet, with the way
/// to set one.
class _WithoutTarget extends StatelessWidget {
  const _WithoutTarget({required this.total});

  final Nutrients total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatKcal(total.kcal), style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          formatMacros(total),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        const _Message(
          'Noch kein Kalorienziel hinterlegt. Unter Optionen › Ziele lässt es '
          'sich setzen.',
        ),
      ],
    );
  }
}

/// A line of the card that reports rather than shows — set apart the way a
/// subtitle is.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
