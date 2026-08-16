import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/logging/app_logger.dart';

void main() {
  late List<LogEntry> captured;

  setUp(() {
    captured = [];
    AppLogger.output = captured.add;
    AppLogger.minLevel = LogLevel.debug;
  });

  tearDown(() {
    AppLogger.output = (_) {};
    AppLogger.minLevel = LogLevel.debug;
  });

  test('routes each severity through output with the right component', () {
    const logger = AppLogger('test-component');

    logger.debug('debug message');
    logger.info('info message');
    logger.warning('warning message');
    logger.error('error message');

    expect(captured, hasLength(4));
    expect(captured[0].level, LogLevel.debug);
    expect(captured[1].level, LogLevel.info);
    expect(captured[2].level, LogLevel.warning);
    expect(captured[3].level, LogLevel.error);
    expect(
      captured.every((entry) => entry.component == 'test-component'),
      isTrue,
    );
  });

  test('carries the error and stack trace passed to error()', () {
    const logger = AppLogger('test-component');
    final stackTrace = StackTrace.current;

    logger.error('boom', Exception('cause'), stackTrace);

    expect(captured, hasLength(1));
    expect(captured.single.error, isA<Exception>());
    expect(captured.single.stackTrace, stackTrace);
  });

  test('drops entries below minLevel', () {
    AppLogger.minLevel = LogLevel.warning;
    const logger = AppLogger('test-component');

    logger.debug('dropped');
    logger.info('dropped');
    logger.warning('kept');
    logger.error('kept');

    expect(captured, hasLength(2));
    expect(captured.map((e) => e.message), ['kept', 'kept']);
  });
}
