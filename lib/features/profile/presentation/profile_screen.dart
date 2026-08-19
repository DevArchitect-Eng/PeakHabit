import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../data/user_profile_providers.dart';
import '../domain/calorie_calculation.dart';
import '../domain/user_profile.dart';

const _logger = AppLogger('profile');

/// Edits the one user profile.
///
/// Reached from the settings tab, so the values entered during onboarding can
/// be corrected later. The macro split is deliberately not editable here: it
/// belongs with the calorie target it divides up.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // The form seeds its fields from the profile it is given, so it is only
      // built once the profile is actually there.
      body: switch (profile) {
        AsyncData(:final value) => _ProfileForm(profile: value),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Das Profil konnte nicht geladen werden.'),
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

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _heightController;
  late final TextEditingController _calorieTargetController;

  late BiologicalSex? _sex = widget.profile.sex;
  late DateTime? _birthDate = widget.profile.birthDate;
  late ActivityLevel? _activityLevel = widget.profile.activityLevel;
  late WeightGoal _goal = widget.profile.goal;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _heightController = TextEditingController(
      text: widget.profile.heightCm?.toString() ?? '',
    );
    _calorieTargetController = TextEditingController(
      text: widget.profile.calorieTarget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _heightController.dispose();
    _calorieTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The weight is not part of the profile; it comes from the weight entries,
    // where the most recent one is the one to calculate with.
    final weighings = ref.watch(latestBodyWeightProvider);
    final latestWeight = weighings.value;
    final draft = _draftProfile();
    final calculation = CalorieCalculation.forProfile(
      draft,
      weightKg: latestWeight?.weightKg,
      today: DateTime.now(),
    );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Benutzername'),
            validator: _validateUsername,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Größe',
              suffixText: 'cm',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) => _validatePositiveNumber(value, 'Die Größe'),
            // The calculation below reads the height, so it has to be rebuilt
            // while it is being typed — the dropdowns do that on their own.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BiologicalSex?>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: 'Geschlecht'),
            items: [
              const DropdownMenuItem(child: Text('Keine Angabe')),
              for (final sex in BiologicalSex.values)
                DropdownMenuItem(value: sex, child: Text(sex.label)),
            ],
            onChanged: (value) => setState(() => _sex = value),
          ),
          const SizedBox(height: 16),
          _BirthDateField(
            value: _birthDate,
            onChanged: (value) => setState(() => _birthDate = value),
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
          ),
          const SizedBox(height: 16),
          _CalorieCalculationCard(
            calculation: calculation,
            weight: latestWeight,
            // A failed read looks like an empty series from here on — without
            // this the card would ask for an entry the user already made.
            weightUnreadable: weighings.hasError,
            missing: _missingForCalculation(draft, latestWeight),
            onApply: calculation == null
                ? null
                : () => _applyCalculated(calculation),
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: const Text('Speichern')),
        ],
      ),
    );
  }

  /// Unlike the fields below, empty is not allowed here — the greeting on the
  /// home screen needs an actual name to show.
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte einen Benutzernamen eingeben.';
    }
    return null;
  }

  /// Empty means "not filled in yet" and stays allowed; anything else has to be
  /// a number the domain model would accept.
  String? _validatePositiveNumber(String? value, String subject) {
    if (value == null || value.trim().isEmpty) return null;

    final number = int.tryParse(value);
    if (number == null) return '$subject muss eine Zahl sein.';
    if (number <= 0) return '$subject muss größer als 0 sein.';
    return null;
  }

  /// The profile as the form currently stands — what a save would write, and
  /// what the calculation reads.
  ///
  /// A value the form would reject counts as not filled in: while a `0` stands
  /// in the height field there is nothing to calculate from, and the domain
  /// model would throw on it. Saving never gets here with such a value, the
  /// validator stops it first.
  UserProfile _draftProfile() => UserProfile(
    username: _usernameController.text.trim(),
    heightCm: _positiveOrNull(_heightController.text),
    sex: _sex,
    birthDate: _birthDate,
    activityLevel: _activityLevel,
    goal: _goal,
    calorieTarget: _positiveOrNull(_calorieTargetController.text),
    // Carried over untouched — this screen does not edit the split.
    macros: widget.profile.macros,
  );

  int? _positiveOrNull(String text) {
    final number = int.tryParse(text);
    return number != null && number > 0 ? number : null;
  }

  /// What the calculation is still waiting for, named the way the fields above
  /// are.
  List<String> _missingForCalculation(
    UserProfile draft,
    BodyWeightEntry? weight,
  ) => [
    if (weight == null) 'ein Gewichtseintrag',
    if (draft.heightCm == null) 'die Größe',
    if (draft.sex == null) 'das Geschlecht',
    if (draft.birthDate == null) 'das Geburtsdatum',
    if (draft.activityLevel == null) 'das Aktivitätslevel',
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

    try {
      await ref.read(userProfileRepositoryProvider).save(_draftProfile());
    } catch (error, stackTrace) {
      // Without this the write fails silently: the button callback drops the
      // error and the screen looks exactly as it does after a success.
      _logger.error('Saving the profile failed', error, stackTrace);
      if (!mounted) return;
      _show('Das Profil konnte nicht gespeichert werden.');
      return;
    }

    if (!mounted) return;
    _show('Profil gespeichert');
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// Birth date as a tappable row, because a date is easier to pick than to type.
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    // The tap target is the whole row, like the dropdowns above and below it —
    // wrapping only the text would leave most of the field dead.
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Geburtsdatum',
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Geburtsdatum entfernen',
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(value == null ? 'Keine Angabe' : _formatDate(value)),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year - 30, now.month, now.day),
      // Nobody using this app was born before 1900, and a birth date in the
      // future is not one.
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) onChanged(picked);
  }
}

