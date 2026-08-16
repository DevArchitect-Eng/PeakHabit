import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/logging/app_lifecycle_logger.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/data/settings_providers.dart';
import 'features/settings/domain/app_theme_mode.dart';

class PeakHabitApp extends ConsumerWidget {
  const PeakHabitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dark while the stored choice is still being read. `main` reads it before
    // the first frame, so in the running app this only covers the gap in tests
    // that pump the app directly.
    final themeMode = ref.watch(themeModeProvider).value ?? AppThemeMode.dark;

    return MaterialApp.router(
      title: 'PeakHabit',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _materialThemeMode(themeMode),
      routerConfig: appRouter,
      builder: (context, child) =>
          AppLifecycleLogger(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// The stored choice translated for `MaterialApp`. Keeping our own enum out of
/// the database's reach from Flutter's is the point of the two existing side
/// by side — see [AppThemeMode].
ThemeMode _materialThemeMode(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};
