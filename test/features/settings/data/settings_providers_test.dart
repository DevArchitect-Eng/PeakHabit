import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';
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
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('hands out a repository on the app database', () async {
    final repository = container.read(settingsRepositoryProvider);

    await repository.saveThemeMode(AppThemeMode.light);

    final rows = await database.select(database.appSettings).get();
    expect(rows.single.themeMode, AppThemeMode.light);
  });

  test('the theme mode provider follows what the repository saves', () async {
    final subscription = container.listen(
      themeModeProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(themeModeProvider.future), AppThemeMode.dark);

    await container
        .read(settingsRepositoryProvider)
        .saveThemeMode(AppThemeMode.light);
    await pumpEventQueue();

    expect(container.read(themeModeProvider).value, AppThemeMode.light);
  });
}
