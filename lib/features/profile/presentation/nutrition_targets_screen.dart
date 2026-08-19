import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../data/user_profile_providers.dart';
import '../domain/macro_distribution.dart';
import '../domain/user_profile.dart';
import 'setting_row.dart';
import 'value_editor.dart';

const _logger = AppLogger('profile');

/// The daily calorie target and how it is split across the macronutrients.
///
/// One level below the goals screen: the goal decides how much energy the day
/// gets, this screen decides the number and what it is made of. The split
/// lives here rather than on the profile because it only means something next
/// to the calorie target it divides up.
///
/// The target is not calculated here — the goals screen keeps it in step with
/// the goal and the activity level on its own. What is entered here is a
/// number the user brings themselves.
class NutritionTargetsScreen extends ConsumerWidget {
  const NutritionTargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ernährungsziele')),
      body: switch (profile) {
        AsyncData(:final value) => _NutritionTargetsList(profile: value),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Die Ernährungsziele konnten nicht geladen werden.'),
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

class _NutritionTargetsList extends ConsumerWidget {
  const _NutritionTargetsList({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macros = profile.macros;
    final targets = profile.macroTargets;

    return ListView(
      children: [
        SettingRow(
          label: 'Kalorien',
          value: profile.calorieTarget == null
              ? 'Keine Angabe'
              : '${profile.calorieTarget}',
          onTap: () => _editCalorieTarget(context, ref),
        ),
        const Divider(height: 1),
        // Tapping any of the three opens the same editor: a share cannot be
        // changed on its own without breaking the 100 the three have to add
        // up to.
        _MacroRow(
          label: 'Kohlenhydrate',
          percent: macros.carbPercent,
          grams: targets?.carbGrams,
          onTap: () => _editMacros(context, ref),
        ),
        const Divider(height: 1),
        _MacroRow(
          label: 'Eiweiß',
          percent: macros.proteinPercent,
          grams: targets?.proteinGrams,
          onTap: () => _editMacros(context, ref),
        ),
        const Divider(height: 1),
        _MacroRow(
          label: 'Fett',
          percent: macros.fatPercent,
          grams: targets?.fatGrams,
          onTap: () => _editMacros(context, ref),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _editCalorieTarget(BuildContext context, WidgetRef ref) async {
    final entered = await showTextEditor(
      context,
      title: 'Kalorien',
      initialValue: profile.calorieTarget?.toString() ?? '',
      suffix: 'kcal',
      digitsOnly: true,
      // Empty means "not set yet" and stays allowed; anything else has to be a
      // number the domain model would accept.
      validate: (value) =>
          value.trim().isEmpty || _positiveOrNull(value) != null
          ? null
          : 'Das Kalorienziel muss größer als 0 sein.',
    );
    if (entered == null || !context.mounted) return;

    await _save(
      context,
      ref,
      profile.copyWith(calorieTarget: _positiveOrNull(entered)),
    );
  }

  Future<void> _editMacros(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<MacroDistribution>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MacroEditorSheet(macros: profile.macros),
    );
    if (chosen == null || !context.mounted) return;

    await _save(context, ref, profile.copyWith(macros: chosen));
  }

  int? _positiveOrNull(String text) {
    final number = int.tryParse(text.trim());
    return number != null && number > 0 ? number : null;
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    UserProfile updated,
  ) async {
    try {
      await ref.read(userProfileRepositoryProvider).save(updated);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the callback drops the error
      // and the screen looks exactly as it does after a success.
      _logger.error('Saving the nutrition targets failed', error, stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die Ernährungsziele konnten nicht gespeichert werden.',
          ),
        ),
      );
    }
  }
}

/// One share of the split: its percentage on the right, what that comes to in
/// grams next to the name.
///
/// The grams are what is eaten, so they are what makes a split easy to judge —
/// they are missing while no calorie target says what to divide up.
class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.percent,
    required this.grams,
    required this.onTap,
  });

  final String label;
  final int percent;
  final double? grams;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grams = this.grams;

    return SettingRow(
      label: label,
      detail: grams == null ? null : '${grams.round()} g',
      value: '$percent %',
      onTap: onTap,
    );
  }
}

/// All three shares at once, because 100 is a property of the three together.
class _MacroEditorSheet extends StatefulWidget {
  const _MacroEditorSheet({required this.macros});

  final MacroDistribution macros;

  @override
  State<_MacroEditorSheet> createState() => _MacroEditorSheetState();
}

class _MacroEditorSheetState extends State<_MacroEditorSheet> {
  late final _carbController = TextEditingController(
    text: widget.macros.carbPercent.toString(),
  );
  late final _proteinController = TextEditingController(
    text: widget.macros.proteinPercent.toString(),
  );
  late final _fatController = TextEditingController(
    text: widget.macros.fatPercent.toString(),
  );

  @override
  void dispose() {
    _carbController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final split = _draft();

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: 'Makroverteilung',
            onConfirm: split == null
                ? null
                : () => Navigator.of(context).pop(split),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                _PercentField(
                  label: 'Kohlenhydrate',
                  controller: _carbController,
                  onChanged: () => setState(() {}),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                _PercentField(
                  label: 'Eiweiß',
                  controller: _proteinController,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
                _PercentField(
                  label: 'Fett',
                  controller: _fatController,
                  onChanged: () => setState(() {}),
                ),
                // Only spoken about when it is in the way: a split that adds
                // up needs no comment, it is what the user was aiming for.
                if (split == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Die drei Anteile müssen zusammen 100 % ergeben '
                    '(aktuell ${_sum()} %).',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  int? _percentOrNull(TextEditingController controller) =>
      int.tryParse(controller.text);

  int _sum() =>
      (_percentOrNull(_carbController) ?? 0) +
      (_percentOrNull(_proteinController) ?? 0) +
      (_percentOrNull(_fatController) ?? 0);

  /// The split the fields describe, or `null` while they do not describe one.
  ///
  /// An empty field makes it `null` rather than counting as a zero share, and
  /// so does a sum other than 100 — exactly the case [MacroDistribution] would
  /// throw on.
  MacroDistribution? _draft() {
    final carbPercent = _percentOrNull(_carbController);
    final proteinPercent = _percentOrNull(_proteinController);
    final fatPercent = _percentOrNull(_fatController);

    if (carbPercent == null || proteinPercent == null || fatPercent == null) {
      return null;
    }
    if (carbPercent + proteinPercent + fatPercent != 100) return null;

    return MacroDistribution(
      carbPercent: carbPercent,
      proteinPercent: proteinPercent,
      fatPercent: fatPercent,
    );
  }
}

class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(labelText: label, suffixText: '%'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
    );
  }
}
