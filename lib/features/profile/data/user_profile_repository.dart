import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/calorie_target_history.dart';
import '../domain/macro_distribution.dart';
import '../domain/user_profile.dart';
import 'user_profile_table.dart';

/// Reads and writes the one user profile.
///
/// Before anything has been saved the repository reports the default profile
/// instead of nothing, so callers always have values to work with. The row is
/// written on the first [save].
///
/// Keeps the record of calorie targets alongside it (see
/// [CalorieTargetHistory]): every write of the profile goes through [save], so
/// a target cannot change without the record hearing about it — whether it
/// comes from the onboarding, from the recalculation on the goals screen or
/// typed in on the nutrition targets screen.
class UserProfileRepository {
  UserProfileRepository(this._database);

  final AppDatabase _database;

  /// The profile as it currently stands.
  Future<UserProfile> read() async {
    final row = await _database
        .select(_database.userProfiles)
        .getSingleOrNull();
    return _toProfile(row);
  }

  /// Emits the profile and every later change to it.
  Stream<UserProfile> watch() => _database
      .select(_database.userProfiles)
      .watchSingleOrNull()
      .map(_toProfile);

  /// Writes [profile] — creating the row on the first call, replacing it on
  /// every call after that.
  ///
  /// A calorie target that differs from the one today stands on is recorded
  /// as a change from today on. One transaction, so the profile and its record
  /// cannot drift apart.
  Future<void> save(UserProfile profile) => _database.transaction(() async {
    await _database
        .into(_database.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: const Value(singleProfileId),
            username: Value(profile.username),
            heightCm: Value(profile.heightCm),
            sex: Value(profile.sex),
            birthDate: Value(profile.birthDate),
            activityLevel: Value(profile.activityLevel),
            goal: profile.goal,
            calorieTarget: Value(profile.calorieTarget),
            proteinPercent: profile.macros.proteinPercent,
            carbPercent: profile.macros.carbPercent,
            fatPercent: profile.macros.fatPercent,
            updatedAt: DateTime.now(),
          ),
        );
    await _recordCalorieTarget(profile.calorieTarget);
  });

  /// Every calorie target the profile has had, and the day each took over.
  Future<CalorieTargetHistory> readCalorieTargetHistory() async =>
      _toHistory(await _database.select(_database.calorieTargetChanges).get());

  /// Emits the record of calorie targets and re-emits it on every change.
  Stream<CalorieTargetHistory> watchCalorieTargetHistory() =>
      _database.select(_database.calorieTargetChanges).watch().map(_toHistory);

  /// Notes [kcal] as the target from today on, unless today already stands
  /// on it.
  ///
  /// Most saves change something else — a name, a height — and would
  /// otherwise leave a row behind for every one of them. A second change on
  /// the same day replaces the first: a day is measured against the target it
  /// ended on.
  Future<void> _recordCalorieTarget(int? kcal) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final history = await readCalorieTargetHistory();
    if (history.targetOn(today) == kcal) return;

    await _database
        .into(_database.calorieTargetChanges)
        .insertOnConflictUpdate(
          CalorieTargetChangesCompanion.insert(
            validFrom: today,
            kcal: Value(kcal),
            updatedAt: now,
          ),
        );
  }

  CalorieTargetHistory _toHistory(List<CalorieTargetChangeRow> rows) =>
      CalorieTargetHistory([
        for (final row in rows) (validFrom: row.validFrom, kcal: row.kcal),
      ]);

  UserProfile _toProfile(UserProfileRow? row) {
    if (row == null) return UserProfile.empty;

    return UserProfile(
      username: row.username,
      heightCm: row.heightCm,
      sex: row.sex,
      birthDate: row.birthDate,
      activityLevel: row.activityLevel,
      goal: row.goal,
      calorieTarget: row.calorieTarget,
      macros: MacroDistribution(
        proteinPercent: row.proteinPercent,
        carbPercent: row.carbPercent,
        fatPercent: row.fatPercent,
      ),
    );
  }
}
