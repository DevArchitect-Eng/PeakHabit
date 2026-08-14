import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(databaseProvider).open();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeakHabitApp(),
    ),
  );
}
