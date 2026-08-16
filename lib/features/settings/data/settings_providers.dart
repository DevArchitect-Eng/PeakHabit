import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/app_theme_mode.dart';
import 'settings_repository.dart';

/// Access to the stored settings. Widgets that only write go through this one.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// The current theme mode, re-emitted whenever it is saved.
final themeModeProvider = StreamProvider<AppThemeMode>(
  (ref) => ref.watch(settingsRepositoryProvider).watchThemeMode(),
);
