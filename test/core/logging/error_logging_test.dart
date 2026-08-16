import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/core/logging/error_logging.dart';

void main() {
  late List<LogEntry> captured;

  setUp(() {
    captured = [];
    AppLogger.output = captured.add;
  });

  tearDown(() {
    AppLogger.output = (_) {};
  });

  test(
    'logs unhandled Flutter errors and still calls the previous handler',
    () {
      var previousHandlerCalled = false;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (_) => previousHandlerCalled = true;
      addTearDown(() => FlutterError.onError = originalOnError);

      installGlobalErrorLogging();

      final exception = Exception('flutter boom');
      FlutterError.onError!(FlutterErrorDetails(exception: exception));

      expect(previousHandlerCalled, isTrue);
      expect(captured, hasLength(1));
      expect(captured.single.component, 'app');
      expect(captured.single.error, exception);
    },
  );

  test('logs unhandled platform errors and reports them as unhandled', () {
    final originalOnError = PlatformDispatcher.instance.onError;
    addTearDown(() => PlatformDispatcher.instance.onError = originalOnError);

    installGlobalErrorLogging();

    final exception = Exception('platform boom');
    final stackTrace = StackTrace.current;
    final handled = PlatformDispatcher.instance.onError!(exception, stackTrace);

    expect(handled, isFalse);
    expect(captured, hasLength(1));
    expect(captured.single.component, 'app');
    expect(captured.single.error, exception);
    expect(captured.single.stackTrace, stackTrace);
  });
}
