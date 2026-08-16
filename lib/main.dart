import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database_provider.dart';
import 'core/logging/error_logging.dart';
import 'features/settings/data/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorLogging();

  final container = ProviderContainer();
  await container.read(databaseProvider).open();
  // Read the stored theme before the first frame, so the app does not start in
  // one theme and visibly switch to the other.
  await container.read(themeModeProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeakHabitApp(),
    ),
  );
}
