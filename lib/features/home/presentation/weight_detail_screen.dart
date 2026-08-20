import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../../body_weight/domain/weight_period.dart';
import '../../profile/presentation/profile_formatting.dart';
import 'weight_chart.dart';
import 'weight_entry_editor.dart';
import 'weight_period_picker.dart';

const _logger = AppLogger('body-weight');

/// The whole weight history behind the home card: what the chosen period did
/// to the weight, the chart of it, and every weighing on record as a line that
/// can be corrected or thrown away.
///
/// The **chosen period** frames the figures and the chart, not the series as a
/// whole: the starting weight there is the first weighing inside the window,
/// not the first one ever recorded. The goals screen is where the all-time
/// starting weight lives.
///
/// The list underneath is the exception, and deliberately so: it shows every
/// weighing on record, whatever the period says. The period asks what a
/// stretch of time did to the weight; the list is the record it did it to, and
/// a shorter window is no reason to hide entries from the one place they can
/// be corrected or deleted.
class WeightDetailScreen extends ConsumerStatefulWidget {
  const WeightDetailScreen({super.key, required this.initialPeriod});

  /// The period the home card was showing, so the screen opens on the same
  /// window rather than resetting to a default the user just moved away from.
  final WeightPeriod initialPeriod;

  @override
  ConsumerState<WeightDetailScreen> createState() => _WeightDetailScreenState();
}

