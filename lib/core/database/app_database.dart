import 'package:drift/drift.dart';

import 'database_connection.dart';

part 'app_database.g.dart';

/// The app's local SQLite database.
///
/// It deliberately carries no feature tables. Every table is added by the
/// feature that needs it, together with the migration step that creates it —
/// see `docs/ARCHITECTURE.md` for how to do that.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseFile());

  /// In-memory database for tests.
  AppDatabase.inMemory() : super(openInMemoryDatabase());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Each feature that raises `schemaVersion` to n adds its own
      // `if (from < n) { ... }` block here.
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
  Future<void> open() => executor.ensureOpen(this);
}
