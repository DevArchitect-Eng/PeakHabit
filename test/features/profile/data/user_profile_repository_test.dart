import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/profile/data/user_profile_repository.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

void main() {
  late AppDatabase database;
  late UserProfileRepository repository;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    repository = UserProfileRepository(database);
  });

  tearDown(() => database.close());

  final filledProfile = UserProfile(
    username: 'mila',
    heightCm: 182,
    sex: BiologicalSex.male,
    birthDate: DateTime(1990, 5, 17),
    activityLevel: ActivityLevel.moderatelyActive,
    goal: WeightGoal.lose500,
    calorieTarget: 2200,
    macros: MacroDistribution(
      proteinPercent: 35,
      carbPercent: 35,
      fatPercent: 30,
    ),
  );

  group('read', () {
    test('reports the default profile before anything was saved', () async {
      expect(await repository.read(), UserProfile.empty);
    });

    test('gives back every value that was saved', () async {
      await repository.save(filledProfile);

      expect(await repository.read(), filledProfile);
    });

    test('gives back a changed username', () async {
      await repository.save(filledProfile);

      await repository.save(filledProfile.copyWith(username: 'ben'));

      expect((await repository.read()).username, 'ben');
    });

    test('keeps the birth date on the same calendar day', () async {
      await repository.save(filledProfile);

      final read = await repository.read();
      expect(read.birthDate?.year, 1990);
      expect(read.birthDate?.month, 5);
      expect(read.birthDate?.day, 17);
    });
  });

  group('save', () {
    test('creates the profile on the first call', () async {
      await repository.save(filledProfile);

      final rows = await database.select(database.userProfiles).get();
      expect(rows, hasLength(1));
    });

    test('changes the existing profile instead of adding a second', () async {
      await repository.save(filledProfile);

      await repository.save(filledProfile.copyWith(calorieTarget: 2500));

      final rows = await database.select(database.userProfiles).get();
      expect(rows, hasLength(1));
      expect((await repository.read()).calorieTarget, 2500);
    });

    test('clears a value that was set before', () async {
      await repository.save(filledProfile);

      await repository.save(filledProfile.copyWith(calorieTarget: null));

      expect((await repository.read()).calorieTarget, isNull);
    });

    test('gram targets follow a changed calorie target', () async {
      await repository.save(filledProfile.copyWith(calorieTarget: 2000));

      final targets = (await repository.read()).macroTargets;
      // 35% of 2000 kcal = 700 kcal / 4 = 175 g protein
      expect(targets?.proteinGrams, 175);
    });
  });

  group('watch', () {
    test('emits the default profile and then every change', () async {
      final seen = <UserProfile>[];
      final subscription = repository.watch().listen(seen.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.save(filledProfile);
      await pumpEventQueue();

      expect(seen, [UserProfile.empty, filledProfile]);
    });
  });

  group('the database itself', () {
    // The domain model already rejects these, so a raw statement stands in for
    // the ways past it — a later migration, or someone editing the file.
    Matcher failsCheck(String constraint) => throwsA(
      isA<Exception>().having(
        (error) => error.toString(),
        'message',
        allOf(contains('CHECK constraint failed'), contains(constraint)),
      ),
    );

    test('refuses a split that is not 100 percent', () {
      expect(
        () => database.customStatement(
          'INSERT INTO user_profiles '
          '(id, goal, protein_percent, carb_percent, fat_percent, updated_at) '
          "VALUES (1, 'maintain', 30, 30, 30, 0)",
        ),
        failsCheck('protein_percent + carb_percent + fat_percent = 100'),
      );
    });

    test('refuses a second profile', () {
      expect(
        () => database.customStatement(
          'INSERT INTO user_profiles '
          '(id, goal, protein_percent, carb_percent, fat_percent, updated_at) '
          "VALUES (2, 'maintain', 30, 40, 30, 0)",
        ),
        failsCheck('id'),
      );
    });
  });

  test('the values survive a restart of the app', () async {
    final directory = await Directory.systemTemp.createTemp('peakhabit_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'peakhabit.sqlite'));

    final firstRun = AppDatabase.atFile(file);
    await firstRun.open();
    await UserProfileRepository(firstRun).save(filledProfile);
    await firstRun.close();

    final secondRun = AppDatabase.atFile(file);
    addTearDown(secondRun.close);
    await secondRun.open();

    expect(await UserProfileRepository(secondRun).read(), filledProfile);
  });
}
