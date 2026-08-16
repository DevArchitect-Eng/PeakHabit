import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/logging/error_logging.dart';
import 'core/startup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorLogging();

  final container = ProviderContainer();
  await warmUp(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeakHabitApp(),
    ),
  );
}
