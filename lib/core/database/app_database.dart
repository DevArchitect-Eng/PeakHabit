import 'dart:io';

import 'package:drift/drift.dart';

// Next to the tables themselves, these import the enums and converters the
// tables use: the generated part file names them, so the library that owns it
// has to import them too.
import '../../features/body_weight/data/body_weight_table.dart';
import '../../features/nutrition/data/composite_food_tables.dart';
import '../../features/nutrition/data/food_table.dart';
import '../../features/nutrition/data/meal_entry_table.dart';
import '../../features/nutrition/domain/food.dart';
import '../../features/nutrition/domain/meal_entry.dart';
import '../../features/profile/data/user_profile_table.dart';
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
@DriftDatabase(
  tables: [
    UserProfiles,
    AppSettings,
    BodyWeightEntries,
    Foods,
    CompositeFoods,
    CompositeFoodIngredients,
    MealEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseFile());

  /// In-memory database for tests.
  AppDatabase.inMemory() : super(openInMemoryDatabase());

  /// Database on an explicit file, for tests that need data to outlive a
  /// single connection.
  AppDatabase.atFile(File file) : super(openDatabaseAtFile(file));

  @override
  int get schemaVersion => 9;

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
      if (from < 4) {
        await m.createTable(bodyWeightEntries);
      }
      if (from < 5) {
        // `BiologicalSex` lost its `diverse` option along with the calorie
        // calculation (#4), which has a constant for women and one for men and
        // none for a third value. A profile still carrying the name could not
        // be read afterwards: the column keeps the enum by name, and drift
        // throws on a name the enum no longer has. Clearing it puts such a
        // profile back on "no answer", which is a value the app handles.
        await customStatement(
          "UPDATE user_profiles SET sex = NULL WHERE sex = 'diverse'",
        );
      }
      // Not just `from < 6`: an installation on 0 or 1 creates `userProfiles`
      // fresh above, already with the column — adding it a second time is a
      // duplicate-column error.
      if (from >= 2 && from < 6) {
        await m.addColumn(userProfiles, userProfiles.username);
      }
      // Not just `from < 7`: anything below 3 creates `appSettings` fresh
      // above, already with the column.
      if (from >= 3 && from < 7) {
        await m.addColumn(appSettings, appSettings.onboardingCompleted);
      }
      // `WeightGoal` traded its three directions for eight weekly rates (#43),
      // so the three stored names are gone. Same trap as version 5 above: the
      // column keeps the enum by name and drift throws on one the enum no
      // longer has. Each old name maps onto the rate it used to stand for —
      // `maintain` kept its name and needs no statement.
      if (from < 8) {
        await customStatement(
          "UPDATE user_profiles SET goal = 'lose500' WHERE goal = 'lose'",
        );
        await customStatement(
          "UPDATE user_profiles SET goal = 'gain200' WHERE goal = 'gain'",
        );
      }
      if (from < 9) {
        await m.createTable(foods);
        await m.createTable(compositeFoods);
        await m.createTable(compositeFoodIngredients);
        await m.createTable(mealEntries);
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
