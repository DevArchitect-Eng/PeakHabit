import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/logging/app_logger.dart';

import '../../support/pump_app.dart';

void main() {
  late List<LogEntry> captured;

  setUp(() {
    captured = [];
    AppLogger.output = captured.add;
  });

  tearDown(() {
    AppLogger.output = (_) {};
  });

  testWidgets('logs the new route when switching tabs', (tester) async {
    await pumpApp(tester);

    captured.clear();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Training'));
    await tester.pumpAndSettle();

    expect(
      captured.any(
        (entry) =>
            entry.component == 'routing' && entry.message.contains('/training'),
      ),
      isTrue,
    );
  });
}
