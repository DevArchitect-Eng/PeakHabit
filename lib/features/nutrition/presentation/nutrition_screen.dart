import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../../profile/data/user_profile_providers.dart';
import '../../profile/domain/user_profile.dart';
import '../data/nutrition_providers.dart';
import '../domain/day_nutrition.dart';
import '../domain/meal_entry.dart';
import '../domain/nutrients.dart';
import 'nutrition_formatting.dart';
import 'nutrition_summary.dart';

const _logger = AppLogger('nutrition');

/// The nutrition tab: one day, split into the four meals, with what each of
/// them came to.
///
/// The day is state of this screen rather than part of the route. It is the
/// tab's own root, and moving between days is a control on it, not navigation
/// — a day per history entry would make the back gesture undo a date change
/// instead of leaving the tab. The meal screen underneath does carry its day,
/// because a screen reached from here has to know which one it was opened on.
class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  late DateTime _day = DateUtils.dateOnly(DateTime.now());

  /// The day before the one on screen — where the suggestion to copy a meal
  /// comes from.
  ///
  /// Built by subtracting from the day number rather than by subtracting 24
  /// hours: a day on which the clocks change is not 24 hours long, and the
  /// hour left over would key a second, identical query.
  DateTime get _previousDay => DateTime(_day.year, _day.month, _day.day - 1);

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(dayNutritionProvider(_day));
    final previous = ref.watch(dayNutritionProvider(_previousDay));
    // The targets come from the profile rather than from anything this tab
    // stores: the calorie target and the macro split are set on the goals
    // screen, and the gram targets follow from the two.
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ernährung'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _DayPicker(
            day: _day,
            onChanged: (day) => setState(() => _day = day),
          ),
        ),
      ),
      body: _body(day, previous, profile),
    );
  }

  Widget _body(
    AsyncValue<DayNutrition> day,
    AsyncValue<DayNutrition> previous,
    UserProfile? profile,
  ) {
    if (day.hasError) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: _Message('Der Tag konnte nicht geladen werden.'),
      );
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!day.hasValue) return const SizedBox.shrink();

    final today = day.value!;
    final calorieTarget = profile?.calorieTarget;
    final macroTargets = profile?.macroTargets;
    final targets = calorieTarget == null || macroTargets == null
        ? null
        : (kcal: calorieTarget, macros: macroTargets);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NutritionSummary(
                  label: 'Tagessumme',
                  nutrients: today.total,
                  targets: targets,
                ),
                // A sum without anything to measure it against is not a
                // mistake to hide — it says where the target is set instead
                // of quietly printing figures that stand for nothing.
                if (targets == null) ...[
                  const SizedBox(height: 12),
                  const _Message(
                    'Noch kein Kalorienziel hinterlegt. Unter Optionen › Ziele '
                    'lässt es sich setzen.',
                  ),
                ],
              ],
            ),
          ),
        ),
        for (final mealType in MealType.values)
          _MealCard(
            mealType: mealType,
            nutrients: today.totalOf(mealType),
            entries: today.entriesOf(mealType),
            // Only where nothing stands under the meal yet: copying onto a
            // meal that is already filled would add yesterday's portions on
            // top of today's rather than repeat the day.
            suggestion: today.entriesOf(mealType).isEmpty
                ? previous.value?.entriesOf(mealType)
                : null,
            onOpen: () => _openMeal(mealType),
            onAdd: () => _openMeal(mealType, adding: true),
            onCopyPreviousDay: () => _copyPreviousDay(mealType),
          ),
      ],
    );
  }

  /// Opens the meal, either on its entries or straight on the food picker.
  ///
  /// The "+" goes through the meal screen rather than opening the picker from
  /// here: adding is the same three steps either way, and doing it in one
  /// place means the screen the entry lands on is the one that shows it.
  void _openMeal(MealType mealType, {bool adding = false}) => context.push(
    '/nutrition/meal?type=${mealType.name}&date=${dayParameter(_day)}'
    '${adding ? '&add=1' : ''}',
  );

  /// Copies the previous day's [mealType] onto the day on screen.
  ///
  /// Always answers `false`, so the swipe never actually dismisses the row —
  /// see [_CopySuggestion] for why the suggestion springs back instead of
  /// animating away.
  Future<bool> _copyPreviousDay(MealType mealType) async {
    try {
      await ref
          .read(mealEntryRepositoryProvider)
          .copyMeal(mealType: mealType, from: _previousDay, to: _day);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the suggestion would spring
      // back exactly as it does after a copy that worked.
      _logger.error('Copying the meal failed', error, stackTrace);
      _report('Die Mahlzeit konnte nicht übernommen werden.');
      return false;
    }

    _report('${mealType.label} vom Vortag übernommen.');
    return false;
  }

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The control that moves between days: a step back, the day itself, a step
/// forward.
///
/// It does not go past today. Nothing in the model forbids a future date, but
/// the tab records what was eaten, and a day that has not happened yet has
/// nothing to record — the same reason the weight editor's date picker stops
/// there.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.day, required this.onChanged});

  final DateTime day;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final atToday = !day.isBefore(today);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => onChanged(_shifted(-1)),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Vorheriger Tag',
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _pickDay(context, today),
              child: Text(formatDayLabel(day, today: today)),
            ),
          ),
          IconButton(
            onPressed: atToday ? null : () => onChanged(_shifted(1)),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Nächster Tag',
          ),
        ],
      ),
    );
  }

  /// The day [days] away, counted in day numbers so a change of clocks cannot
  /// land it on the wrong one.
  DateTime _shifted(int days) => DateTime(day.year, day.month, day.day + days);

  Future<void> _pickDay(BuildContext context, DateTime today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) onChanged(DateUtils.dateOnly(picked));
  }
}

