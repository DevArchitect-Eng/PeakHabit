import 'package:flutter/material.dart';

import '../../body_weight/domain/weight_period.dart';
import '../../profile/presentation/value_editor.dart';

/// The control that picks how far back a look at the weight series reaches.
///
/// Shared by the home card and the weight detail screen: both offer the same
/// set of periods, and a second copy of the control is one that gets a new
/// option in one place and not the other.
class WeightPeriodPicker extends StatelessWidget {
  const WeightPeriodPicker({
    super.key,
    required this.period,
    required this.onChanged,
  });

  final WeightPeriod period;
  final ValueChanged<WeightPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _pick(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(period.label)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Opens the choice sheet the settings rows use, rather than a dropdown
  /// menu: it is the shape every other picking in the app already has, and
  /// seven options read better as a list that is confirmed than as a menu
  /// that commits on the way past.
  Future<void> _pick(BuildContext context) async {
    final chosen = await showChoiceEditor<WeightPeriod>(
      context,
      title: 'Zeitraum',
      value: period,
      options: WeightPeriod.values,
      labelOf: (option) => option.label,
    );
    // Nothing stands in for "no period", so an empty choice only comes back
    // from a dropped sheet.
    final next = chosen?.value;
    if (next == null) return;

    onChanged(next);
  }
}

extension WeightPeriodLabel on WeightPeriod {
  /// The form the picker shows.
  String get label => switch (this) {
    WeightPeriod.allTime => 'Seit Beginn',
    WeightPeriod.year => '1 Jahr',
    WeightPeriod.sixMonths => '1/2 Jahr',
    WeightPeriod.threeMonths => '3 Monate',
    WeightPeriod.twoMonths => '2 Monate',
    WeightPeriod.month => '1 Monat',
    WeightPeriod.week => '1 Woche',
  };
}
