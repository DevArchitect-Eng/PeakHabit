import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// Routes Flutter's and the platform's unhandled-error hooks through
/// [AppLogger.app], in addition to whatever they already do (the debug
/// red screen, console dump, ...).
///
/// Call once during app start, before `runApp`.
void installGlobalErrorLogging() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    AppLogger.app.error(
      'Unhandled Flutter error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    previousOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.app.error('Unhandled platform error', error, stackTrace);
    return false;
  };
}
