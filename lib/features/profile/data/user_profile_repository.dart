import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/macro_distribution.dart';
import '../domain/user_profile.dart';
import 'user_profile_table.dart';

/// Reads and writes the one user profile.
///
/// Before anything has been saved the repository reports the default profile
/// instead of nothing, so callers always have values to work with. The row is
/// written on the first [save].
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
  Future<void> save(UserProfile profile) async {
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
  }

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
