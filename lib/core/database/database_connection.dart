import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File name of the database inside the app support directory.
const _databaseFileName = 'peakhabit.sqlite';

/// The database the app runs on, opened on a background isolate so queries
/// never block the UI.
///
/// It lives in the app support directory, not in the documents directory: the
/// latter is meant for user-facing files and becomes browsable in the Files
/// app as soon as file sharing is switched on.
QueryExecutor openDatabaseFile() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(directory.path, _databaseFileName)),
    );
  });
}

/// A throwaway database that only lives in memory, so unit and widget tests
/// run without touching the file system.
QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();

/// A database on an explicit file. Used by tests that need to reopen the same
/// data on a fresh connection; the app itself goes through [openDatabaseFile],
/// which picks the location on its own.
QueryExecutor openDatabaseAtFile(File file) => NativeDatabase(file);
