import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../body_weight/data/body_weight_providers.dart';
import '../../body_weight/domain/body_weight_entry.dart';
import '../../profile/data/user_profile_providers.dart';
import '../../profile/domain/calorie_calculation.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/goal_warning.dart';
import '../../profile/presentation/profile_formatting.dart';
import '../../settings/data/settings_providers.dart';

const _logger = AppLogger('onboarding');

enum _Step { welcome, username, goal, height, weight, calorieTarget }

enum _CalorieChoice { manual, calculate }

/// First-start onboarding: username, goal, height, weight and calorie target,
/// so the app starts already usable instead of empty.
///
/// Shown by [PeakHabitApp] itself in place of the routed app, not as a route
/// of its own — there is nothing to navigate back to before it has run.
/// Every step is mandatory: there is no button to skip a step or the flow as
/// a whole, because the entire point is to get the values the rest of the
/// app depends on into the database. "Weiter" stays disabled until the
/// current step holds a value the domain model would accept, and the flow
/// only ends by completing the last step.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = _Step.values;

  int _stepIndex = 0;
  bool _saving = false;
  String? _error;

  final _usernameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _calorieController = TextEditingController();

  WeightGoal? _goal;
  _CalorieChoice? _calorieChoice;
  BiologicalSex? _sex;
  DateTime? _birthDate;
  ActivityLevel? _activityLevel;

  @override
  void dispose() {
    _usernameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  _Step get _step => _steps[_stepIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Willkommen bei PeakHabit'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_stepIndex + 1) / _steps.length,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildStep(),
            if (_error case final error?) ...[
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A plain `FilledButton` here, not wrapped in `Expanded` inside a
            // `Row`: the theme sizes it to the full width via
            // `Size.fromHeight`, which needs a bounded width to resolve
            // against — a `Row`'s loose constraints leave it infinite.
            FilledButton(
              onPressed: _saving || !_canContinue ? null : _continue,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_step == _Step.calorieTarget ? 'Fertig' : 'Weiter'),
            ),
            if (_stepIndex > 0)
              TextButton(
                onPressed: _saving ? null : _back,
                child: const Text('Zurück'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    _Step.welcome => const _WelcomeStep(),
    _Step.username => TextField(
      controller: _usernameController,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Benutzername'),
      onChanged: (_) => setState(() {}),
    ),
    _Step.goal => _ChoiceList<WeightGoal>(
      title: 'Was ist dein Ziel?',
      value: _goal,
      options: WeightGoal.values,
      labelOf: (goal) => goal.label,
      onChanged: _pickGoal,
    ),
    _Step.height => TextField(
      controller: _heightController,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Größe', suffixText: 'cm'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
    ),
    _Step.weight => TextField(
      controller: _weightController,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Aktuelles Gewicht',
        suffixText: 'kg',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      onChanged: (_) => setState(() {}),
    ),
    _Step.calorieTarget => _CalorieTargetStep(
      choice: _calorieChoice,
      onChoiceChanged: (value) => setState(() => _calorieChoice = value),
      calorieController: _calorieController,
      onCalorieChanged: () => setState(() {}),
      sex: _sex,
      onSexChanged: (value) => setState(() => _sex = value),
      birthDate: _birthDate,
      onBirthDateChanged: (value) => setState(() => _birthDate = value),
      activityLevel: _activityLevel,
      onActivityLevelChanged: (value) => setState(() => _activityLevel = value),
      calculation: _calculation,
    ),
  };

  bool get _canContinue => switch (_step) {
    _Step.welcome => true,
    _Step.username => _usernameController.text.trim().isNotEmpty,
    _Step.goal => _goal != null,
    _Step.height => _positiveInt(_heightController.text) != null,
    _Step.weight => _positiveDouble(_weightController.text) != null,
    _Step.calorieTarget => switch (_calorieChoice) {
      null => false,
      _CalorieChoice.manual => _positiveInt(_calorieController.text) != null,
      // Not just "there is a calculation": body data that is off by enough —
      // a height typed as 1 rather than 170, say — puts the result at or
      // below zero, and the profile refuses such a target. Letting it through
      // here would throw on the way out of a flow nobody can skip.
      _CalorieChoice.calculate => _calculatedTarget != null,
    },
  };

  /// Takes the picked rate, and says so where it is one of the hard ones.
  ///
  /// Warned about at the pick rather than at the end of the flow: this is the
  /// moment the user is still weighing the rates against each other, and by
  /// the last step they have moved on to the calorie target.
  void _pickGoal(WeightGoal goal) {
    setState(() => _goal = goal);
    unawaited(showGoalWarnings(context, goalWarnings(goal: goal)));
  }

  /// The calculated target, but only when it is one the profile would accept.
  int? get _calculatedTarget {
    final target = _calculation?.calorieTarget;
    return target != null && target > 0 ? target : null;
  }

  /// The calculation from the values entered so far — body weight and height
  /// are not saved yet at this point, so they are passed in directly rather
  /// than read back from a repository.
  CalorieCalculation? get _calculation {
    final sex = _sex;
    final birthDate = _birthDate;
    final activityLevel = _activityLevel;
    final goal = _goal;
    final heightCm = _positiveInt(_heightController.text);
    final weightKg = _positiveDouble(_weightController.text);
    if (sex == null ||
        birthDate == null ||
        activityLevel == null ||
        goal == null ||
        heightCm == null ||
        weightKg == null) {
      return null;
    }

    return CalorieCalculation.forProfile(
      UserProfile(
        heightCm: heightCm,
        sex: sex,
        birthDate: birthDate,
        activityLevel: activityLevel,
        goal: goal,
      ),
      weightKg: weightKg,
      today: DateTime.now(),
    );
  }

  int? _positiveInt(String text) {
    final number = int.tryParse(text.trim());
    return number != null && number > 0 ? number : null;
  }

  double? _positiveDouble(String text) {
    final number = double.tryParse(text.trim().replaceAll(',', '.'));
    return number != null && number.isFinite && number > 0 ? number : null;
  }

  void _back() => setState(() => _stepIndex--);

  void _continue() {
    if (_step == _Step.calorieTarget) {
      unawaited(_finish());
    } else {
      setState(() => _stepIndex++);
    }
  }

  Future<void> _finish() async {
    final heightCm = _positiveInt(_heightController.text);
    final weightKg = _positiveDouble(_weightController.text);
    final goal = _goal;
    final calorieTarget = switch (_calorieChoice) {
      _CalorieChoice.manual => _positiveInt(_calorieController.text),
      _CalorieChoice.calculate => _calculatedTarget,
      null => null,
    };
    // The button that reaches here is disabled unless `_canContinue` already
    // confirmed all of this holds a value.
    if (heightCm == null ||
        weightKg == null ||
        goal == null ||
        calorieTarget == null) {
      return;
    }

    final calculating = _calorieChoice == _CalorieChoice.calculate;

    // Said before the write, not after: the moment the profile lands,
    // `PeakHabitApp` swaps this screen out for the routed app, and a dialog
    // put up afterwards would belong to a screen that is already gone. Only
    // the floor can fire here — the rate had its say back on its own step.
    //
    // Only while the app is the one calculating: the body data behind
    // `_calculation` survives a switch back to a hand-typed target, and
    // warning about a number nothing stores would point at a target the user
    // never asked for.
    await showGoalWarnings(
      context,
      goalWarnings(calculation: calculating ? _calculation : null),
    );
    if (!mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Built inside the try on purpose: both constructors validate and throw
      // on a value they will not take. Outside it, that throw would leave the
      // flow through `unawaited(_finish())` — unlogged, without a message, and
      // with the button still live, so the screen would simply stop reacting.
      final profile = UserProfile(
        username: _usernameController.text.trim(),
        heightCm: heightCm,
        sex: calculating ? _sex : null,
        birthDate: calculating ? _birthDate : null,
        activityLevel: calculating ? _activityLevel : null,
        goal: goal,
        calorieTarget: calorieTarget,
      );
      final weightEntry = BodyWeightEntry(
        date: DateTime.now(),
        weightKg: weightKg,
      );

      await ref.read(userProfileRepositoryProvider).save(profile);
      await ref.read(bodyWeightRepositoryProvider).save(weightEntry);
      await ref.read(settingsRepositoryProvider).saveOnboardingCompleted();
    } catch (error, stackTrace) {
      _logger.error('Completing onboarding failed', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Das hat nicht geklappt. Bitte erneut versuchen.';
      });
      return;
    }
    // No navigation here: `PeakHabitApp` watches the onboarding flag and
    // swaps this screen out for the routed app on its own once the save
    // above lands.
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kurz einrichten', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text(
            'Ein paar Angaben, dann ist PeakHabit sofort nutzbar: Ziel, '
            'Größe, aktuelles Gewicht und ein Kalorienziel. Das dauert nur '
            'eine Minute und lässt sich später jederzeit in den Optionen '
            'anpassen.',
          ),
        ],
      ),
    );
  }
}

