import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/app.dart';
import 'package:peakhabit/core/logging/app_logger.dart';

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
    await tester.pumpWidget(const ProviderScope(child: PeakHabitApp()));
    await tester.pumpAndSettle();

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
