import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/app.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';

import 'in_memory_settings_repository.dart';

/// Starts the whole app and waits until it is idle.
///
/// The settings come from an [InMemorySettingsRepository] rather than from the
/// real database — see there for why a widget test cannot use the real one.
///
/// Passing a [settings] back in starts the app on values that are already
/// stored, which is as close to a restart as a widget test gets.
Future<InMemorySettingsRepository> pumpApp(
  WidgetTester tester, {
  InMemorySettingsRepository? settings,
}) async {
  final repository = settings ?? InMemorySettingsRepository();
  if (settings == null) addTearDown(repository.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
      child: const PeakHabitApp(),
    ),
  );
  await tester.pumpAndSettle();

  return repository;
}
