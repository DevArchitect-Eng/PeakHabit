import 'dart:async';

import 'package:peakhabit/features/settings/data/settings_repository.dart';
import 'package:peakhabit/features/settings/domain/app_theme_mode.dart';

/// A [SettingsRepository] that keeps its values in memory.
///
/// Widget tests that drove the real database hung instead of finishing — the
/// fake-async zone `testWidgets` runs in and drift's asynchronous queries do
/// not get along. What the database does with the settings is covered by the
/// repository tests, which run outside that zone.
///
/// See `CLAUDE.md` § Tests — the rule cost two tickets before it was written
/// down somewhere one reads before writing a test, rather than after.
class InMemorySettingsRepository implements SettingsRepository {
  /// [onboardingCompleted] defaults to `true`, unlike a real fresh install:
  /// most widget tests are about the app past onboarding, and having each of
  /// them opt in to that would be far more noise than the tests that
  /// deliberately want a first start opting out.
  InMemorySettingsRepository([
    this._themeMode = AppThemeMode.dark,
    this._onboardingCompleted = true,
  ]);

  final _themeChanges = StreamController<AppThemeMode>.broadcast();
  final _onboardingChanges = StreamController<bool>.broadcast();

  AppThemeMode _themeMode;
  bool _onboardingCompleted;

  @override
  Future<AppThemeMode> readThemeMode() async => _themeMode;

  @override
  Stream<AppThemeMode> watchThemeMode() async* {
    yield _themeMode;
    yield* _themeChanges.stream;
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    _themeChanges.add(mode);
  }

  @override
  Future<bool> readOnboardingCompleted() async => _onboardingCompleted;

  @override
  Stream<bool> watchOnboardingCompleted() async* {
    yield _onboardingCompleted;
    yield* _onboardingChanges.stream;
  }

  @override
  Future<void> saveOnboardingCompleted() async {
    _onboardingCompleted = true;
    _onboardingChanges.add(true);
  }

  Future<void> dispose() =>
      Future.wait([_themeChanges.close(), _onboardingChanges.close()]);
}
