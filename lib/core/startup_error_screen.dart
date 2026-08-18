import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Blocking screen shown when the app could not be brought up — in practice
/// almost always because of the database.
///
/// Two recovery paths, per the product decision on #19: "Erneut versuchen"
/// covers transient causes (e.g. a briefly full disk), "App-Daten
/// zurücksetzen" discards the database file and starts over. The reset only
/// ever runs after an explicit confirmation — the local database is the only
/// copy of the user's data, so losing it by accident is not an option.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.onRetry,
    required this.onReset,
    required this.message,
  });

  /// The start failed outright: opening the database threw.
  static const openFailedMessage = 'Die Datenbank ließ sich nicht öffnen.';

  /// The start neither failed nor finished (see #28). Worded as "no answer"
  /// rather than "broken" on purpose: the open may well still be running, it
  /// just took longer than anyone should stare at an empty screen for.
  static const noResponseMessage = 'Die Datenbank antwortet nicht.';

  final VoidCallback onRetry;
  final VoidCallback onReset;

  /// Which of the two situations above brought the user here.
  final String message;

  @override
  Widget build(BuildContext context) {
    // This screen carries its own MaterialApp: it stands in for the whole app,
    // which at this point has not been built.
    return MaterialApp(
      theme: AppTheme.dark,
      home: _RecoveryBody(onRetry: onRetry, onReset: onReset, message: message),
    );
  }
}

/// The screen's content, below the [MaterialApp] rather than beside it — the
/// confirmation dialog needs a [Navigator] and `MaterialLocalizations` above
/// the context it is opened from.
class _RecoveryBody extends StatelessWidget {
  const _RecoveryBody({
    required this.onRetry,
    required this.onReset,
    required this.message,
  });

  final VoidCallback onRetry;
  final VoidCallback onReset;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'PeakHabit konnte nicht gestartet werden.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Erneut versuchen'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _confirmReset(context),
                  child: const Text('App-Daten zurücksetzen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App-Daten zurücksetzen?'),
        content: const Text(
          'Alle gespeicherten Daten werden unwiderruflich gelöscht und die '
          'App startet mit einer leeren Datenbank neu.',
        ),
        // Both actions are text buttons: the app-wide FilledButton style is a
        // full-width one for forms, which would blow up the dialog's action
        // row and push the buttons onto separate lines.
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onReset();
  }
}