class _WeightDetailScreenState extends ConsumerState<WeightDetailScreen> {
  late WeightPeriod _period = widget.initialPeriod;

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(latestBodyWeightProvider);
    final series = ref.watch(bodyWeightSeriesProvider(_period));
    // The list below the chart is deliberately not the period's: the period
    // frames the figures and the chart — the question "what did the last three
    // months do" — while the list is the record itself, and a weighing does
    // not stop existing because the window above it got shorter. Reached
    // through the same provider on [WeightPeriod.allTime], which runs from the
    // earliest entry on record to today.
    final everything = ref.watch(
      bodyWeightSeriesProvider(WeightPeriod.allTime),
    );
    // A failed read is told apart from an empty series, the same way the card
    // does it: stepping on the scale fixes the one and not the other, and a
    // weighing entered here would land where nobody can see it.
    final unreadable =
        latest.hasError || series.hasError || everything.hasError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Körpergewicht'),
        actions: [
          IconButton(
            onPressed: unreadable ? null : _enterWeight,
            icon: const Icon(Icons.add),
            tooltip: 'Gewicht eintragen',
          ),
        ],
      ),
      body: _body(latest, series, everything, unreadable: unreadable),
    );
  }

  Widget _body(
    AsyncValue<BodyWeightEntry?> latest,
    AsyncValue<BodyWeightSeries> series,
    AsyncValue<BodyWeightSeries> everything, {
    required bool unreadable,
  }) {
    if (unreadable) {
      return const _Padded(
        _Message('Der Gewichtsverlauf konnte nicht geladen werden.'),
      );
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!latest.hasValue) return const SizedBox.shrink();

    if (latest.value == null) {
      return const _Padded(
        _Message(
          'Noch keine Wiegung. Der Verlauf beginnt mit dem ersten Wert.',
        ),
      );
    }

    final entries = series.value?.entries ?? const <BodyWeightEntry>[];
    // Newest first, against the oldest-first order the repository reads in:
    // the list is read from the top, and the top is where today belongs.
    final newestFirst = (everything.value?.entries ?? const <BodyWeightEntry>[])
        .reversed
        .toList();

    // One scroll view for the whole screen, so the head scrolls away with the
    // list instead of the list scrolling inside it — every weighing on record
    // is far too long to sit in a box of its own. Built lazily for the same
    // reason.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _head(series.value, entries)),
        if (newestFirst.isNotEmpty)
          // Named, because the list no longer answers to the picker above it:
          // without the label, a period showing three weighings over a list of
          // three hundred looks like a bug rather than a decision.
          const SliverToBoxAdapter(child: _SectionLabel('Alle Wiegungen')),
        SliverList.builder(
          itemCount: newestFirst.length,
          itemBuilder: (context, index) => _EntryRow(
            entry: newestFirst[index],
            onEdit: () => _correctWeight(newestFirst[index]),
            onDelete: () => _deleteWeight(newestFirst[index]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  /// The figures and the chart, set on a card of their own.
  ///
  /// The card is what draws the line between the two halves of the screen: the
  /// period, the figures and the chart belong together and change together,
  /// while the weighings underneath sit on the plain background and do not
  /// answer to the picker at all. It is also what scopes the picker — inside
  /// the card, beside the heading, it plainly changes the card rather than the
  /// screen.
  Widget _head(BodyWeightSeries? series, List<BodyWeightEntry> entries) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Verlauf', style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(width: 8),
                  // Half the row, with the picker set against its right edge.
                  // Bounded rather than left to its own width on purpose: a
                  // control laid out with no width limit cannot give way, and
                  // at the largest system text sizes the label would run past
                  // the card instead of wrapping inside the button.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: WeightPeriodPicker(
                        period: _period,
                        expand: false,
                        onChanged: (period) => setState(() => _period = period),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (entries.isNotEmpty) ...[
                PeriodSummary(entries: entries),
                const SizedBox(height: 16),
              ],
              _plot(series, entries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plot(BodyWeightSeries? series, List<BodyWeightEntry> entries) {
    // Holds the height the chart is about to take, so switching periods does
    // not make the screen jump while the new window is read.
    if (series == null) return const SizedBox(height: WeightChart.height);

    if (entries.isEmpty) {
      return const SizedBox(
        height: WeightChart.height,
        child: Center(child: _Message('Im gewählten Zeitraum keine Wiegung.')),
      );
    }

    return WeightChart(entries: entries, from: series.from, to: series.to);
  }

  /// Adds a weighing, on a day of the user's choosing.
  ///
  /// The field starts empty — see the card, which enters one the same way.
  Future<void> _enterWeight() async {
    final result = await showWeightEditor(context);
    // The screen may be gone by the time the sheet is: `ref` does not outlive
    // it, and reading through it after that throws rather than dropping the
    // write.
    if (result == null || !mounted) return;

    await _save(BodyWeightEntry(date: result.date, weightKg: result.weightKg));
  }

  /// Corrects the weighing of [entry]'s day, which stays that day: the editor
  /// is opened on it and does not offer another.
  Future<void> _correctWeight(BodyWeightEntry entry) async {
    final result = await showWeightEditor(
      context,
      initialWeightKg: entry.weightKg,
      fixedDate: entry.date,
    );
    if (result == null || !mounted) return;

    await _save(BodyWeightEntry(date: entry.date, weightKg: result.weightKg));
  }

  Future<void> _save(BodyWeightEntry entry) async {
    try {
      await ref.read(bodyWeightRepositoryProvider).save(entry);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the screen would look exactly
      // as it does after a successful one, only without the new value in it.
      _logger.error('Saving the weight entry failed', error, stackTrace);
      _report('Das Gewicht konnte nicht gespeichert werden.');
    }
    // No refresh here: the screen watches the series, and the repository
    // re-emits it as soon as the write lands.
  }

  /// Removes the weighing of [entry]'s day, answering whether it worked.
  ///
  /// The answer is what the swipe waits on: a delete that failed leaves the
  /// row where it is instead of animating away from an entry that is still
  /// there.
  Future<bool> _deleteWeight(BodyWeightEntry entry) async {
    try {
      await ref.read(bodyWeightRepositoryProvider).delete(entry.date);
      return true;
    } catch (error, stackTrace) {
      _logger.error('Deleting the weight entry failed', error, stackTrace);
      _report('Die Wiegung konnte nicht gelöscht werden.');
      return false;
    }
  }

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The three numbers over the chart: where the period started, where it stands
/// now, and what lies between them.
///
/// Everything is measured inside the window — [entries] are the weighings of
/// the chosen period, oldest first, and never empty.
class PeriodSummary extends StatelessWidget {
  const PeriodSummary({super.key, required this.entries});

  final List<BodyWeightEntry> entries;

  /// Below the rounding of a single decimal there is no movement to report.
  static const double _stillness = 0.05;

  @override
  Widget build(BuildContext context) {
    final start = entries.first.weightKg;
    final current = entries.last.weightKg;
    final change = current - start;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Figure(label: 'Start', value: _kilograms(start)),
        ),
        Expanded(
          child: _Figure(label: 'Aktuell', value: _kilograms(current)),
        ),
        Expanded(
          child: _Figure(
            label: 'Unterschied',
            value: _changeLabel(change),
            detail: _percentLabel(change, start),
            icon: _trendIcon(change),
            color: _trendColor(context, change),
          ),
        ),
      ],
    );
  }

  String _kilograms(double weightKg) => '${formatDecimal(weightKg, 1)} kg';

  /// The change with its sign, using the typographic minus the goal labels
  /// use rather than the hyphen on the keyboard.
  String _changeLabel(double change) {
    if (change.abs() < _stillness) return '±0 kg';
    return '${change > 0 ? '+' : '−'}${formatDecimal(change.abs(), 1)} kg';
  }

  /// The change against the weight it started from.
  ///
  /// A starting weight of zero cannot get past the editor, but dividing by it
  /// would print an infinity rather than fail, so the guard stays: the figure
  /// falls back to no movement, which is what an unusable ratio amounts to.
  String _percentLabel(double change, double start) {
    if (change.abs() < _stillness || start <= 0) return '±0 %';
    final percent = change / start * 100;
    return '${change > 0 ? '+' : '−'}${formatDecimal(percent.abs(), 1)} %';
  }

  IconData _trendIcon(double change) {
    if (change.abs() < _stillness) return Icons.trending_flat;
    return change > 0 ? Icons.trending_up : Icons.trending_down;
  }

  /// Green for up and red for down — the **direction**, not a verdict. Whether
  /// gaining is good depends on the goal in the profile, and this screen does
  /// not read it.
  ///
  /// Neither colour is the only thing saying which way it went: the icon
  /// points and the number carries its sign, so the same reading survives a
  /// screenshot in greyscale or an eye that does not separate the two.
  Color _trendColor(BuildContext context, double change) {
    final scheme = Theme.of(context).colorScheme;
    if (change.abs() < _stillness) return scheme.onSurfaceVariant;

    // Not from the colour scheme: a seed of light blue gives no green, and
    // `error` is red for a fault rather than for a direction. Two pairs
    // instead, one per brightness, because a green that reads on near-black
    // washes out on white.
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (change > 0) {
      return dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    }
    return dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
  }
}

/// One of the three figures over the chart.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.color,
  });

  final String label;
  final String value;

  /// The second line under the value — the relative change, where there is
  /// one.
  final String? detail;

  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: muted),
        const SizedBox(height: 2),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        if (detail != null) Text(detail!, style: muted?.copyWith(color: color)),
      ],
    );
  }
}

