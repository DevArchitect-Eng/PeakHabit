import 'package:flutter/material.dart';

import '../../profile/domain/macro_distribution.dart';
import '../domain/nutrients.dart';
import 'nutrition_formatting.dart';

/// What a summary measures itself against: the daily energy target and the
/// three gram targets that follow from it.
///
/// The two travel together because they are set together — `UserProfile`
/// derives the gram targets from the calorie target, so one without the other
/// cannot happen.
typedef NutritionTargets = ({int kcal, MacroTargets macros});

/// What a day or a meal adds up to: the energy, and the three macronutrients
/// under it.
///
/// With [targets] given, every figure is shown against its target and says how
/// much of it is still open — that is the day's card. Without them it is the
/// bare sums, which is what a **meal** gets: splitting the daily target across
/// the four meals would mean inventing a share for each of them that nothing
/// in the app decides. See the design section of #9.
class NutritionSummary extends StatelessWidget {
  const NutritionSummary({
    super.key,
    required this.label,
    required this.nutrients,
    this.targets,
  });

  final String label;
  final Nutrients nutrients;

  /// What this summary is measured against, or `null` where nothing is — a
  /// meal, or a profile that has no calorie target yet.
  final NutritionTargets? targets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targets = this.targets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        if (targets == null)
          Text(formatKcal(nutrients.kcal), style: theme.textTheme.headlineSmall)
        else ...[
          // The eaten figure keeps the headline size and the target rides
          // along smaller: the question is how much has been eaten, and the
          // target is what makes that number mean something.
          _NoWrap(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${nutrients.kcal.round()}',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${targets.kcal} kcal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Bar(value: nutrients.kcal, target: targets.kcal.toDouble()),
          const SizedBox(height: 4),
          _Remaining(remaining: targets.kcal - nutrients.kcal, unit: 'kcal'),
        ],
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Macro(
                label: 'Protein',
                grams: nutrients.proteinGrams,
                target: targets?.macros.proteinGrams,
              ),
            ),
            Expanded(
              child: _Macro(
                label: 'Kohlenhydrate',
                grams: nutrients.carbGrams,
                target: targets?.macros.carbGrams,
              ),
            ),
            Expanded(
              child: _Macro(
                label: 'Fett',
                grams: nutrients.fatGrams,
                target: targets?.macros.fatGrams,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One of the three macronutrients under the energy, against its gram target
/// where there is one.
class _Macro extends StatelessWidget {
  const _Macro({
    required this.label,
    required this.grams,
    required this.target,
  });

  final String label;
  final double grams;

  /// The gram target, `null` where the summary has none to measure against.
  final double? target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = this.target;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          _NoWrap(
            child: Text(
              target == null
                  ? formatGrams(grams)
                  : '${grams.round()} / ${formatGrams(target)}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 6),
            _Bar(value: grams, target: target),
            const SizedBox(height: 4),
            _Remaining(remaining: target - grams, unit: 'g', compact: true),
          ],
        ],
      ),
    );
  }
}

/// How far a figure has come towards its target.
///
/// Fills completely once the target is passed and switches colour there, so
/// the overrun is visible without reading the numbers — but the bar alone is
/// never the only sign of it: [_Remaining] spells it out in words next to it.
class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.target});

  final double value;
  final double target;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A target of zero cannot come out of the profile — a calorie target is
    // positive and the shares add up to it — but dividing by it would paint a
    // NaN rather than fail, so the guard stays.
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        // Always a value, never null: an indeterminate indicator animates
        // forever, and `pumpAndSettle` would never settle against it.
        value: progress,
        minHeight: 6,
        backgroundColor: scheme.surfaceContainerHighest,
        // Not `error`: going past a protein target is not a fault, and the
        // same bar serves all four figures. `tertiary` is simply the other
        // accent the scheme brings.
        color: value > target ? scheme.tertiary : scheme.primary,
      ),
    );
  }
}

/// What is still open, or by how much the target was passed.
class _Remaining extends StatelessWidget {
  const _Remaining({
    required this.remaining,
    required this.unit,
    this.compact = false,
  });

  final double remaining;

  /// `kcal` or `g` — printed after the number.
  final String unit;

  /// The narrow form under a macro column, where the line has a third of the
  /// card to fit into.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Below half a unit there is nothing left worth reporting, and "0 kcal
    // übrig" next to a full bar reads as if something were still open.
    final over = remaining < -0.5;
    final amount = remaining.abs().round();

    return _NoWrap(
      child: Text(
        over
            ? '$amount $unit zu viel'
            : '${compact ? 'noch ' : ''}$amount $unit${compact ? '' : ' übrig'}',
        style:
            (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
                ?.copyWith(
                  color: over ? scheme.tertiary : scheme.onSurfaceVariant,
                ),
      ),
    );
  }
}

/// A line that never breaks: too long for its column, it shrinks rather than
/// wraps.
///
/// The three macro columns only read as one row while value, bar and remainder
/// sit at the same height in each of them. A day big enough to break
/// "3009 / 326 g" over two lines pushes that column's bar and remainder below
/// its neighbours' — so the text gives way instead of the layout. Ellipsis
/// would not do here: cutting a figure short is worse than printing it small.
class _NoWrap extends StatelessWidget {
  const _NoWrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
