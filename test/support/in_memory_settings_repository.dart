import 'dart:async';

import 'package:peakhabit/features/settings/data/settings_repository.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

/// A [SettingsRepository] that keeps its values in memory.
///
/// Widget tests run in a fake-async zone in which drift's queries never
/// complete, so a widget test cannot drive the real database. What the
/// database does with the settings is covered by the repository tests
/// instead, which run without that zone.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._themeMode = AppThemeMode.dark]);

  final _changes = StreamController<AppThemeMode>.broadcast();

  AppThemeMode _themeMode;

  @override
  Future<AppThemeMode> readThemeMode() async => _themeMode;

  @override
  Stream<AppThemeMode> watchThemeMode() async* {
    yield _themeMode;
    yield* _changes.stream;
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    _changes.add(mode);
  }

  Future<void> dispose() => _changes.close();
}
