import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File name of the database inside the app's documents directory.
const _databaseFileName = 'peakhabit.sqlite';

/// The database the app runs on: a file in the documents directory, opened on
/// a background isolate so queries never block the UI.
QueryExecutor openDatabaseFile() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(directory.path, _databaseFileName)),
    );
  });
}

/// A throwaway database that only lives in memory, so unit and widget tests
/// run without touching the file system.
QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();
