import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../../body_weight/domain/weight_period.dart';
import '../../profile/presentation/profile_formatting.dart';
import 'weight_chart.dart';
import 'weight_entry_editor.dart';

const _logger = AppLogger('body-weight');

/// The weight widget of the home screen: where the weight stands, how it got
/// there, and the way to add today's.
///
/// This is the one place weighing happens — the goals screen only reports the
/// two numbers it needs, so there is a single place where entering one can go
/// wrong.
class BodyWeightCard extends ConsumerStatefulWidget {
  const BodyWeightCard({super.key});

  @override
  ConsumerState<BodyWeightCard> createState() => _BodyWeightCardState();
}

class _BodyWeightCardState extends ConsumerState<BodyWeightCard> {
  /// Three months to start with: long enough that a week of water weight does
  /// not look like a trend, short enough that a few weeks of tracking already
  /// fill it.
  WeightPeriod _period = WeightPeriod.threeMonths;

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(latestBodyWeightProvider);
    final series = ref.watch(bodyWeightSeriesProvider(_period));
    // A failed read is told apart from an empty series: stepping on the scale
    // fixes the one and not the other. It also takes the way in with it — a
    // weighing entered here would land where nobody can see it.
    final unreadable = latest.hasError || series.hasError;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onAdd: unreadable ? null : _enterWeight),
            _body(latest, series, unreadable: unreadable),
          ],
        ),
      ),
    );
  }

  Widget _body(
    AsyncValue<BodyWeightEntry?> latest,
    AsyncValue<BodyWeightSeries> series, {
    required bool unreadable,
  }) {
    if (unreadable) {
      return const _Message('Der Gewichtsverlauf konnte nicht geladen werden.');
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!latest.hasValue) return const SizedBox.shrink();

    final current = latest.value;
    if (current == null) return _EmptyState(onAdd: _enterWeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CurrentWeight(entry: current, series: series.value),
        const SizedBox(height: 16),
        _PeriodPicker(
          period: _period,
          onChanged: (period) => setState(() => _period = period),
        ),
        const SizedBox(height: 16),
        _plot(series),
      ],
    );
  }

  Widget _plot(AsyncValue<BodyWeightSeries> series) {
    final value = series.value;
    // Holds the height the chart is about to take, so switching periods does
    // not make the card jump while the new window is read.
    if (value == null) return const SizedBox(height: WeightChart.height);

    if (value.entries.isEmpty) {
      return const SizedBox(
        height: WeightChart.height,
        child: Center(child: _Message('Im gewählten Zeitraum keine Wiegung.')),
      );
    }

    return WeightChart(entries: value.entries, from: value.from, to: value.to);
  }

  Future<void> _enterWeight() async {
    final weightKg = await showWeightEditor(
      context,
      initialWeightKg: ref.read(latestBodyWeightProvider).value?.weightKg,
    );
    if (weightKg == null || !mounted) return;

    try {
      // Today's entry, replacing an earlier one from the same day: weighing
      // again corrects the day rather than adding a second value to it.
      await ref
          .read(bodyWeightRepositoryProvider)
          .save(BodyWeightEntry(date: DateTime.now(), weightKg: weightKg));
    } catch (error, stackTrace) {
      // Without this the write fails silently: the card would look exactly as
      // it does after a successful one, only without the new value in it.
      _logger.error('Saving the weight entry failed', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das Gewicht konnte nicht gespeichert werden.'),
        ),
      );
    }
    // No refresh here: the card watches the series, and the repository re-emits
    // it as soon as the write lands.
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  /// `null` where there is nothing to add to — a series that cannot be read
  /// would take the entry and hide it.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Körpergewicht',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          tooltip: 'Gewicht eintragen',
        ),
      ],
    );
  }
}

/// The latest weighing, and what has changed since the one before it in the
/// window.
class _CurrentWeight extends StatelessWidget {
  const _CurrentWeight({required this.entry, required this.series});

  final BodyWeightEntry entry;
  final BodyWeightSeries? series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatDecimal(entry.weightKg, 1)} kg',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 2),
        Text(
          _subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// What the weight has done, or the day it was taken where a single weighing
  /// leaves nothing to compare it against.
  ///
  /// The change is dated from the weighing it is measured against rather than
  /// named after the period: the window may be three months long while the
  /// entries in it cover a week, and "in den letzten 3 Monaten" would then
  /// claim three months of progress from seven days of it — which is exactly
  /// where every new user starts.
  String get _subtitle {
    final entries = series?.entries ?? const <BodyWeightEntry>[];
    if (entries.length < 2) return 'am ${formatShortDate(entry.date)}';

    final first = entries.first;
    final change = entries.last.weightKg - first.weightKg;
    return '${_changeLabel(change)} seit ${formatShortDate(first.date)}';
  }

  /// The change with its sign, using the typographic minus the goal labels
  /// use rather than the hyphen on the keyboard.
  String _changeLabel(double change) {
    // Below the rounding of a single decimal there is no movement to report,
    // and "−0 kg" would be a strange way to say so.
    if (change.abs() < 0.05) return '±0 kg';
    return '${change > 0 ? '+' : '−'}${formatDecimal(change.abs(), 1)} kg';
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.period, required this.onChanged});

  final WeightPeriod period;
  final ValueChanged<WeightPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<WeightPeriod>(
        segments: [
          for (final option in WeightPeriod.values)
            ButtonSegment(value: option, label: Text(option.label)),
        ],
        selected: {period},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

/// What stands in for the chart before the first weighing.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Message(
          'Noch keine Wiegung. Der Verlauf beginnt mit dem ersten Wert.',
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onAdd, child: const Text('Gewicht eintragen')),
      ],
    );
  }
}

/// A line of the card that reports rather than shows — set apart from the
/// weight above it the way a subtitle is.
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

extension WeightPeriodLabel on WeightPeriod {
  /// The form the picker shows, short enough for three of them on one line.
  String get label => switch (this) {
    WeightPeriod.month => '1 Monat',
    WeightPeriod.threeMonths => '3 Monate',
    WeightPeriod.year => '1 Jahr',
  };
}
