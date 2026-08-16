import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/logging/app_logger.dart';

void main() {
  setUp(() {
    AppLogger.output = (_) {};
  });

  test('opens an in-memory database and closes it again', () async {
    final database = AppDatabase.inMemory();

    await database.open();
    await database.close();
  });

  test('logs opening, schema creation and closing', () async {
    final captured = <LogEntry>[];
    AppLogger.output = captured.add;
    final database = AppDatabase.inMemory();

    await database.open();
    await database.close();

    expect(captured.every((entry) => entry.component == 'database'), isTrue);
    final messages = captured.map((entry) => entry.message).toList();
    expect(messages, [
      'Opening database',
      'Creating schema at version 2',
      'Database opened',
      'Closing database',
      'Database closed',
    ]);
  });

  test('creates a fresh database at schema version 2', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    // Pinned to the literal version on purpose: raising `schemaVersion` should
    // force a look at this test, and with it at the matching migration step.
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 2);
  });

  test('enforces foreign keys', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('carries the profile table', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    expect(
      database.allTables.map((table) => table.actualTableName),
      contains('user_profiles'),
    );
  });

  test('migrates an installation that still runs version 1', () async {
    final directory = await Directory.systemTemp.createTemp('peakhabit_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'peakhabit.sqlite'));

    // Rewind a fresh database to what a version-1 installation left behind:
    // the plumbing, but none of the feature tables.
    final legacy = AppDatabase.atFile(file);
    await legacy.open();
    await legacy.customStatement('DROP TABLE user_profiles');
    await legacy.customStatement('PRAGMA user_version = 1');
    await legacy.close();

    final migrated = AppDatabase.atFile(file);
    addTearDown(migrated.close);
    await migrated.open();

    final tables = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name = 'user_profiles'",
        )
        .get();
    expect(tables, hasLength(1));
  });
}
