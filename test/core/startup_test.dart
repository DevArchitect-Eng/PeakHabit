import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/core/startup.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';
import 'package:peakhabit/features/settings/data/settings_repository.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
  });

  // Guards the app against starting on a blank screen: `warmUp` waits for the
  // theme, and that wait only ends if the provider was started first.
  test('finishes instead of waiting forever', () async {
    await warmUp(container);
  });

  test('leaves the stored theme ready for the first frame', () async {
    await SettingsRepository(database).saveThemeMode(AppThemeMode.light);

    await warmUp(container);

    expect(container.read(themeModeProvider).value, AppThemeMode.light);
  });

  test('falls back to dark when nothing was stored yet', () async {
    await warmUp(container);

    expect(container.read(themeModeProvider).value, AppThemeMode.dark);
  });
}
