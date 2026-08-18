import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/features/body_weight/data/body_weight_repository.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';

void main() {
  late AppDatabase database;
  late BodyWeightRepository repository;

  setUp(() async {
    AppLogger.output = (_) {};
    database = AppDatabase.inMemory();
    await database.open();
    repository = BodyWeightRepository(database);
  });

  tearDown(() => database.close());

  BodyWeightEntry entryOn(int day, double weightKg) =>
      BodyWeightEntry(date: DateTime(2026, 8, day), weightKg: weightKg);

  group('save and read', () {
    test('reports no entry before anything was saved', () async {
      expect(await repository.readLatest(), isNull);
      expect(
        await repository.readRange(DateTime(2026), DateTime(2027)),
        isEmpty,
      );
    });

    test('gives back what was saved', () async {
      await repository.save(entryOn(18, 81.4));

      expect(await repository.readLatest(), entryOn(18, 81.4));
    });

    test('keeps the entry on the same calendar day', () async {
      await repository.save(
        BodyWeightEntry(date: DateTime(2026, 8, 18, 7, 30), weightKg: 81.4),
      );

      expect((await repository.readLatest())?.date, DateTime(2026, 8, 18));
    });

    test('reports the newest entry as the latest one', () async {
      await repository.save(entryOn(18, 81.4));
      await repository.save(entryOn(12, 82.0));
      await repository.save(entryOn(15, 81.8));

      expect(await repository.readLatest(), entryOn(18, 81.4));
    });
  });

  group('one entry per day', () {
    test('a second entry on the same day replaces the first', () async {
      await repository.save(entryOn(18, 81.4));

      await repository.save(entryOn(18, 80.9));

      final rows = await database.select(database.bodyWeightEntries).get();
      expect(rows, hasLength(1));
      expect(await repository.readLatest(), entryOn(18, 80.9));
    });

    test('the time of day does not open a second slot', () async {
      await repository.save(
        BodyWeightEntry(date: DateTime(2026, 8, 18, 6), weightKg: 80.9),
      );

      await repository.save(
        BodyWeightEntry(date: DateTime(2026, 8, 18, 21), weightKg: 82.1),
      );

      final rows = await database.select(database.bodyWeightEntries).get();
      expect(rows, hasLength(1));
      expect((await repository.readLatest())?.weightKg, 82.1);
    });

    test('entries on different days stand next to each other', () async {
      await repository.save(entryOn(17, 81.4));
      await repository.save(entryOn(18, 80.9));

      final rows = await database.select(database.bodyWeightEntries).get();
      expect(rows, hasLength(2));
    });
  });

  group('readRange', () {
    setUp(() async {
      // Saved out of order on purpose — the query has to do the sorting.
      for (final entry in [
        entryOn(18, 81.4),
        entryOn(10, 82.6),
        entryOn(14, 82.0),
        entryOn(22, 81.1),
      ]) {
        await repository.save(entry);
      }
    });

    test('gives back the entries oldest first', () async {
      final entries = await repository.readRange(
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 22),
      );

      expect(entries.map((entry) => entry.date), [
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 14),
        DateTime(2026, 8, 18),
        DateTime(2026, 8, 22),
      ]);
    });

    test('includes the entries on both bounds', () async {
      final entries = await repository.readRange(
        DateTime(2026, 8, 14),
        DateTime(2026, 8, 18),
      );

      expect(entries, [entryOn(14, 82.0), entryOn(18, 81.4)]);
    });

    test('leaves out what lies outside', () async {
      final entries = await repository.readRange(
        DateTime(2026, 8, 15),
        DateTime(2026, 8, 21),
      );

      expect(entries, [entryOn(18, 81.4)]);
    });

    test('ignores a time of day on the bounds', () async {
      final entries = await repository.readRange(
        DateTime(2026, 8, 14, 23, 59),
        DateTime(2026, 8, 18, 0, 1),
      );

      expect(entries, [entryOn(14, 82.0), entryOn(18, 81.4)]);
    });

    test('is empty when nothing falls into the range', () async {
      expect(
        await repository.readRange(DateTime(2026, 9), DateTime(2026, 9, 30)),
        isEmpty,
      );
    });

    test('spans the turn of the year', () async {
      await repository.save(
        BodyWeightEntry(date: DateTime(2025, 12, 31), weightKg: 84.0),
      );
      await repository.save(
        BodyWeightEntry(date: DateTime(2026, 1, 1), weightKg: 84.3),
      );

      final entries = await repository.readRange(
        DateTime(2025, 12, 30),
        DateTime(2026, 1, 2),
      );

      expect(entries.map((entry) => entry.weightKg), [84.0, 84.3]);
    });
  });

  group('delete', () {
    test('removes the entry of that day', () async {
      await repository.save(entryOn(17, 81.4));
      await repository.save(entryOn(18, 80.9));

      await repository.delete(DateTime(2026, 8, 18));

      expect(await repository.readLatest(), entryOn(17, 81.4));
    });

    test('ignores the time of day', () async {
      await repository.save(entryOn(18, 80.9));

      await repository.delete(DateTime(2026, 8, 18, 15, 20));

      expect(await repository.readLatest(), isNull);
    });

    test('leaves a day without an entry alone', () async {
      await repository.save(entryOn(18, 80.9));

      await repository.delete(DateTime(2026, 8, 17));

      expect(await repository.readLatest(), entryOn(18, 80.9));
    });
  });

  group('watch', () {
    test('emits the latest entry and then every change', () async {
      final seen = <BodyWeightEntry?>[];
      final subscription = repository.watchLatest().listen(seen.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.save(entryOn(18, 81.4));
      await pumpEventQueue();
      await repository.delete(DateTime(2026, 8, 18));
      await pumpEventQueue();

      expect(seen, [null, entryOn(18, 81.4), null]);
    });

    test('a range follows what is saved into it', () async {
      final seen = <List<BodyWeightEntry>>[];
      final subscription = repository
          .watchRange(DateTime(2026, 8, 1), DateTime(2026, 8, 31))
          .listen(seen.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.save(entryOn(18, 81.4));
      await pumpEventQueue();

      expect(seen, [
        <BodyWeightEntry>[],
        [entryOn(18, 81.4)],
      ]);
    });
  });

  group('the database itself', () {
    // The domain model already rejects these, so a raw statement stands in for
    // the ways past it — a later migration, or someone editing the file.
    test('refuses a weight of zero or less', () {
      expect(
        () => database.customStatement(
          'INSERT INTO body_weight_entries (date, weight_kg, updated_at) '
          "VALUES ('2026-08-18', 0, 0)",
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('CHECK constraint failed'),
              contains('weight_kg > 0'),
            ),
          ),
        ),
      );
    });

    test('refuses a second row for one day', () {
      expect(
        () async {
          await database.customStatement(
            'INSERT INTO body_weight_entries (date, weight_kg, updated_at) '
            "VALUES ('2026-08-18', 81.4, 0)",
          );
          await database.customStatement(
            'INSERT INTO body_weight_entries (date, weight_kg, updated_at) '
            "VALUES ('2026-08-18', 80.9, 0)",
          );
        },
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('UNIQUE constraint failed'),
          ),
        ),
      );
    });
  });

  test('the entries survive a restart of the app', () async {
    final directory = await Directory.systemTemp.createTemp('peakhabit_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'peakhabit.sqlite'));

    final firstRun = AppDatabase.atFile(file);
    await firstRun.open();
    await BodyWeightRepository(firstRun).save(entryOn(18, 81.4));
    await firstRun.close();

    final secondRun = AppDatabase.atFile(file);
    addTearDown(secondRun.close);
    await secondRun.open();

    expect(
      await BodyWeightRepository(secondRun).readLatest(),
      entryOn(18, 81.4),
    );
  });
}
