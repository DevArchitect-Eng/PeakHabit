import 'dart:async';

import 'package:peakhabit/features/profile/data/user_profile_repository.dart';
import 'package:peakhabit/features/profile/domain/calorie_target_history.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

/// A [UserProfileRepository] that keeps the profile in memory.
///
/// Same reason as the in-memory settings repository next to it: a widget test
/// cannot drive the real database, and what the database does with the profile
/// is covered by the repository tests.
class InMemoryUserProfileRepository implements UserProfileRepository {
  ///
  /// Without [targetChanges] the record of calorie targets starts on the
  /// target of [_profile], dated today — what the migration leaves behind on
  /// an installation that already has one.
  InMemoryUserProfileRepository([
    this._profile = UserProfile.empty,
    this.failingWrites = false,
    List<CalorieTargetChange>? targetChanges,
  ]) : _targetChanges = [
         ...?targetChanges ??
             (_profile.calorieTarget == null
                 ? null
                 : [(validFrom: _today(), kcal: _profile.calorieTarget)]),
       ];

  /// Lets every write fail, for the case a screen has to react to a save it
  /// could not complete.
  final bool failingWrites;

  final _changes = StreamController<UserProfile>.broadcast();
  final _historyChanges = StreamController<CalorieTargetHistory>.broadcast();
  final List<CalorieTargetChange> _targetChanges;

  UserProfile _profile;

  /// What was saved last, for a test to check against.
  UserProfile get profile => _profile;

  @override
  Future<UserProfile> read() async => _profile;

  @override
  Stream<UserProfile> watch() async* {
    yield _profile;
    yield* _changes.stream;
  }

  @override
  Future<void> save(UserProfile profile) async {
    if (failingWrites) throw StateError('saving the profile failed');
    _profile = profile;
    _changes.add(profile);

    // The same rule the real repository follows: a row only for a target
    // today does not already stand on, and one row per day at most.
    final today = _today();
    if (_history.targetOn(today) != profile.calorieTarget) {
      _targetChanges
        ..removeWhere((change) => change.validFrom == today)
        ..add((validFrom: today, kcal: profile.calorieTarget));
      _historyChanges.add(_history);
    }
  }

  @override
  Future<CalorieTargetHistory> readCalorieTargetHistory() async => _history;

  @override
  Stream<CalorieTargetHistory> watchCalorieTargetHistory() async* {
    yield _history;
    yield* _historyChanges.stream;
  }

  CalorieTargetHistory get _history => CalorieTargetHistory(_targetChanges);

  Future<void> dispose() async {
    await _changes.close();
    await _historyChanges.close();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
