import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log severity, ordered from most to least verbose.
enum LogLevel {
  debug,
  info,
  warning,
  error;

  /// Maps to the `level` values `dart:developer`'s `log()` expects, roughly
  /// following `java.util.logging`'s scale that tools like DevTools colorize.
  int get _severity => switch (this) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}

/// One line of diagnostic output, passed to [AppLogger.output].
@immutable
class LogEntry {
  const LogEntry({
    required this.level,
    required this.component,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String component;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => '[$component] $message';
}

/// Central, purely local diagnostic logging for PeakHabit.
///
/// Nothing logged here leaves the device — no analytics, no crash reporting,
/// no network calls. See `docs/ARCHITECTURE.md` for when to reach for this
/// instead of `print` or ad-hoc console output.
///
/// Use one of the predefined component loggers ([lifecycle], [database],
/// [routing], [app]) or create a `const AppLogger('my-component')` for a new
/// area.
class AppLogger {
  const AppLogger(this.component);

  /// App foreground/background/inactive transitions.
  static const lifecycle = AppLogger('lifecycle');

  /// Database open/close and migrations.
  static const database = AppLogger('database');

  /// Tab and route changes.
  static const routing = AppLogger('routing');

  /// App-wide events that don't fit a more specific component, such as
  /// unhandled errors.
  static const app = AppLogger('app');

  final String component;

  /// The least severe level that still reaches [output]. Everything below is
  /// dropped before formatting, so debug logging costs nothing in release.
  static LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// Where accepted [LogEntry]s go. Defaults to the console via
  /// `dart:developer`; tests swap this out to capture entries instead.
  static void Function(LogEntry entry) output = _logToConsole;

  static void _logToConsole(LogEntry entry) {
    developer.log(
      entry.message,
      name: 'PeakHabit.${entry.component}',
      level: entry.level._severity,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  void debug(String message) => _emit(LogLevel.debug, message);

  void info(String message) => _emit(LogLevel.info, message);

  void warning(String message) => _emit(LogLevel.warning, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _emit(LogLevel.error, message, error, stackTrace);

  void _emit(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;
    output(
      LogEntry(
        level: level,
        component: component,
        message: message,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
