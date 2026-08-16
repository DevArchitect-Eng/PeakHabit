import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/settings_providers.dart';
import '../domain/app_theme_mode.dart';

/// The settings tab.
///
/// Laid out as titled sections so later settings — units, notifications — are
/// added as another [SettingsSection] instead of growing one long flat list.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: const [
          SettingsSection(
            title: 'Darstellung',
            children: [_ThemeModeSetting()],
          ),
          SettingsSection(title: 'Persönliches', children: [_ProfileTile()]),
        ],
      ),
    );
  }
}

/// A titled group of settings.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

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
      subtitle: const Text('Größe, Geschlecht, Ziel und Kalorienziel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/settings/profile'),
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
        onSelectionChanged: (selection) {
          ref.read(settingsRepositoryProvider).saveThemeMode(selection.single);
        },
      ),
    );
  }
}
