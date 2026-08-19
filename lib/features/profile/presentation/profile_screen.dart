import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../data/user_profile_providers.dart';
import '../domain/user_profile.dart';
import 'profile_formatting.dart';
import 'setting_row.dart';
import 'value_editor.dart';

const _logger = AppLogger('profile');

/// Edits the one user profile.
///
/// Reached from the settings tab, so the values entered during onboarding can
/// be corrected later. Only the body data is edited here — what the user is
/// working towards sits on the goals screen, and the calorie target with its
/// macro split below that: this screen answers who somebody is, those two
/// answer where they are going.
///
/// A row is edited by tapping it, and every change is written as soon as its
/// editor is confirmed. There is no save button to forget.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: switch (profile) {
        AsyncData(:final value) => _ProfileList(profile: value),
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

class _ProfileList extends ConsumerWidget {
  const _ProfileList({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthDate = profile.birthDate;

    return ListView(
      children: [
        SettingRow(
          label: 'Benutzername',
          value: profile.username.isEmpty ? 'Keine Angabe' : profile.username,
          onTap: () => _editUsername(context, ref),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Größe',
          value: profile.heightCm == null
              ? 'Keine Angabe'
              : '${profile.heightCm} cm',
          onTap: () => _editHeight(context, ref),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Geschlecht',
          value: profile.sex?.label ?? 'Keine Angabe',
          onTap: () => _editSex(context, ref),
        ),
        const Divider(height: 1),
        SettingRow(
          label: 'Geburtsdatum',
          value: birthDate == null ? 'Keine Angabe' : formatDate(birthDate),
          onTap: () => _editBirthDate(context, ref),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _editUsername(BuildContext context, WidgetRef ref) async {
    final entered = await showTextEditor(
      context,
      title: 'Benutzername',
      initialValue: profile.username,
      // Unlike the fields below, empty is not allowed: the greeting on the
      // home screen needs an actual name to show.
      validate: (value) =>
          value.trim().isEmpty ? 'Bitte einen Benutzernamen eingeben.' : null,
    );
    if (entered == null || !context.mounted) return;

    await _save(context, ref, profile.copyWith(username: entered.trim()));
  }

  Future<void> _editHeight(BuildContext context, WidgetRef ref) async {
    final entered = await showTextEditor(
      context,
      title: 'Größe',
      initialValue: profile.heightCm?.toString() ?? '',
      suffix: 'cm',
      digitsOnly: true,
      // Empty means "not filled in yet" and stays allowed; anything else has
      // to be a number the domain model would accept.
      validate: (value) =>
          value.trim().isEmpty || _positiveOrNull(value) != null
          ? null
          : 'Die Größe muss größer als 0 sein.',
    );
    if (entered == null || !context.mounted) return;

    await _save(
      context,
      ref,
      profile.copyWith(heightCm: _positiveOrNull(entered)),
    );
  }

  Future<void> _editSex(BuildContext context, WidgetRef ref) async {
    final chosen = await showChoiceEditor<BiologicalSex>(
      context,
      title: 'Geschlecht',
      value: profile.sex,
      options: BiologicalSex.values,
      labelOf: (sex) => sex.label,
      noneLabel: 'Keine Angabe',
    );
    if (chosen == null || !context.mounted) return;

    await _save(context, ref, profile.copyWith(sex: chosen.value));
  }

  Future<void> _editBirthDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    // The platform picker confirms and cancels on its own, which is the same
    // bargain the editors above strike.
    final picked = await showDatePicker(
      context: context,
      initialDate:
          profile.birthDate ?? DateTime(now.year - 30, now.month, now.day),
      // Nobody using this app was born before 1900, and a birth date in the
      // future is not one.
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !context.mounted) return;

    await _save(context, ref, profile.copyWith(birthDate: picked));
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
      _logger.error('Saving the profile failed', error, stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das Profil konnte nicht gespeichert werden.'),
        ),
      );
    }
  }
}
