import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/settings/data/settings_repository.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    repository = SettingsRepository(database);
  });

  tearDown(() => database.close());

  group('readThemeMode', () {
    test('reports dark before anything was saved', () async {
      expect(await repository.readThemeMode(), AppThemeMode.dark);
    });

    test('gives back what was saved', () async {
      await repository.saveThemeMode(AppThemeMode.light);

      expect(await repository.readThemeMode(), AppThemeMode.light);
    });
  });

  group('saveThemeMode', () {
    test('creates the row on the first call', () async {
      await repository.saveThemeMode(AppThemeMode.system);

      final rows = await database.select(database.appSettings).get();
      expect(rows, hasLength(1));
    });

    test('changes the existing row instead of adding a second', () async {
      await repository.saveThemeMode(AppThemeMode.light);

      await repository.saveThemeMode(AppThemeMode.system);

      final rows = await database.select(database.appSettings).get();
      expect(rows, hasLength(1));
      expect(await repository.readThemeMode(), AppThemeMode.system);
    });
  });

  group('watchThemeMode', () {
    test('emits the default and then every change', () async {
      final seen = <AppThemeMode>[];
      final subscription = repository.watchThemeMode().listen(seen.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.saveThemeMode(AppThemeMode.light);
      await pumpEventQueue();

      expect(seen, [AppThemeMode.dark, AppThemeMode.light]);
    });
  });

  test('refuses a second settings row', () {
    expect(
      () => database.customStatement(
        "INSERT INTO app_settings (id, theme_mode, updated_at) "
        "VALUES (2, 'light', 0)",
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          allOf(contains('CHECK constraint failed'), contains('id')),
        ),
      ),
    );
  });

  group('readOnboardingCompleted', () {
    test('reports false before anything was saved', () async {
      expect(await repository.readOnboardingCompleted(), isFalse);
    });

    test('gives back true once saved', () async {
      await repository.saveOnboardingCompleted();

      expect(await repository.readOnboardingCompleted(), isTrue);
    });
  });

  test('saveOnboardingCompleted does not change the theme mode', () async {
    await repository.saveThemeMode(AppThemeMode.light);

    await repository.saveOnboardingCompleted();

    expect(await repository.readThemeMode(), AppThemeMode.light);
  });

  test('saveThemeMode does not reset the onboarding flag', () async {
    await repository.saveOnboardingCompleted();

    await repository.saveThemeMode(AppThemeMode.light);

    expect(await repository.readOnboardingCompleted(), isTrue);
  });

  group('watchOnboardingCompleted', () {
    test('emits the default and then every change', () async {
      final seen = <bool>[];
      final subscription = repository.watchOnboardingCompleted().listen(
        seen.add,
      );
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.saveOnboardingCompleted();
      await pumpEventQueue();

      expect(seen, [false, true]);
    });
  });

  test('the choice survives a restart of the app', () async {
    final directory = await Directory.systemTemp.createTemp('peakhabit_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'peakhabit.sqlite'));

    final firstRun = AppDatabase.atFile(file);
    await firstRun.open();
    await SettingsRepository(firstRun).saveThemeMode(AppThemeMode.light);
    await firstRun.close();

    final secondRun = AppDatabase.atFile(file);
    addTearDown(secondRun.close);
    await secondRun.open();

    expect(
      await SettingsRepository(secondRun).readThemeMode(),
      AppThemeMode.light,
    );
  });
}
