import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Blocking screen shown when the app could not be brought up — in practice
/// almost always because the database could not be opened.
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
  });

  final VoidCallback onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    // This screen carries its own MaterialApp: it stands in for the whole app,
    // which at this point has not been built.
    return MaterialApp(
      theme: AppTheme.dark,
      home: _RecoveryBody(onRetry: onRetry, onReset: onReset),
    );
  }
}

/// The screen's content, below the [MaterialApp] rather than beside it — the
/// confirmation dialog needs a [Navigator] and `MaterialLocalizations` above
/// the context it is opened from.
class _RecoveryBody extends StatelessWidget {
  const _RecoveryBody({required this.onRetry, required this.onReset});

  final VoidCallback onRetry;
  final VoidCallback onReset;

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
                const Text(
                  'Die Datenbank ließ sich nicht öffnen.',
                  textAlign: TextAlign.center,
                ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onReset();
  }
}
