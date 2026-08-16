import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
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
