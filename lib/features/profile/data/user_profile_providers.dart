import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/calorie_target_history.dart';
import '../domain/user_profile.dart';
import 'user_profile_repository.dart';

/// Access to the stored profile. Widgets that only write go through this one.
final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(ref.watch(databaseProvider)),
);

/// The current profile, re-emitted whenever it is saved.
final userProfileProvider = StreamProvider<UserProfile>(
  (ref) => ref.watch(userProfileRepositoryProvider).watch(),
);

/// Every calorie target the profile has had, re-emitted on every change.
///
/// What a past day is measured against — the profile only knows the target as
/// it stands today.
final calorieTargetHistoryProvider = StreamProvider<CalorieTargetHistory>(
  (ref) => ref.watch(userProfileRepositoryProvider).watchCalorieTargetHistory(),
);
