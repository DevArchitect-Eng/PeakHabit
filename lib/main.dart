import 'package:flutter/material.dart';

import 'core/logging/error_logging.dart';
import 'core/startup_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorLogging();

  runApp(const StartupGate());
}
