import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/logging/app_lifecycle_logger.dart';
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

  testWidgets('logs app lifecycle state changes', (tester) async {
    await tester.pumpWidget(const AppLifecycleLogger(child: SizedBox.shrink()));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(captured, hasLength(1));
    expect(captured.single.component, 'lifecycle');
    expect(captured.single.message, contains('AppLifecycleState.paused'));
  });

  testWidgets('stops observing once removed from the tree', (tester) async {
    await tester.pumpWidget(const AppLifecycleLogger(child: SizedBox.shrink()));
    await tester.pumpWidget(const SizedBox.shrink());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(captured, isEmpty);
  });
}