/// Shows how the calorie target is calculated, and hands the result over to
/// the field above on request.
///
/// The steps are laid out rather than just the result: a target that appears
/// out of nowhere is one nobody can check, and the numbers behind it are what
/// tells the user which profile value to correct when it looks wrong.
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
            else if (calculation == null)
              Text(
                '${missing.length == 1 ? 'Dafür fehlt' : 'Dafür fehlen'} noch: '
                '${missing.join(', ')}.',
                style: theme.textTheme.bodyMedium,
              )
            else
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
        _Step(
          label: 'Gewicht vom ${_formatDate(weight.date)}',
          value: '${_decimal(weight.weightKg, 1)} kg',
        ),
      _Step(
        label: 'Grundumsatz (Mifflin-St Jeor)',
        value: _kcal(calculation.basalMetabolicRate.round()),
      ),
      _Step(
        label:
            'Aktivität (× ${_decimal(calculation.activityLevel.calorieFactor, 3)})',
        value: _kcal(calculation.totalEnergyExpenditure.round()),
      ),
      _Step(
        label:
            '${calculation.goal.label} '
            '(${_gramsPerWeek(calculation.goal.weeklyWeightChangeGrams)})',
        value: _signedKcal(calculation.goalAdjustment),
      ),
      const Divider(height: 24),
      _Step(
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

  /// A decimal number with a comma, the way it is written in German. Trailing
  /// zeros of a shorter number are dropped: 1,375 but 1,2 rather than 1,200.
  String _decimal(double value, int maxDecimals) {
    final text = value.toStringAsFixed(maxDecimals);
    // Only zeros behind the point go — the same pattern on a number without
    // one would eat the zeros of 100.
    final trimmed = text.contains('.')
        ? text.replaceFirst(RegExp(r'\.?0+$'), '')
        : text;
    return trimmed.replaceFirst('.', ',');
  }
}

/// One line of the calculation: what it is on the left, what it costs on the
/// right.
class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasised
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${date.year}';

extension on BiologicalSex {
  String get label => switch (this) {
    BiologicalSex.female => 'weiblich',
    BiologicalSex.male => 'männlich',
  };
}

extension on ActivityLevel {
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sitzend, kaum Bewegung',
    ActivityLevel.lightlyActive => 'Leicht aktiv, 1–2× Sport pro Woche',
    ActivityLevel.moderatelyActive => 'Mäßig aktiv, 3–4× Sport pro Woche',
    ActivityLevel.veryActive => 'Sehr aktiv, 5–6× Sport pro Woche',
    ActivityLevel.extraActive => 'Extrem aktiv, täglich hart oder körperlich',
  };
}

extension on WeightGoal {
  String get label => switch (this) {
    WeightGoal.lose => 'Abnehmen',
    WeightGoal.maintain => 'Gewicht halten',
    WeightGoal.gain => 'Zunehmen',
  };
}
