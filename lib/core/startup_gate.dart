import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import 'database/database_connection.dart';
import 'logging/app_logger.dart';
import 'startup.dart';
import 'startup_error_screen.dart';
import 'theme/app_theme.dart';

/// How long [StartupGate] waits for [warmUp] before it offers a way out.
///
/// Generous on purpose: the first start after an update runs the migrations,
/// and on a slow device with a lot of rows that is not instant — a start cut
/// short by an impatient limit would look broken to the user for no reason.
/// Overshooting costs little, because the wait is not a cancellation: a start
/// that is merely slow keeps running to the end, the recovery screen just
/// appears alongside it.
const startupTimeout = Duration(seconds: 15);

/// Root widget of the app.
///
/// Runs [warmUp] before showing [PeakHabitApp], and turns a failure into a
/// blocking recovery screen instead of a blank one (see #19). A [warmUp] that
/// hangs rather than throws ends up on the same screen once [startupTimeout]
/// has passed (see #28) — the blank screen was the symptom to get rid of, and
/// it looks the same whether the start failed or never came back.
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

  /// What the recovery screen tells the user in [_Phase.error].
  String _errorMessage = StartupErrorScreen.openFailedMessage;

  /// Containers of starts that overran [startupTimeout] and are still running.
  /// More than one can pile up: every retry that hangs again adds its own.
  final _overrunning = <ProviderContainer>[];

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
    if (!mounted) return;
    setState(() => _phase = _Phase.loading);

    final container = widget.containerBuilder();
    final warmingUp = warmUp(container);
    try {
      await warmingUp.timeout(startupTimeout);
    } on TimeoutException {
      AppLogger.app.warning(
        'Starting the app is still not done after '
        '${startupTimeout.inSeconds}s, showing the recovery screen',
      );
      // Not disposed here, unlike the failure below: `timeout` cancels
      // nothing, so the open is still in flight, and disposing would close the
      // connection out from under a migration that may be halfway through.
      // Letting go of the container is left to _disposeWhenSettled — or to
      // _reset, which has to get rid of it before the file goes.
      _overrunning.add(container);
      unawaited(_disposeWhenSettled(container, warmingUp));
      if (!mounted) return;
      setState(() {
        _errorMessage = StartupErrorScreen.noResponseMessage;
        _phase = _Phase.error;
      });
      return;
    } catch (error, stackTrace) {
      AppLogger.app.error('Starting the app failed', error, stackTrace);
      container.dispose();
      if (!mounted) return;
      setState(() {
        _errorMessage = StartupErrorScreen.openFailedMessage;
        _phase = _Phase.error;
      });
      return;
    }

    if (!mounted) {
      container.dispose();
      return;
    }
    setState(() {
      // Nothing should be here yet, but an attempt that overtook another one
      // must not leave the loser's database connection open forever.
      _container?.dispose();
      _container = container;
      _phase = _Phase.ready;
    });
  }

  /// Sees an overrunning start through and releases its container afterwards.
  /// Without this, the connection would stay open for the rest of the process
  /// and a late failure would surface as an unhandled async error.
  ///
  /// A late success is logged but not shown: the user is on the recovery
  /// screen by now, possibly inside the reset dialog, and swapping the whole
  /// app in under their fingers is worse than letting them press "Erneut
  /// versuchen" — which is quick, because the slow part is done by then.
  Future<void> _disposeWhenSettled(
    ProviderContainer container,
    Future<void> warmingUp,
  ) async {
    try {
      await warmingUp;
      AppLogger.app.warning('The overrunning start finished after all');
    } catch (error, stackTrace) {
      AppLogger.app.error(
        'The overrunning start failed in the end',
        error,
        stackTrace,
      );
    }
    // Gone from the list means a reset already closed it; disposing a second
    // time is not this method's job.
    if (_overrunning.remove(container)) container.dispose();
  }

  Future<void> _reset() async {
    // Off the error screen first: deleting the file is asynchronous, and the
    // buttons would otherwise stay live long enough to start a second attempt
    // alongside this one.
    setState(() => _phase = _Phase.loading);

    // A start that overran the timeout still holds the file open. Deleting it
    // underneath a live connection would leave that connection writing to an
    // unlinked file while the next attempt creates a new one at the same path
    // — and the journal files next to it are named after the path, not the
    // file. Here it is safe to cut the start short: the user has just chosen
    // to discard the data it was migrating.
    for (final container in _overrunning) {
      container.dispose();
    }
    _overrunning.clear();

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
      _Phase.error => StartupErrorScreen(
        onRetry: _attempt,
        onReset: _reset,
        message: _errorMessage,
      ),
      _Phase.ready => UncontrolledProviderScope(
        container: _container!,
        child: const PeakHabitApp(),
      ),
    };
  }
}