/// One of the four meals: what it is, what it came to, and the way into it.
///
/// **No target beside the figures.** The row says what has been eaten and
/// nothing about a share of the daily goal — see [NutritionSummary].
class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.mealType,
    required this.nutrients,
    required this.entries,
    required this.suggestion,
    required this.onOpen,
    required this.onAdd,
    required this.onCopyPreviousDay,
  });

  final MealType mealType;

  /// What the meal came to — zero on a day nothing was logged, where the row
  /// still shows rather than disappearing.
  final Nutrients nutrients;

  /// What was eaten at this meal, listed under the row so the tab answers
  /// "what did I have for breakfast" without being opened.
  final List<MealEntry> entries;

  /// What stood under the same meal the day before, offered for copying.
  /// `null` or empty where there is nothing to offer.
  final List<MealEntry>? suggestion;

  /// Opens the meal on its entries — what tapping the row does.
  final VoidCallback onOpen;

  /// Opens the meal straight on the food picker — what the "+" does.
  final VoidCallback onAdd;

  /// Copies the previous day's meal, answering whether anything was written.
  final Future<bool> Function() onCopyPreviousDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestion = this.suggestion;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(mealType.icon, color: theme.colorScheme.primary),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    mealType.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatKcal(nutrients.kcal),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            subtitle: Text(formatMacros(nutrients)),
            trailing: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              tooltip: '${mealType.label} ergänzen',
            ),
            onTap: onOpen,
          ),
          // Tapping a line opens the meal, the same as tapping the row above:
          // the line is a glance at what is there, and changing it is what the
          // meal screen is for.
          for (final entry in entries)
            InkWell(
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.item.name,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${formatGrams(entry.grams)} · '
                      '${formatKcal(entry.nutrients.kcal)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (entries.isNotEmpty) const SizedBox(height: 4),
          if (suggestion != null && suggestion.isNotEmpty)
            _CopySuggestion(entries: suggestion, onCopy: onCopyPreviousDay),
        ],
      ),
    );
  }
}

/// The offer to repeat the previous day's meal, confirmed by swiping right.
///
/// The swipe **does not dismiss the row**: it confirms a suggestion rather
/// than removing an entry, so a successful copy answers `false` and lets the
/// row spring back. It disappears a moment later anyway, because the meal is
/// no longer empty and the suggestion no longer applies. Animating it away
/// instead would leave a dismissed [Dismissible] in the tree for as long as
/// the write takes to come back through the day's stream.
class _CopySuggestion extends StatelessWidget {
  const _CopySuggestion({required this.entries, required this.onCopy});

  /// The previous day's entries under this meal, never empty.
  final List<MealEntry> entries;

  final Future<bool> Function() onCopy;

  /// How many foods the line names before it gives up and counts the rest.
  static const _namesShown = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = entries.fold(
      Nutrients.zero,
      (sum, entry) => sum + entry.nutrients,
    );

    return Dismissible(
      key: ValueKey(
        'copy-${entries.first.mealType.name}-${entries.first.date}',
      ),
      // Right only, as the hint says. A left swipe would have to mean
      // something else, and there is nothing else to mean here.
      direction: DismissDirection.startToEnd,
      background: const _ConfirmBackground(),
      confirmDismiss: (_) => onCopy(),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.history, color: theme.colorScheme.onSurfaceVariant),
        title: Text('Vom Vortag: $_names'),
        subtitle: Text(
          '${formatKcal(total.kcal)} · nach rechts wischen zum Übernehmen',
        ),
      ),
    );
  }

  /// The foods of the previous day's meal, cut off before the line grows into
  /// a paragraph.
  String get _names {
    final names = entries.map((entry) => entry.item.name).toList();
    if (names.length <= _namesShown) return names.join(', ');
    final rest = names.length - _namesShown;
    return '${names.take(_namesShown).join(', ')} +$rest';
  }
}

/// What shows under the suggestion while it is being swiped.
class _ConfirmBackground extends StatelessWidget {
  const _ConfirmBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.check, color: scheme.onPrimaryContainer),
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
