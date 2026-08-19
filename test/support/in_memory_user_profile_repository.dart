import 'dart:async';

import 'package:peakhabit/features/profile/data/user_profile_repository.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

/// A [UserProfileRepository] that keeps the profile in memory.
///
/// Same reason as the in-memory settings repository next to it: a widget test
/// cannot drive the real database, and what the database does with the profile
/// is covered by the repository tests.
class InMemoryUserProfileRepository implements UserProfileRepository {
  InMemoryUserProfileRepository([
    this._profile = UserProfile.empty,
    this.failingWrites = false,
  ]);

  /// Lets every write fail, for the case a screen has to react to a save it
  /// could not complete.
  final bool failingWrites;

  final _changes = StreamController<UserProfile>.broadcast();

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
  }

  Future<void> dispose() => _changes.close();
}
