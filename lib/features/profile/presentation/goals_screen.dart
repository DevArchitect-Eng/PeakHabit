import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../data/user_profile_providers.dart';
import '../domain/user_profile.dart';
import 'profile_formatting.dart';
import 'value_row.dart';

const _logger = AppLogger('profile');

/// What the user is working towards: the weight goal and the activity level it
/// is calculated with.
///
/// Reached from the settings tab, one level above the nutrition targets. Split
/// off the profile screen because the profile answers "who is this" while this
/// one answers "where is this going" — and the starting and current weight
/// only mean something next to a goal.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ziele')),
      // The form seeds its fields from the profile it is given, so it is only
      // built once the profile is actually there.
      body: switch (profile) {
        AsyncData(:final value) => _GoalsForm(profile: value),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Die Ziele konnten nicht geladen werden.'),
          ),
        ),
        // Reading one row from a local database takes about a frame, so a
        // spinner would only flicker. It would also never stop spinning for
        // `pumpAndSettle`, which is what a widget test waits on.
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _GoalsForm extends ConsumerStatefulWidget {
  const _GoalsForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends ConsumerState<_GoalsForm> {
  late WeightGoal _goal = widget.profile.goal;
  late ActivityLevel? _activityLevel = widget.profile.activityLevel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const _WeightSummaryCard(),
        const SizedBox(height: 16),
        DropdownButtonFormField<WeightGoal>(
          initialValue: _goal,
          decoration: const InputDecoration(labelText: 'Ziel'),
          items: [
            for (final goal in WeightGoal.values)
              DropdownMenuItem(value: goal, child: Text(goal.label)),
          ],
          // The goal always has a value, so a null selection cannot happen.
          onChanged: (value) => setState(() => _goal = value ?? _goal),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ActivityLevel?>(
          initialValue: _activityLevel,
          decoration: const InputDecoration(labelText: 'Aktivitätslevel'),
          items: [
            const DropdownMenuItem(child: Text('Keine Angabe')),
            for (final level in ActivityLevel.values)
              DropdownMenuItem(value: level, child: Text(level.label)),
          ],
          onChanged: (value) => setState(() => _activityLevel = value),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: _save, child: const Text('Speichern')),
      ],
    );
  }

  Future<void> _save() async {
    // Only the two fields this screen owns are written; everything else of the
    // profile is carried over as it stands.
    final updated = widget.profile.copyWith(
      goal: _goal,
      activityLevel: _activityLevel,
    );

    try {
      await ref.read(userProfileRepositoryProvider).save(updated);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the button callback drops the
      // error and the screen looks exactly as it does after a success.
      _logger.error('Saving the goals failed', error, stackTrace);
      if (!mounted) return;
      _show('Die Ziele konnten nicht gespeichert werden.');
      return;
    }

    if (!mounted) return;
    _show('Ziele gespeichert');
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// Where the user started and where they stand, straight from the weight
/// entries.
///
/// Read-only on purpose: weighing happens on the home screen, and a second
/// place to enter it would be a second place to get it wrong.
class _WeightSummaryCard extends ConsumerWidget {
  const _WeightSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final first = ref.watch(firstBodyWeightProvider);
    final latest = ref.watch(latestBodyWeightProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gewicht', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (first.hasError || latest.hasError)
              // Not "weigh yourself" — the user has no way to fix a failed
              // read by stepping on the scale.
              Text(
                'Die Gewichtseinträge konnten nicht gelesen werden.',
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              _WeightRow(label: 'Startgewicht', entry: first.value),
              _WeightRow(label: 'Aktuelles Gewicht', entry: latest.value),
            ],
          ],
        ),
      ),
    );
  }
}

/// One weighing, or the note that there is none yet.
class _WeightRow extends StatelessWidget {
  const _WeightRow({required this.label, required this.entry});

  final String label;
  final BodyWeightEntry? entry;

  @override
  Widget build(BuildContext context) {
    final entry = this.entry;

    return ValueRow(
      label: entry == null ? label : '$label (${formatDate(entry.date)})',
      value: entry == null
          ? 'Kein Eintrag'
          : '${formatDecimal(entry.weightKg, 1)} kg',
    );
  }
}
