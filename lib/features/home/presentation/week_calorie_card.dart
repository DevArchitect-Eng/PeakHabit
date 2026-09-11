import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../nutrition/data/nutrition_providers.dart';
import '../../nutrition/domain/day_nutrition.dart';
import '../../nutrition/presentation/nutrition_day_provider.dart';
import '../../profile/data/user_profile_providers.dart';
import '../../profile/domain/calorie_target_history.dart';

/// How far a day may land from its calorie target and still count as on it.
const calorieTolerance = 50.0;

/// What a day's ring says about it.
enum CalorieMark {
  /// The day had no target to be measured against.
  noTarget,

  /// Below the target by more than [calorieTolerance] — including a day
  /// nothing was logged on. The ring is simply not full yet; falling short
  /// is not flagged.
  under,

  /// Within [calorieTolerance] of the target, either side.
  onTarget,

  /// Past the target by more than [calorieTolerance].
  over,
}

/// The mark [kcal] earns against [target] — see [CalorieMark].
CalorieMark calorieMarkFor({required double kcal, required int? target}) {
  if (target == null) return CalorieMark.noTarget;
  final difference = kcal - target;
  if (difference > calorieTolerance) return CalorieMark.over;
  if (difference < -calorieTolerance) return CalorieMark.under;
  return CalorieMark.onTarget;
}

/// The week of the home screen: Monday to Sunday, each day as a ring filled
/// by how much of its calorie target was eaten.
///
/// Always the **calendar week** of today, not the last seven days: it starts
/// over on a Monday, the way a week is planned. Days after today are there
/// with an empty ring, so the row keeps its seven places and today its spot
/// in it.
///
/// A past day is measured against the target it had rather than today's (see
/// [CalorieTargetHistory]) — a change on the goals screen should not re-mark
/// the days before it.
///
/// Unlike the nutrition card below it, a day is a way into the nutrition tab:
/// the navigation bar only opens the tab on the day it last showed, and
/// getting to Tuesday from there takes stepping back through the days one by
/// one. The home stack stays where it was — every tab keeps its own.
class WeekCalorieCard extends ConsumerWidget {
  const WeekCalorieCard({super.key, @visibleForTesting this.today});

  /// The day the week is built around — the real today unless a test pins
  /// one, so what a week looks like does not depend on the weekday the test
  /// happens to run on.
  final DateTime? today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateUtils.dateOnly(this.today ?? DateTime.now());
    final week = weekOf(today);
    // Only the days that have happened: a day to come has nothing logged on
    // it, and watching it would keep a query open for nothing.
    final days = {
      for (final day in week)
        if (!day.isAfter(today)) day: ref.watch(dayNutritionProvider(day)),
    };
    final history = ref.watch(calorieTargetHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Diese Woche', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _body(context, ref, week, today, days, history),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    List<DateTime> week,
    DateTime today,
    Map<DateTime, AsyncValue<DayNutrition>> days,
    AsyncValue<CalorieTargetHistory> history,
  ) {
    if (history.hasError || days.values.any((day) => day.hasError)) {
      return const _Message('Die Woche konnte nicht geladen werden.');
    }
    // Reading from a local database takes about a frame, so there is nothing
    // to show in the meantime — and a spinner would never settle for a widget
    // test waiting on it.
    if (!history.hasValue || days.values.any((day) => !day.hasValue)) {
      return const SizedBox.shrink();
    }
    final targets = history.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final day in week)
              Expanded(
                child: _DayRing(
                  key: ValueKey(day),
                  day: day,
                  isToday: day == today,
                  // `null` for a day still to come.
                  kcal: days[day]?.value!.total.kcal,
                  target: targets.targetOn(day),
                  onTap: day.isAfter(today)
                      ? null
                      : () => _openDay(context, ref, day),
                ),
              ),
          ],
        ),
        // The rings still show without a target — a week's structure and the
        // days logged on are worth seeing — but none of them is judged, and
        // this says why and where that changes.
        if (targets.targetOn(today) == null) ...[
          const SizedBox(height: 12),
          const _Message(
            'Noch kein Kalorienziel hinterlegt. Unter Optionen › Ziele lässt es '
            'sich setzen.',
          ),
        ],
      ],
    );
  }

  /// Puts the nutrition tab on [day] and switches to it.
  ///
  /// `go` rather than the navigation bar's `goBranch`: it takes the tab back
  /// to its day view, where a meal screen still open from before would
  /// otherwise stand in front of the day that was asked for.
  void _openDay(BuildContext context, WidgetRef ref, DateTime day) {
    ref.read(nutritionDayProvider.notifier).show(day);
    context.go('/nutrition');
  }
}

/// The seven days of the calendar week [day] falls in, Monday first.
///
/// Counted in day numbers rather than by adding 24 hours: a week holding a
/// change of clocks has a day of 23 or 25 hours in it, and midnight plus 24
/// hours would land on the wrong one.
List<DateTime> weekOf(DateTime day) {
  final monday = DateTime(day.year, day.month, day.day - (day.weekday - 1));
  return [
    for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
      DateTime(monday.year, monday.month, monday.day + offset),
  ];
}

const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _weekdayLong = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