/// A single-choice list used for the goal, the biological sex and whether the
/// calorie target is entered or calculated — every place in this flow that
/// needs an explicit choice out of a handful of options.
class _ChoiceList<T> extends StatelessWidget {
  const _ChoiceList({
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final String title;
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        RadioGroup<T>(
          groupValue: value,
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
          child: Column(
            children: [
              for (final option in options)
                RadioListTile<T>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(labelOf(option)),
                  value: option,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The last step: either a known calorie target, entered directly, or enough
/// to calculate one — which needs the sex, birth date and activity level
/// [CalorieCalculation] depends on, and which nothing earlier in the flow
/// asked for.
class _CalorieTargetStep extends StatelessWidget {
  const _CalorieTargetStep({
    required this.choice,
    required this.onChoiceChanged,
    required this.calorieController,
    required this.onCalorieChanged,
    required this.sex,
    required this.onSexChanged,
    required this.birthDate,
    required this.onBirthDateChanged,
    required this.activityLevel,
    required this.onActivityLevelChanged,
    required this.calculation,
  });

  final _CalorieChoice? choice;
  final ValueChanged<_CalorieChoice> onChoiceChanged;
  final TextEditingController calorieController;
  final VoidCallback onCalorieChanged;
  final BiologicalSex? sex;
  final ValueChanged<BiologicalSex> onSexChanged;
  final DateTime? birthDate;
  final ValueChanged<DateTime> onBirthDateChanged;
  final ActivityLevel? activityLevel;
  final ValueChanged<ActivityLevel> onActivityLevelChanged;
  final CalorieCalculation? calculation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChoiceList<_CalorieChoice>(
          title: 'Kennst du dein tägliches Kalorienziel?',
          value: choice,
          options: _CalorieChoice.values,
          labelOf: (value) => switch (value) {
            _CalorieChoice.manual => 'Ja, ich gebe es ein',
            _CalorieChoice.calculate => 'Nein, für mich berechnen',
          },
          onChanged: onChoiceChanged,
        ),
        const SizedBox(height: 8),
        switch (choice) {
          null => const SizedBox.shrink(),
          _CalorieChoice.manual => TextField(
            controller: calorieController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Kalorienziel',
              suffixText: 'kcal',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => onCalorieChanged(),
          ),
          _CalorieChoice.calculate => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChoiceList<BiologicalSex>(
                title: 'Geschlecht',
                value: sex,
                options: BiologicalSex.values,
                labelOf: (value) => value.label,
                onChanged: onSexChanged,
              ),
              const SizedBox(height: 8),
              _BirthDateField(value: birthDate, onChanged: onBirthDateChanged),
              const SizedBox(height: 16),
              _ChoiceList<ActivityLevel>(
                title: 'Aktivitätslevel',
                value: activityLevel,
                options: ActivityLevel.values,
                labelOf: (value) => value.label,
                onChanged: onActivityLevelChanged,
              ),
              if (calculation case final calculation?) ...[
                const SizedBox(height: 16),
                // A result at or below zero means the body data cannot be
                // right — without saying so, "Fertig" would just sit there
                // greyed out and the user would have nothing to go on.
                if (calculation.calorieTarget > 0)
                  _CalculatedTargetCard(calculation: calculation)
                else
                  Text(
                    'Daraus lässt sich kein sinnvolles Kalorienziel '
                    'berechnen. Bitte Größe, Gewicht und Geburtsdatum '
                    'prüfen — oder das Ziel selbst eingeben.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ],
          ),
        },
      ],
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Geburtsdatum'),
        child: Text(value == null ? 'Auswählen' : formatDate(value)),
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

class _CalculatedTargetCard extends StatelessWidget {
  const _CalculatedTargetCard({required this.calculation});

  final CalorieCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Berechnetes Kalorienziel',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${calculation.calorieTarget} kcal',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
