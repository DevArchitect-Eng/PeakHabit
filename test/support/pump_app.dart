import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/app.dart';
import 'package:peakhabit/core/router/app_router.dart';
import 'package:peakhabit/features/profile/data/user_profile_providers.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';

import 'in_memory_settings_repository.dart';
import 'in_memory_user_profile_repository.dart';

/// The stores the app under test runs on, so a test can seed them beforehand
/// or check them afterwards.
typedef AppStores = ({
  InMemorySettingsRepository settings,
  InMemoryUserProfileRepository profile,
});

/// Stores with nothing in them yet, closed again when the test ends.
AppStores emptyStores() {
  final stores = (
    settings: InMemorySettingsRepository(),
    profile: InMemoryUserProfileRepository(),
  );
  addTearDown(stores.settings.dispose);
  addTearDown(stores.profile.dispose);
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
  final stores = on ?? emptyStores();
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
      ],
      child: const PeakHabitApp(),
    ),
  );
  await tester.pumpAndSettle();

  return stores;
}
