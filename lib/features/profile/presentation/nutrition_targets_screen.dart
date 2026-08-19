import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../data/user_profile_providers.dart';
import '../domain/calorie_calculation.dart';
import '../domain/macro_distribution.dart';
import '../domain/user_profile.dart';
import 'profile_formatting.dart';
import 'value_row.dart';

const _logger = AppLogger('profile');

/// The daily calorie target and how it is split across the macronutrients.
///
/// One level below the goals screen: the goal decides how much energy the day
/// gets, this screen decides the number and what it is made of. The split
/// lives here rather than on the profile because it only means something next
/// to the calorie target it divides up.
class NutritionTargetsScreen extends ConsumerWidget {
  const NutritionTargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ernährungsziele')),
      // The form seeds its fields from the profile it is given, so it is only
      // built once the profile is actually there.
      body: switch (profile) {
        AsyncData(:final value) => _NutritionTargetsForm(profile: value),
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

class _NutritionTargetsForm extends ConsumerStatefulWidget {
  const _NutritionTargetsForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_NutritionTargetsForm> createState() =>
      _NutritionTargetsFormState();
}

class _NutritionTargetsFormState extends ConsumerState<_NutritionTargetsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _calorieTargetController;
  late final TextEditingController _carbController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final macros = widget.profile.macros;
    _calorieTargetController = TextEditingController(
      text: widget.profile.calorieTarget?.toString() ?? '',
    );
    _carbController = TextEditingController(
      text: macros.carbPercent.toString(),
    );
    _proteinController = TextEditingController(
      text: macros.proteinPercent.toString(),
    );
    _fatController = TextEditingController(text: macros.fatPercent.toString());
  }

