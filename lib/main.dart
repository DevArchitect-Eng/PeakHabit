import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database_provider.dart';
import 'core/logging/error_logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorLogging();

  final container = ProviderContainer();
  await container.read(databaseProvider).open();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeakHabitApp(),
    ),
  );
}
