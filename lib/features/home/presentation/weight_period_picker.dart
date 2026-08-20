import 'package:flutter/material.dart';

import '../../body_weight/domain/weight_period.dart';
import '../../profile/presentation/value_editor.dart';

/// The period a weight screen starts on, before the user picks another.
///
/// Three months: long enough that a week of water weight does not look like a
/// trend, short enough that a few weeks of tracking already fill it.
const defaultWeightPeriod = WeightPeriod.threeMonths;

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
    this.expand = true,
  });

  final WeightPeriod period;
  final ValueChanged<WeightPeriod> onChanged;

  /// Whether the control fills the width it is offered.
  ///
  /// The home card leaves it on: there the picker spans the card, and the card
  /// is exactly what it changes. The detail screen turns it off and sets it
  /// beside the heading of the block it belongs to — a control spanning the
  /// top of a screen reads as though it filtered the whole screen, and this
  /// one only frames the figures and the chart.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final button = OutlinedButton(
      onPressed: () => _pick(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Tight fills the button, loose lets it shrink to the label — the
          // label still gives way rather than overflowing when a large system
          // text size makes it wider than the room beside the heading.
          Flexible(
            fit: expand ? FlexFit.tight : FlexFit.loose,
            child: Text(period.label),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
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

/// The period [name] stands for, falling back to [defaultWeightPeriod].
///
/// Lenient on purpose: the name travels in the URL, where a hand-typed or
/// outdated one has to land on a screen rather than on an exception.
WeightPeriod weightPeriodByName(String? name) => WeightPeriod.values.firstWhere(
  (period) => period.name == name,
  orElse: () => defaultWeightPeriod,
);
