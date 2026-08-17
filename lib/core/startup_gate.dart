import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import 'database/database_connection.dart';
import 'logging/app_logger.dart';
import 'startup.dart';
import 'startup_error_screen.dart';
import 'theme/app_theme.dart';

/// Root widget of the app.
///
/// Runs [warmUp] before showing [PeakHabitApp], and turns a failure into a
/// blocking recovery screen instead of a blank one (see #19).
///
/// Every attempt builds its own [ProviderContainer]: retrying against a
/// connection that already failed to open is not guaranteed to work, and the
/// "reset app data" action needs a database that has not already failed
/// once.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    ProviderContainer Function()? containerBuilder,
    Future<void> Function()? deleteDatabase,
  }) : containerBuilder = containerBuilder ?? ProviderContainer.new,
       deleteDatabase = deleteDatabase ?? deleteDatabaseFile;

  /// Builds the container for one startup attempt. Overridden in tests to
  /// inject a database that fails or succeeds on demand.
  final ProviderContainer Function() containerBuilder;

  /// Discards the on-disk database file. Overridden in tests so they don't
  /// touch the file system.
  final Future<void> Function() deleteDatabase;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

enum _Phase { loading, error, ready }

class _StartupGateState extends State<StartupGate> {
  _Phase _phase = _Phase.loading;
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    unawaited(_attempt());
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  Future<void> _attempt() async {
    setState(() => _phase = _Phase.loading);

    final container = widget.containerBuilder();
    try {
      await warmUp(container);
    } catch (error, stackTrace) {
      AppLogger.app.error('Starting the app failed', error, stackTrace);
      container.dispose();
      if (!mounted) return;
      setState(() => _phase = _Phase.error);
      return;
    }

    if (!mounted) {
      container.dispose();
      return;
    }
    setState(() {
      _container = container;
      _phase = _Phase.ready;
    });
  }

  Future<void> _reset() async {
    try {
      await widget.deleteDatabase();
    } catch (error, stackTrace) {
      AppLogger.app.error('Resetting the database failed', error, stackTrace);
    }
    await _attempt();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      // No spinner: warmUp is expected to finish in well under a second, and
      // an indeterminate animation never settles, which breaks
      // `tester.pumpAndSettle()` in every test that passes through here.
      _Phase.loading => MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(),
      ),
      _Phase.error => StartupErrorScreen(onRetry: _attempt, onReset: _reset),
      _Phase.ready => UncontrolledProviderScope(
        container: _container!,
        child: const PeakHabitApp(),
      ),
    };
  }
}
