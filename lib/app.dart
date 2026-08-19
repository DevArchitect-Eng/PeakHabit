import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/logging/app_lifecycle_logger.dart';
import 'core/logging/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/settings/data/settings_providers.dart';
import 'features/settings/domain/app_theme_mode.dart';

class PeakHabitApp extends ConsumerWidget {
  const PeakHabitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(themeModeProvider);
    if (stored case AsyncError(:final error, :final stackTrace)) {
      // The app stays usable on the default, but silently forgetting the
      // user's choice should not also be invisible in the log.
      AppLogger.app.error('Reading the theme mode failed', error, stackTrace);
    }

    // Dark while the stored choice is still being read. `main` reads it before
    // the first frame, so in the running app this only covers the gap in tests
    // that pump the app directly.
    final themeMode = stored.value ?? AppThemeMode.dark;

    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    if (onboardingCompleted case AsyncError(:final error, :final stackTrace)) {
      AppLogger.app.error(
        'Reading the onboarding flag failed',
        error,
        stackTrace,
      );
    }
    // Falls back to "already done" rather than "not done yet", unlike the
    // theme above: `warmUp` reads this before the first frame just like the
    // theme, so the fallback only matters on a read that failed outright —
    // and re-running onboarding over an existing profile is worse than
    // occasionally skipping it once for a user who already finished it.
    final onboardingDone = onboardingCompleted.value ?? true;

    if (!onboardingDone) {
      return MaterialApp(
        title: 'PeakHabit',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _materialThemeMode(themeMode),
        home: const OnboardingScreen(),
        builder: (context, child) =>
            AppLifecycleLogger(child: child ?? const SizedBox.shrink()),
      );
    }

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

/// The stored choice translated for `MaterialApp`. The two enums exist side by
/// side so the names in the database do not depend on a framework type — see
/// [AppThemeMode].
ThemeMode _materialThemeMode(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};
