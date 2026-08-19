import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
import '../data/settings_providers.dart';
import '../domain/app_theme_mode.dart';

const _logger = AppLogger('settings');

/// The settings tab.
///
/// Laid out as titled sections so later settings — units, notifications — are
/// added as another [_SettingsSection] instead of growing one long flat list.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: const [
          _SettingsSection(
            title: 'Darstellung',
            children: [_ThemeModeSetting()],
          ),
          _SettingsSection(
            title: 'Persönliches',
            children: [_ProfileTile(), _GoalsTile()],
          ),
        ],
      ),
    );
  }
}

/// A titled group of settings.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Way into the profile, so the onboarding values can be corrected later.
class _ProfileTile extends StatelessWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: const Text('Profil bearbeiten'),
      subtitle: const Text('Größe, Geschlecht und Kalorienziel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/settings/profile'),
    );
  }
}

/// Way into the goals, which are edited apart from the profile they used to
/// sit in.
class _GoalsTile extends StatelessWidget {
  const _GoalsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: const Text('Ziele'),
      subtitle: const Text('Gewichtsziel und Aktivitätslevel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/settings/goals'),
    );
  }
}

/// Dark, light or whatever the system asks for.
class _ThemeModeSetting extends ConsumerWidget {
  const _ThemeModeSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? AppThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<AppThemeMode>(
        segments: const [
          ButtonSegment(value: AppThemeMode.system, label: Text('System')),
          ButtonSegment(value: AppThemeMode.light, label: Text('Hell')),
          ButtonSegment(value: AppThemeMode.dark, label: Text('Dunkel')),
        ],
        selected: {mode},
        // Nothing is kept in widget state: the write goes to the database and
        // comes back through the provider, which is what repaints the app.
        onSelectionChanged: (selection) =>
            _save(context, ref, selection.single),
      ),
    );
  }

  /// A failed write would otherwise be invisible: the button snaps back to the
  /// old choice, because only the stored value drives what is selected.
  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
  ) async {
    try {
      await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
    } catch (error, stackTrace) {
      _logger.error('Saving the theme mode failed', error, stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Die Auswahl konnte nicht gespeichert werden.'),
        ),
      );
    }
  }
}
