import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The one database instance of the app. Repositories read it from here
/// instead of opening their own connection.
///
/// Tests override this with `AppDatabase.inMemory()`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
