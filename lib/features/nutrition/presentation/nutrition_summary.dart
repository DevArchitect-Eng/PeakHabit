import 'package:flutter/material.dart';

import '../domain/nutrients.dart';
import 'nutrition_formatting.dart';

/// What a day or a meal adds up to: the energy, and the three macronutrients
/// under it.
///
/// **No target next to the figures**, deliberately. The nutrition tab shows
/// what has been eaten, not what is left of a quota: splitting the daily
/// target across the four meals would mean inventing a share for each of them
/// that nothing in the app decides — see the design section of #9. The daily
/// target itself is a screen of its own.
class NutritionSummary extends StatelessWidget {
  const NutritionSummary({
    super.key,
    required this.label,
    required this.nutrients,
  });

  final String label;
  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        Text(formatKcal(nutrients.kcal), style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Macro(label: 'Protein', grams: nutrients.proteinGrams),
            ),
            Expanded(
              child: _Macro(label: 'Kohlenhydrate', grams: nutrients.carbGrams),
            ),
            Expanded(
              child: _Macro(label: 'Fett', grams: nutrients.fatGrams),
            ),
          ],
        ),
      ],
    );
  }
}

/// One of the three macronutrients under the energy.
class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.grams});

  final String label;
  final double grams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(formatGrams(grams), style: theme.textTheme.titleMedium),
      ],
    );
  }
}
