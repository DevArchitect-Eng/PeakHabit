import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/body_weight/data/body_weight_providers.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';

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

  final entry = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 81.4);

  test('hands out a repository on the app database', () async {
    final repository = container.read(bodyWeightRepositoryProvider);

    await repository.save(entry);

    final rows = await database.select(database.bodyWeightEntries).get();
    expect(rows.single.weightKg, 81.4);
  });

  test('the latest provider follows what the repository saves', () async {
    final subscription = container.listen(
      latestBodyWeightProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(latestBodyWeightProvider.future), isNull);

    await container.read(bodyWeightRepositoryProvider).save(entry);
    await pumpEventQueue();

    expect(container.read(latestBodyWeightProvider).value, entry);
  });

  test('the first provider follows what the repository saves', () async {
    final subscription = container.listen(
      firstBodyWeightProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(firstBodyWeightProvider.future), isNull);

    await container.read(bodyWeightRepositoryProvider).save(entry);
    await pumpEventQueue();

    expect(container.read(firstBodyWeightProvider).value, entry);
  });
}
