import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../data/user_profile_providers.dart';
import '../domain/user_profile.dart';
import 'profile_formatting.dart';

const _logger = AppLogger('profile');

/// Edits the one user profile.
///
/// Reached from the settings tab, so the values entered during onboarding can
/// be corrected later. Only the body data is edited here — what the user is
/// working towards sits on the goals screen, and the calorie target with its
/// macro split below that: this screen answers who somebody is, those two
/// answer where they are going.
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

  late BiologicalSex? _sex = widget.profile.sex;
  late DateTime? _birthDate = widget.profile.birthDate;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _heightController = TextEditingController(
      text: widget.profile.heightCm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  /// The profile as the form currently stands — what a save would write.
  ///
  /// Built from the stored profile, so everything this screen does not edit —
  /// the goal, the activity level, the macro split — is carried over as it
  /// stands instead of being rebuilt field by field.
  ///
  /// A value the form would reject counts as not filled in: the domain model
  /// would throw on a `0` in the height field. Saving never gets here with
  /// such a value, the validator stops it first.
  UserProfile _draftProfile() => widget.profile.copyWith(
    username: _usernameController.text.trim(),
    heightCm: _positiveOrNull(_heightController.text),
    sex: _sex,
    birthDate: _birthDate,
  );

  int? _positiveOrNull(String text) {
    final number = int.tryParse(text);
    return number != null && number > 0 ? number : null;
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
        child: Text(value == null ? 'Keine Angabe' : formatDate(value)),
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
