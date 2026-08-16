import 'package:flutter/widgets.dart';

import 'app_logger.dart';

/// Logs every foreground/background/inactive transition of the app via
/// [AppLogger.lifecycle].
///
/// Wrap it around the routed content, e.g. in `MaterialApp.router`'s
/// `builder`, so it observes the same [WidgetsBinding] as the rest of the
/// app for as long as the app runs.
class AppLifecycleLogger extends StatefulWidget {
  const AppLifecycleLogger({required this.child, super.key});

  final Widget child;

  @override
  State<AppLifecycleLogger> createState() => _AppLifecycleLoggerState();
}

class _AppLifecycleLoggerState extends State<AppLifecycleLogger>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.lifecycle.info('App lifecycle state changed to $state');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