/// One weighing in the list: the weight, the day it was taken, and the two
/// ways to change it — a tap to correct the number, a swipe to throw it away.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final BodyWeightEntry entry;
  final VoidCallback onEdit;

  /// Deletes the entry and answers whether it worked — see
  /// `_WeightDetailScreenState._deleteWeight`.
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      // The day is the identity of an entry, so it is what tells one row from
      // another across a rebuild.
      key: ValueKey(entry.date),
      background: _DismissBackground(alignment: Alignment.centerLeft),
      secondaryBackground: _DismissBackground(alignment: Alignment.centerRight),
      // The delete itself runs here rather than in `onDismissed`: the row may
      // only leave once the entry is actually gone, or a failed write would
      // animate away a weighing that is still on record.
      confirmDismiss: (_) => onDelete(),
      child: ListTile(
        title: Text(
          '${formatDecimal(entry.weightKg, 1)} kg',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          MaterialLocalizations.of(context).formatFullDate(entry.date),
        ),
        onTap: onEdit,
      ),
    );
  }
}

/// What shows under a row on its way out.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.errorContainer,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}

/// The heading over the entry list — the counterpart to the "Verlauf" heading
/// on the card above, at the same level so the screen reads as two blocks.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }
}

/// A line that reports rather than shows — set apart the way a subtitle is.
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

/// The screen's margin, for what stands on its own instead of in the list.
class _Padded extends StatelessWidget {
  const _Padded(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), child: child);
}
