import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/profile/data/user_profile_repository.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/settings/data/settings_repository.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

void main() {
  setUp(() {
    AppLogger.output = (_) {};
  });

  test('opens an in-memory database and closes it again', () async {
    final database = AppDatabase.inMemory();

    await database.open();
    await database.close();
  });

  test('logs opening, schema creation and closing', () async {
    final captured = <LogEntry>[];
    AppLogger.output = captured.add;
    final database = AppDatabase.inMemory();

    await database.open();
    await database.close();

    expect(captured.every((entry) => entry.component == 'database'), isTrue);
    final messages = captured.map((entry) => entry.message).toList();
    expect(messages, [
      'Opening database',
      'Creating schema at version 8',
      'Database opened',
      'Closing database',
      'Database closed',
    ]);
  });

  test('creates a fresh database at schema version 8', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    // Pinned to the literal version on purpose: raising `schemaVersion` should
    // force a look at this test, and with it at the matching migration step.
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 8);
  });

  test('enforces foreign keys', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('carries the feature tables', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    expect(
      database.allTables.map((table) => table.actualTableName),
      containsAll(['user_profiles', 'app_settings', 'body_weight_entries']),
    );
  });

  group('migration', () {
    late Directory directory;
    late File file;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('peakhabit_test');
      file = File(p.join(directory.path, 'peakhabit.sqlite'));
    });

    tearDown(() => directory.delete(recursive: true));

    /// Rewinds a fresh database to what an older installation left behind:
    /// the plumbing, minus the tables that only came later.
    Future<void> rewindTo(int version, List<String> droppedTables) async {
      final legacy = AppDatabase.atFile(file);
      await legacy.open();
      for (final table in droppedTables) {
        await legacy.customStatement('DROP TABLE $table');
      }
      // `user_profiles` gained `username` in version 6 — a table that
      // survives the rewind still has it fresh from `legacy.open()` above,
      // which would make the addColumn migration see a column that is
      // already there.
      if (version < 6 && !droppedTables.contains('user_profiles')) {
        await legacy.customStatement(
          'ALTER TABLE user_profiles DROP COLUMN username',
        );
      }
      // Same reasoning for `app_settings.onboarding_completed`, added in
      // version 7.
      if (version < 7 && !droppedTables.contains('app_settings')) {
        await legacy.customStatement(
          'ALTER TABLE app_settings DROP COLUMN onboarding_completed',
        );
      }
      await legacy.customStatement('PRAGMA user_version = $version');
      await legacy.close();
    }

    Future<List<String>> tablesAfterOpening() async {
      final migrated = AppDatabase.atFile(file);
      addTearDown(migrated.close);
      await migrated.open();

      final rows = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      return rows.map((row) => row.read<String>('name')).toList();
    }

    test('brings an installation on version 1 up to date', () async {
      await rewindTo(1, [
        'user_profiles',
        'app_settings',
        'body_weight_entries',
      ]);

      expect(
        await tablesAfterOpening(),
        containsAll(['user_profiles', 'app_settings', 'body_weight_entries']),
      );
    });

    test('adds the settings table to an installation on version 2', () async {
      await rewindTo(2, ['app_settings', 'body_weight_entries']);

      expect(await tablesAfterOpening(), contains('app_settings'));
    });

    test('adds the weight table to an installation on version 3', () async {
      await rewindTo(3, ['body_weight_entries']);

      expect(await tablesAfterOpening(), contains('body_weight_entries'));
    });

    test('clears a stored sex the enum no longer has', () async {
      final legacy = AppDatabase.atFile(file);
      await legacy.open();
      // Written as raw SQL because `BiologicalSex.diverse` is gone — there is
      // no longer a companion that could produce this row.
      await legacy.customStatement(
        'INSERT INTO user_profiles (id, sex, goal, protein_percent, '
        'carb_percent, fat_percent, updated_at) '
        "VALUES (1, 'diverse', 'maintain', 30, 40, 30, 0)",
      );
      // Version 4 predates the `username` column added in version 6, and the
      // `onboarding_completed` one added in version 7 — see `rewindTo` above
      // for why these have to be stripped back off.
      await legacy.customStatement(
        'ALTER TABLE user_profiles DROP COLUMN username',
      );
      await legacy.customStatement(
        'ALTER TABLE app_settings DROP COLUMN onboarding_completed',
      );
      await legacy.customStatement('PRAGMA user_version = 4');
      await legacy.close();

      final migrated = AppDatabase.atFile(file);
      addTearDown(migrated.close);
      await migrated.open();

      final profile = await UserProfileRepository(migrated).read();
      expect(profile.sex, isNull);
      // The rest of the row survives the migration untouched.
      expect(profile.goal, WeightGoal.maintain);
    });

    test('adds the username column to an installation on version 5', () async {
      final legacy = AppDatabase.atFile(file);
      await legacy.open();
      await legacy.customStatement(
        'INSERT INTO user_profiles (id, goal, protein_percent, '
        'carb_percent, fat_percent, updated_at) '
        "VALUES (1, 'maintain', 30, 40, 30, 0)",
      );
      // Simulates version 5, which had the table but not yet the column —
      // `DROP COLUMN` stands in for a schema that never had it, since the
      // fresh database above starts on the current one. Same reasoning for
      // `onboarding_completed`, added later still, in version 7.
      await legacy.customStatement(
        'ALTER TABLE user_profiles DROP COLUMN username',
      );
      await legacy.customStatement(
        'ALTER TABLE app_settings DROP COLUMN onboarding_completed',
      );
      await legacy.customStatement('PRAGMA user_version = 5');
      await legacy.close();

      final migrated = AppDatabase.atFile(file);
      addTearDown(migrated.close);
      await migrated.open();

      final profile = await UserProfileRepository(migrated).read();
      expect(profile.username, '');
      // The rest of the row survives the migration untouched.
      expect(profile.goal, WeightGoal.maintain);
    });

    test(
      'adds the onboarding-completed column to an installation on version 6',
      () async {
        final legacy = AppDatabase.atFile(file);
        await legacy.open();
        await legacy.customStatement(
          "INSERT INTO app_settings (id, theme_mode, updated_at) "
          "VALUES (1, 'dark', 0)",
        );
        // Simulates version 6, which had the table but not yet the column.
        await legacy.customStatement(
          'ALTER TABLE app_settings DROP COLUMN onboarding_completed',
        );
        await legacy.customStatement('PRAGMA user_version = 6');
        await legacy.close();

        final migrated = AppDatabase.atFile(file);
        addTearDown(migrated.close);
        await migrated.open();

        final repository = SettingsRepository(migrated);
        expect(await repository.readOnboardingCompleted(), isFalse);
        // The rest of the row survives the migration untouched.
        expect(await repository.readThemeMode(), AppThemeMode.dark);
      },
    );

    /// Stores [goal] the way version 7 held it and opens the database again.
    ///
    /// Raw SQL because the three old names are gone from `WeightGoal` — there
    /// is no companion left that could write such a row.
    Future<UserProfile> profileAfterMigratingGoal(String goal) async {
      final legacy = AppDatabase.atFile(file);
      await legacy.open();
      await legacy.customStatement(
        'INSERT INTO user_profiles (id, username, goal, protein_percent, '
        'carb_percent, fat_percent, updated_at) '
        "VALUES (1, 'mila', '$goal', 30, 40, 30, 0)",
      );
      await legacy.customStatement('PRAGMA user_version = 7');
      await legacy.close();

      final migrated = AppDatabase.atFile(file);
      addTearDown(migrated.close);
      await migrated.open();
      return UserProfileRepository(migrated).read();
    }

    test('puts a stored "lose" on the rate it used to stand for', () async {
      final profile = await profileAfterMigratingGoal('lose');

      expect(profile.goal, WeightGoal.lose500);
      // The rest of the row survives the migration untouched.
      expect(profile.username, 'mila');
    });

    test('puts a stored "gain" on the rate it used to stand for', () async {
      final profile = await profileAfterMigratingGoal('gain');

      expect(profile.goal, WeightGoal.gain200);
    });

    test('leaves a stored "maintain" where it is', () async {
      // The one old name the new enum still has — the migration must not go
      // looking for something to rewrite it to.
      final profile = await profileAfterMigratingGoal('maintain');

      expect(profile.goal, WeightGoal.maintain);
    });
  });
}
