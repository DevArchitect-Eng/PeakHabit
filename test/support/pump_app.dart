import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/app.dart';
import 'package:peakhabit/core/router/app_router.dart';
import 'package:peakhabit/features/body_weight/data/body_weight_providers.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/profile/data/user_profile_providers.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

import 'in_memory_body_weight_repository.dart';
import 'in_memory_settings_repository.dart';
import 'in_memory_user_profile_repository.dart';

/// The stores the app under test runs on, so a test can seed them beforehand
/// or check them afterwards.
typedef AppStores = ({
  InMemorySettingsRepository settings,
  InMemoryUserProfileRepository profile,
  InMemoryBodyWeightRepository bodyWeight,
});

/// Stores holding what a test wants to find there, closed again when the test
/// ends. Left empty they hold the same defaults a fresh install would.
AppStores storesWith({
  AppThemeMode? themeMode,
  bool onboardingCompleted = true,
  UserProfile? profile,
  bool profileUnwritable = false,
  List<BodyWeightEntry> weightEntries = const [],
  bool weightEntriesUnreadable = false,
}) {
  final stores = (
    settings: InMemorySettingsRepository(
      themeMode ?? AppThemeMode.dark,
      onboardingCompleted,
    ),
    profile: InMemoryUserProfileRepository(
      profile ?? UserProfile.empty,
      profileUnwritable,
    ),
    bodyWeight: InMemoryBodyWeightRepository(
      entries: weightEntries,
      failing: weightEntriesUnreadable,
    ),
  );
  addTearDown(stores.settings.dispose);
  addTearDown(stores.profile.dispose);
  addTearDown(stores.bodyWeight.dispose);
  return stores;
}

/// Starts the whole app and waits until it is idle.
///
/// The repositories are in-memory rather than the real database — see
/// [InMemorySettingsRepository] for why a widget test cannot use the real one.
///
/// Passing [on] back in starts the app on values that are already stored,
/// which is as close to a restart as a widget test gets.
Future<AppStores> pumpApp(WidgetTester tester, {AppStores? on}) async {
  final stores = on ?? storesWith();
  // The router is one global object shared by every test in a file, so without
  // this a test would start wherever the previous one happened to stop.
  appRouter.go('/home');
  // Taller than the 600 pixels a test window brings by default: a form that
  // reaches past the fold puts its buttons under the navigation bar, where a
  // tap lands on the wrong widget.
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(stores.settings),
        userProfileRepositoryProvider.overrideWithValue(stores.profile),
        bodyWeightRepositoryProvider.overrideWithValue(stores.bodyWeight),
      ],
      child: const PeakHabitApp(),
    ),
  );
  await tester.pumpAndSettle();

  return stores;
}
