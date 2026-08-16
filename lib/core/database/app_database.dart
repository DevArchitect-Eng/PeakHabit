import 'dart:io';

import 'package:drift/drift.dart';

import '../../features/profile/data/user_profile_table.dart';
// The generated part file names the enums and converters used by the tables
// below, so the library that owns it has to import them too.
import '../../features/profile/domain/user_profile.dart';
import '../../features/settings/data/app_settings_table.dart';
import '../../features/settings/domain/app_theme_mode.dart';
import '../logging/app_logger.dart';
import 'database_connection.dart';
import 'date_only_converter.dart';

part 'app_database.g.dart';

/// The app's local SQLite database.
///
/// Every table is added by the feature that needs it, together with the
/// migration step that creates it — see `docs/ARCHITECTURE.md` for how to do
/// that.
@DriftDatabase(tables: [UserProfiles, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseFile());

  /// In-memory database for tests.
  AppDatabase.inMemory() : super(openInMemoryDatabase());

  /// Database on an explicit file, for tests that need data to outlive a
  /// single connection.
  AppDatabase.atFile(File file) : super(openDatabaseAtFile(file));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      AppLogger.database.info('Creating schema at version $schemaVersion');
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      AppLogger.database.info('Migrating database from $from to $to');
      // Each feature that raises `schemaVersion` to n adds its own
      // `if (from < n) { ... }` block here.
      if (from < 2) {
        await m.createTable(userProfiles);
      }
      if (from < 3) {
        await m.createTable(appSettings);
      }
      AppLogger.database.info('Migration to $to complete');
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless they are switched on per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Opens the underlying database and runs pending migrations.
  ///
  /// Called once at app start so the schema is brought up to date at a defined
  /// point instead of on whichever query happens to run first.
  Future<void> open() async {
    AppLogger.database.info('Opening database');
    await executor.ensureOpen(this);
    AppLogger.database.info('Database opened');
  }

  @override
  Future<void> close() async {
    AppLogger.database.info('Closing database');
    await super.close();
    AppLogger.database.info('Database closed');
  }
}
