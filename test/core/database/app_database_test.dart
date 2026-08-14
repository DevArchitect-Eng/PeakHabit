import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';

void main() {
  test('opens an in-memory database and closes it again', () async {
    final database = AppDatabase.inMemory();

    await database.open();
    await database.close();
  });

  test('creates a fresh database at schema version 1', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    // Pinned to the literal version on purpose: raising `schemaVersion` should
    // force a look at this test, and with it at the matching migration step.
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 1);
  });

  test('enforces foreign keys', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.open();

    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('carries no feature tables yet', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    expect(database.allTables, isEmpty);
  });
}
