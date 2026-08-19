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
    final row = await _readRow();
    return _toThemeMode(row);
  }

  /// Emits the theme mode and every later change to it.
  Stream<AppThemeMode> watchThemeMode() => _watchRow().map(_toThemeMode);

  /// Writes [mode] — creating the row on the first call, replacing it on every
  /// call after that. The other settings carry over unchanged.
  Future<void> saveThemeMode(AppThemeMode mode) async {
    final row = await _readRow();
    await _saveRow(row, themeMode: mode);
  }

  /// Whether the first-start onboarding has been completed.
  Future<bool> readOnboardingCompleted() async {
    final row = await _readRow();
    return _toOnboardingCompleted(row);
  }

  /// Emits the onboarding-completed flag and every later change to it.
  Stream<bool> watchOnboardingCompleted() =>
      _watchRow().map(_toOnboardingCompleted);

  /// Marks the onboarding as completed, so it does not appear again. The
  /// other settings carry over unchanged.
  Future<void> saveOnboardingCompleted() async {
    final row = await _readRow();
    await _saveRow(row, onboardingCompleted: true);
  }

  Future<AppSettingsRow?> _readRow() =>
      _database.select(_database.appSettings).getSingleOrNull();

  Stream<AppSettingsRow?> _watchRow() =>
      _database.select(_database.appSettings).watchSingleOrNull();

  /// Replaces the settings row, keeping every field not passed in at what
  /// [current] already had — or at its default, when there was no row yet.
  Future<void> _saveRow(
    AppSettingsRow? current, {
    AppThemeMode? themeMode,
    bool? onboardingCompleted,
  }) async {
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: const Value(singleSettingsId),
            themeMode: themeMode ?? _toThemeMode(current),
            onboardingCompleted: Value(
              onboardingCompleted ?? _toOnboardingCompleted(current),
            ),
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Dark is the app's default look, so an unwritten setting means dark.
  AppThemeMode _toThemeMode(AppSettingsRow? row) =>
      row?.themeMode ?? AppThemeMode.dark;

  /// No row yet means the onboarding has not run.
  bool _toOnboardingCompleted(AppSettingsRow? row) =>
      row?.onboardingCompleted ?? false;
}
