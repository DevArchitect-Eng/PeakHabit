import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_theme_mode.dart';
import 'app_settings_table.dart';

/// Reads and writes the app settings.
///
/// Before anything has been saved the repository reports the defaults instead
/// of nothing, so callers always have values to work with. The row is written
/// on the first save.
class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  /// The theme mode as it currently stands.
  Future<AppThemeMode> readThemeMode() async {
    final row = await _database.select(_database.appSettings).getSingleOrNull();
    return _toThemeMode(row);
  }

  /// Emits the theme mode and every later change to it.
  Stream<AppThemeMode> watchThemeMode() => _database
      .select(_database.appSettings)
      .watchSingleOrNull()
      .map(_toThemeMode);

  /// Writes [mode] — creating the row on the first call, replacing it on every
  /// call after that.
  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: const Value(singleSettingsId),
            themeMode: mode,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Dark is the app's default look, so an unwritten setting means dark.
  AppThemeMode _toThemeMode(AppSettingsRow? row) =>
      row?.themeMode ?? AppThemeMode.dark;
}
