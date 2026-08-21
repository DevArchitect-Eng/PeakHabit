import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../data/nutrition_providers.dart';
import '../domain/day_nutrition.dart';
import '../domain/food.dart';
import '../domain/meal_entry.dart';
import 'nutrition_formatting.dart';
import 'nutrition_summary.dart';
import 'portion_editor.dart';

const _logger = AppLogger('nutrition');

/// What stands under one meal on one day, and the two ways to change it — a
/// tap to correct the amount, a swipe to throw the entry away.
///
/// Correcting an entry is about the amount, not about what it was: the tap
/// opens the portion editor and does not offer another food. Swapping the food
/// is deleting one entry and adding another, which is what actually happened.
class MealDetailScreen extends ConsumerStatefulWidget {
  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.day,
    this.addOnOpen = false,
  });

  final MealType mealType;

  /// The day being logged, at local midnight.
  final DateTime day;

  /// Whether to go straight on to picking a food — what the "+" of a meal row
  /// in the tab means. The screen underneath is built either way, so dropping
  /// the picker lands on the meal rather than back where the "+" was.
  final bool addOnOpen;

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame: pushing a route from initState would run while
    // this one is still being built.
    if (widget.addOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _addEntry();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(dayNutritionProvider(widget.day));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType.label),
        // The day rides along in the app bar because the screen is reached
        // from a tab that can stand on any date — without it, a meal
        // nachgetragen for last Tuesday looks exactly like today's.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                formatDayLabel(widget.day),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: day.hasError ? null : _addEntry,
            icon: const Icon(Icons.add),
            tooltip: 'Lebensmittel hinzufügen',
          ),
        ],
      ),
      body: _body(day),
    );
  }

  Widget _body(AsyncValue<DayNutrition> day) {
    if (day.hasError) {
      return const _Padded(
        _Message('Die Mahlzeit konnte nicht geladen werden.'),
      );
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!day.hasValue) return const SizedBox.shrink();

    final entries = day.value!.entriesOf(widget.mealType);
    if (entries.isEmpty) {
      return _Padded(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Message('Für diese Mahlzeit ist noch nichts eingetragen.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _addEntry,
              child: const Text('Lebensmittel hinzufügen'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: NutritionSummary(
                  label: widget.mealType.label,
                  nutrients: day.value!.totalOf(widget.mealType),
                ),
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) => _EntryRow(
            entry: entries[index],
            onEdit: () => _correctEntry(entries[index]),
            onDelete: () => _deleteEntry(entries[index]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  /// Picks a food, asks how much of it, and logs it — the two questions in the
  /// order they are actually answered.
  Future<void> _addEntry() async {
    final item = await context.push<FoodItem>('/nutrition/meal/food');
    if (item == null || !mounted) return;

    final grams = await showPortionEditor(
      context,
      item: item,
      // A food that names a portion starts on it, so the usual case is a tap
      // on the check rather than a weight looked up on the packet.
      initialGrams: item is Food ? item.portionGrams : null,
    );
    if (grams == null || !mounted) return;

    await _save(
      MealEntry(
        date: widget.day,
        mealType: widget.mealType,
        item: item,
        grams: grams,
      ),
    );
  }

  /// Corrects the amount of [entry], which stays the same food on the same
  /// day.
  Future<void> _correctEntry(MealEntry entry) async {
    final grams = await showPortionEditor(
      context,
      item: entry.item,
      initialGrams: entry.grams,
    );
    if (grams == null || !mounted) return;

    await _save(
      MealEntry(
        id: entry.id,
        date: entry.date,
        mealType: entry.mealType,
        item: entry.item,
        grams: grams,
      ),
    );
  }

  Future<void> _save(MealEntry entry) async {
    try {
      await ref.read(mealEntryRepositoryProvider).save(entry);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the screen would look exactly
      // as it does after a successful one, only without the entry in it.
      _logger.error('Saving the meal entry failed', error, stackTrace);
      _report('Der Eintrag konnte nicht gespeichert werden.');
    }
    // No refresh here: the screen watches the day, and the repository re-emits
    // it as soon as the write lands.
  }

  /// Removes [entry], answering whether it worked.
  ///
  /// The answer is what the swipe waits on: a delete that failed leaves the
  /// row where it is instead of animating away from an entry that is still
  /// there.
  Future<bool> _deleteEntry(MealEntry entry) async {
    try {
      await ref.read(mealEntryRepositoryProvider).delete(entry.id!);
      return true;
    } catch (error, stackTrace) {
      _logger.error('Deleting the meal entry failed', error, stackTrace);
      _report('Der Eintrag konnte nicht gelöscht werden.');
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

/// One entry in the meal: what was eaten, how much of it, and what that came
/// to.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final MealEntry entry;
  final VoidCallback onEdit;

  /// Deletes the entry and answers whether it worked — see
  /// `_MealDetailScreenState._deleteEntry`.
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nutrients = entry.nutrients;

    return Dismissible(
      // The row id is the identity of an entry — the same food may stand under
      // a meal twice, so the name would not tell two rows apart.
      key: ValueKey(entry.id),
      background: const _DismissBackground(alignment: Alignment.centerLeft),
      secondaryBackground: const _DismissBackground(
        alignment: Alignment.centerRight,
      ),
      // The delete itself runs here rather than in `onDismissed`: the row may
      // only leave once the entry is actually gone, or a failed write would
      // animate away something that is still on record.
      confirmDismiss: (_) => onDelete(),
      child: ListTile(
        title: Text(entry.item.name),
        subtitle: Text(
          '${formatGrams(entry.grams)} · ${formatMacros(nutrients)}',
        ),
        trailing: Text(
          formatKcal(nutrients.kcal),
          style: theme.textTheme.titleMedium,
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
