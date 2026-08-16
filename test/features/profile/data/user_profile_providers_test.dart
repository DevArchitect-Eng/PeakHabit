import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/profile/data/user_profile_providers.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('hands out a repository on the app database', () async {
    final repository = container.read(userProfileRepositoryProvider);

    await repository.save(UserProfile(heightCm: 175));

    final rows = await database.select(database.userProfiles).get();
    expect(rows.single.heightCm, 175);
  });

  test('the profile provider follows what the repository saves', () async {
    final subscription = container.listen(
      userProfileProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(userProfileProvider.future), UserProfile.empty);

    await container
        .read(userProfileRepositoryProvider)
        .save(UserProfile(heightCm: 175, goal: WeightGoal.gain));
    await pumpEventQueue();

    expect(
      container.read(userProfileProvider).value,
      UserProfile(heightCm: 175, goal: WeightGoal.gain),
    );
  });
}