  @override
  void dispose() {
    _calorieTargetController.dispose();
    _carbController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The weight is not part of the profile; it comes from the weight entries,
    // where the most recent one is the one to calculate with.
    final weighings = ref.watch(latestBodyWeightProvider);
    final latestWeight = weighings.value;
    final calculation = CalorieCalculation.forProfile(
      widget.profile,
      weightKg: latestWeight?.weightKg,
      today: DateTime.now(),
    );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          TextFormField(
            controller: _calorieTargetController,
            decoration: const InputDecoration(
              labelText: 'Kalorienziel',
              suffixText: 'kcal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) =>
                _validatePositiveNumber(value, 'Das Kalorienziel'),
            // The gram targets below follow the calorie target, so they have
            // to be rebuilt while it is being typed.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _CalorieCalculationCard(
            calculation: calculation,
            weight: latestWeight,
            // A failed read looks like an empty series from here on — without
            // this the card would ask for an entry the user already made.
            weightUnreadable: weighings.hasError,
            missing: _missingForCalculation(widget.profile, latestWeight),
            // Only offered when the result is one the profile would accept:
            // body data that is off by enough puts the target at or below
            // zero, and taking that over would be a dead end.
            onApply: calculation == null || calculation.calorieTarget <= 0
                ? null
                : () => _applyCalculated(calculation),
          ),
          const SizedBox(height: 16),
          _MacroCard(
            carbController: _carbController,
            proteinController: _proteinController,
            fatController: _fatController,
            onChanged: () => setState(() {}),
            validate: _validatePercent,
            distribution: _draftMacros(),
            percentSum: _percentSum(),
            calorieTarget: _positiveOrNull(_calorieTargetController.text),
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: const Text('Speichern')),
        ],
      ),
    );
  }

  /// Empty means "not set yet" and stays allowed; anything else has to be a
  /// number the domain model would accept.
  String? _validatePositiveNumber(String? value, String subject) {
    if (value == null || value.trim().isEmpty) return null;

    final number = int.tryParse(value);
    if (number == null) return '$subject muss eine Zahl sein.';
    if (number <= 0) return '$subject muss größer als 0 sein.';
    return null;
  }

  /// Unlike the calorie target, a share may not be left empty: the three of
  /// them have to add up to 100, and a missing one cannot.
  String? _validatePercent(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bitte einen Wert.';

    final number = int.tryParse(value);
    if (number == null) return 'Nur ganze Zahlen.';
    if (number > 100) return 'Höchstens 100 %.';
    return null;
  }

  int? _positiveOrNull(String text) {
    final number = int.tryParse(text);
    return number != null && number > 0 ? number : null;
  }

  int? _percentOrNull(TextEditingController controller) =>
      int.tryParse(controller.text);

  /// The running total, counting a field that holds nothing as nothing.
  ///
  /// Only ever shown, never stored — [_draftMacros] is stricter about an empty
  /// field than this is.
  int _percentSum() =>
      (_percentOrNull(_carbController) ?? 0) +
      (_percentOrNull(_proteinController) ?? 0) +
      (_percentOrNull(_fatController) ?? 0);

  /// The split as the fields currently stand, or `null` while they do not
  /// describe one.
  ///
  /// An empty field makes it `null` rather than counting as a zero share:
  /// otherwise 70 / 30 / nothing would look like a valid split in the card
  /// while saving refuses it, and the screen would claim something it cannot
  /// store. A sum other than 100 is `null` as well — exactly the case
  /// [MacroDistribution] would throw on.
  MacroDistribution? _draftMacros() {
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

  /// What the calculation is still waiting for, named the way the fields are
  /// on the screens holding them.
  List<String> _missingForCalculation(
    UserProfile profile,
    BodyWeightEntry? weight,
  ) => [
    if (weight == null) 'ein Gewichtseintrag',
    if (profile.heightCm == null) 'die Größe',
    if (profile.sex == null) 'das Geschlecht',
    if (profile.birthDate == null) 'das Geburtsdatum',
    if (profile.activityLevel == null) 'das Aktivitätslevel',
  ];

  /// Puts the calculated target into the field — and no further.
  ///
  /// Nothing is stored until the user saves, so a target entered by hand is
  /// only ever replaced by an explicit tap on this button.
  void _applyCalculated(CalorieCalculation calculation) {
    setState(() {
      _calorieTargetController.text = calculation.calorieTarget.toString();
    });
    _show('Kalorienziel übernommen — noch nicht gespeichert');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Checked against the controller rather than trusting the validator
    // alone. `validate()` only ever asks the fields that are currently built,
    // and these sit in a ListView, which drops what is far enough out of
    // sight — a dropped field unregisters from the Form and is passed over.
    // The list keeps every field of this screen alive today, so the validator
    // does run; the check is here so a longer screen cannot turn a `0` into a
    // silent "no target at all" later on.
    final calorieText = _calorieTargetController.text.trim();
    final calorieTarget = _positiveOrNull(calorieText);
    if (calorieText.isNotEmpty && calorieTarget == null) {
      _show('Das Kalorienziel muss größer als 0 sein.');
      return;
    }

    final macros = _draftMacros();
    if (macros == null) {
      _show('Die Makroverteilung braucht drei Anteile, zusammen 100 %.');
      return;
    }

    final updated = widget.profile.copyWith(
      calorieTarget: calorieTarget,
      macros: macros,
    );

    try {
      await ref.read(userProfileRepositoryProvider).save(updated);
    } catch (error, stackTrace) {
      // Without this the write fails silently: the button callback drops the
      // error and the screen looks exactly as it does after a success.
      _logger.error('Saving the nutrition targets failed', error, stackTrace);
      if (!mounted) return;
      _show('Die Ernährungsziele konnten nicht gespeichert werden.');
      return;
    }

    if (!mounted) return;
    _show('Ernährungsziele gespeichert');
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// The three shares, the running sum, and what they come to in grams.
class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.carbController,
    required this.proteinController,
    required this.fatController,
    required this.onChanged,
    required this.validate,
    required this.distribution,
    required this.percentSum,
    required this.calorieTarget,
  });

  final TextEditingController carbController;
  final TextEditingController proteinController;
  final TextEditingController fatController;
  final VoidCallback onChanged;
  final FormFieldValidator<String> validate;

  /// The split the fields describe, or `null` while they do not add up to 100.
  final MacroDistribution? distribution;

  final int percentSum;
  final int? calorieTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distribution = this.distribution;
    final calorieTarget = this.calorieTarget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Makroverteilung', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Anteile am Kalorienziel, zusammen 100 %.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _PercentField(
              label: 'Kohlenhydrate',
              controller: carbController,
              onChanged: onChanged,
              validator: validate,
            ),
            const SizedBox(height: 12),
            _PercentField(
              label: 'Eiweiß',
              controller: proteinController,
              onChanged: onChanged,
              validator: validate,
            ),
            const SizedBox(height: 12),
            _PercentField(
              label: 'Fett',
              controller: fatController,
              onChanged: onChanged,
              validator: validate,
            ),
            const SizedBox(height: 12),
            // Always shown, not only when it is wrong: a sum that is right is
            // what the user is aiming for while typing.
            Text(
              percentSum == 100
                  ? 'Summe: 100 %'
                  : 'Summe: $percentSum % — muss 100 % ergeben.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: percentSum == 100 ? null : theme.colorScheme.error,
              ),
            ),
            if (distribution != null && calorieTarget != null) ...[
              const Divider(height: 24),
              // The percentages are what is stored; the grams are what is
              // eaten, so they are what makes a split easy to judge.
              Text(
                'Ergibt bei $calorieTarget kcal',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ..._gramRows(distribution.gramsFor(calorieTarget)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _gramRows(MacroTargets targets) => [
    ValueRow(label: 'Kohlenhydrate', value: _grams(targets.carbGrams)),
    ValueRow(label: 'Eiweiß', value: _grams(targets.proteinGrams)),
    ValueRow(label: 'Fett', value: _grams(targets.fatGrams)),
  ];

  String _grams(double value) => '${value.round()} g';
}

/// One share of the split, in whole percent.
class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: '%'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      onChanged: (_) => onChanged(),
    );
  }
}