/// One day of the week: its weekday, its ring and its date.
class _DayRing extends StatelessWidget {
  const _DayRing({
    super.key,
    required this.day,
    required this.isToday,
    required this.kcal,
    required this.target,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;

  /// What was eaten that day — `null` for a day still to come, which has no
  /// figure yet rather than a figure of zero.
  final double? kcal;

  final int? target;

  /// `null` for a day still to come: the nutrition tab does not go past
  /// today, so there is nothing to open.
  final VoidCallback? onTap;

  static const _diameter = 36.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kcal = this.kcal;
    final mark = kcal == null
        ? CalorieMark.noTarget
        : calorieMarkFor(kcal: kcal, target: target);
    final upcoming = kcal == null;

    // Today stands out by its weight and colour and by the patch behind it;
    // a day to come is faded, because there is nothing on it yet.
    final labelColor = isToday
        ? scheme.primary
        : upcoming
        ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
        : scheme.onSurfaceVariant;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: labelColor,
      fontWeight: isToday ? FontWeight.bold : null,
    );

    return Semantics(
      label: _semanticLabel(mark),
      button: onTap != null,
      // Handed on here as well: `excludeSemantics` drops the InkWell's own
      // tap action with the rest of what is underneath, and a screen reader
      // would announce a button it cannot press.
      onTap: onTap,
      // Each day a node of its own, even one to come that is no button —
      // otherwise its label melts into the card's heading.
      container: true,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: isToday
                ? BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _Fitted(
                  Text(_weekdayShort[day.weekday - 1], style: labelStyle),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: _diameter,
                  height: _diameter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Filled rather than merely offered the box — see
                      // `_CalorieRing` in the nutrition card.
                      Positioned.fill(
                        child: _Ring(
                          kcal: kcal ?? 0,
                          target: target,
                          mark: mark,
                        ),
                      ),
                      _MarkIcon(mark),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                _Fitted(Text('${day.day}.${day.month}.', style: labelStyle)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// What a screen reader says for the day: the date in words, and the
  /// figures the ring only draws.
  String _semanticLabel(CalorieMark mark) {
    final date = '${_weekdayLong[day.weekday - 1]}, ${day.day}.${day.month}.';
    final prefix = isToday ? 'Heute, $date' : date;
    final kcal = this.kcal;
    if (kcal == null) return prefix;

    final eaten = kcal.round();
    return switch (mark) {
      CalorieMark.noTarget => '$prefix: $eaten kcal, kein Ziel',
      CalorieMark.under => '$prefix: $eaten von $target kcal',
      CalorieMark.onTarget => '$prefix: $eaten von $target kcal, im Ziel',
      CalorieMark.over => '$prefix: $eaten von $target kcal, zu viel',
    };
  }
}

/// A day's ring: filled by the share of its target that was eaten, capped
/// once the target is reached.
///
/// Green inside the tolerance, `tertiary` past it — the same colour the
/// nutrition card and tab use for an overrun. Neither is ever the only sign:
/// [_MarkIcon] draws a check or an arrow into the ring as well.
class _Ring extends StatelessWidget {
  const _Ring({required this.kcal, required this.target, required this.mark});

  final double kcal;
  final int? target;
  final CalorieMark mark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = this.target;
    // No share of nothing: a day without a target leaves its ring empty
    // rather than drawing a fraction it cannot have. A target of zero cannot
    // come out of the profile, but dividing by it would paint a NaN rather
    // than fail, so the guard stays.
    final progress = target == null || target <= 0
        ? 0.0
        : (kcal / target).clamp(0.0, 1.0);

    return CircularProgressIndicator(
      // Always a value, never null: an indeterminate indicator animates
      // forever, and `pumpAndSettle` would never settle against it.
      value: progress,
      strokeWidth: 4,
      strokeCap: StrokeCap.round,
      backgroundColor: scheme.surfaceContainerHighest,
      color: switch (mark) {
        CalorieMark.onTarget => onTargetColor(context),
        CalorieMark.over => scheme.tertiary,
        CalorieMark.under || CalorieMark.noTarget => scheme.primary,
      },
    );
  }
}

/// The green of a day on its target.
///
/// Not from the colour scheme: a seed of light blue gives no green. One per
/// brightness, because a green that reads on near-black washes out on white —
/// the same pair the weight screen uses for its trend.
Color onTargetColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF4ADE80)
    : const Color(0xFF15803D);

/// What stands inside a ring besides its colour: a check for a day on its
/// target, an arrow for one past it.
///
/// A day that fell short has none — the ring that is not full says so
/// already, and it is not a warning.
class _MarkIcon extends StatelessWidget {
  const _MarkIcon(this.mark);

  final CalorieMark mark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (mark) {
      CalorieMark.onTarget => Icon(
        Icons.check,
        size: 18,
        color: onTargetColor(context),
      ),
      CalorieMark.over => Icon(
        Icons.arrow_upward,
        size: 18,
        color: scheme.tertiary,
      ),
      CalorieMark.under || CalorieMark.noTarget => const SizedBox.shrink(),
    };
  }
}

/// A label under or over a ring, shrunk rather than wrapped or cut off when
/// the column is narrow or the system text is large.
class _Fitted extends StatelessWidget {
  const _Fitted(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, child: child);
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