/// Shows how the calorie target is calculated, and hands the result over to
/// the field above on request.
///
/// The steps are laid out rather than just the result: a target that appears
/// out of nowhere is one nobody can check, and the numbers behind it are what
/// tells the user which value to correct when it looks wrong.
class _CalorieCalculationCard extends StatelessWidget {
  const _CalorieCalculationCard({
    required this.calculation,
    required this.weight,
    required this.weightUnreadable,
    required this.missing,
    required this.onApply,
  });

  /// The calculation, or `null` while [missing] still holds something.
  final CalorieCalculation? calculation;

  /// The entry the weight comes from, shown so its date is visible too.
  final BodyWeightEntry? weight;

  /// Whether the weight entries could not be read at all — a different case
  /// from not having any, and one the user cannot fix by weighing themselves.
  final bool weightUnreadable;

  final List<String> missing;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculation = this.calculation;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kalorienziel berechnen', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (weightUnreadable)
              Text(
                'Das letzte Gewicht konnte nicht gelesen werden.',
                style: theme.textTheme.bodyMedium,
              )
            else if (calculation == null) ...[
              Text(
                '${missing.length == 1 ? 'Dafür fehlt' : 'Dafür fehlen'} noch: '
                '${missing.join(', ')}.',
                style: theme.textTheme.bodyMedium,
              ),
              // None of it is entered here, so the note has to say where it is.
              if (missing.length > 1 || missing.single != 'ein Gewichtseintrag')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Größe, Geschlecht und Geburtsdatum stehen im Profil, '
                    'das Aktivitätslevel unter „Ziele".',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ] else
              ..._steps(context, calculation),
          ],
        ),
      ),
    );
  }

  List<Widget> _steps(BuildContext context, CalorieCalculation calculation) {
    final weight = this.weight;

    return [
      if (weight != null)
        ValueRow(
          label: 'Gewicht vom ${formatDate(weight.date)}',
          value: '${formatDecimal(weight.weightKg, 1)} kg',
        ),
      ValueRow(
        label: 'Grundumsatz (Mifflin-St Jeor)',
        value: _kcal(calculation.basalMetabolicRate.round()),
      ),
      ValueRow(
        label:
            'Aktivität (× ${formatDecimal(calculation.activityLevel.calorieFactor, 3)})',
        value: _kcal(calculation.totalEnergyExpenditure.round()),
      ),
      ValueRow(
        label:
            '${calculation.goal.label} '
            '(${_gramsPerWeek(calculation.goal.weeklyWeightChangeGrams)})',
        value: _signedKcal(calculation.goalAdjustment),
      ),
      const Divider(height: 24),
      ValueRow(
        label: 'Kalorienziel',
        value: _kcal(calculation.calorieTarget),
        emphasised: true,
      ),
      const SizedBox(height: 12),
      // Tonal rather than filled: it fills in the field above, the save
      // button below is the one that stores anything. Full width like every
      // filled button in the app — the theme sizes them that way.
      FilledButton.tonal(onPressed: onApply, child: const Text('Übernehmen')),
    ];
  }

  String _kcal(int value) => '$value kcal';

  String _signedKcal(int value) => switch (value) {
    0 => '±0 kcal',
    < 0 => '−${value.abs()} kcal',
    _ => '+$value kcal',
  };

  String _gramsPerWeek(int grams) => switch (grams) {
    0 => 'Gewicht bleibt',
    < 0 => '−${grams.abs()} g pro Woche',
    _ => '+$grams g pro Woche',
  };
}
