import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/database/app_database.dart';
import 'package:peakhabit/core/database/database_provider.dart';
import 'package:peakhabit/core/logging/app_logger.dart';
import 'package:peakhabit/core/startup_error_screen.dart';
import 'package:peakhabit/core/startup_gate.dart';
import 'package:peakhabit/features/profile/data/user_profile_providers.dart';
import 'package:peakhabit/features/settings/data/settings_providers.dart';

import '../support/in_memory_settings_repository.dart';
import '../support/in_memory_user_profile_repository.dart';

/// A database that only decides whether opening works — it never runs a query.
///
/// [open] deliberately does not call `super.open()`: driving the real drift
/// database from inside the fake-async zone of `testWidgets` hangs instead of
/// finishing, which is the same reason the repositories below are in-memory
/// ones. Nothing here needs a working database, because the repositories that
/// would query it are replaced.
class _FakeDatabase extends AppDatabase {
  _FakeDatabase() : super.inMemory();

  /// Whether the next [open] succeeds. Starts out failing, which is the
  /// situation the recovery screen exists for.
  bool succeed = false;

  @override
  Future<void> open() async {
    if (!succeed) throw Exception('database is broken');
  }

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() {
    AppLogger.output = (_) {};
  });

  /// One startup attempt's container, wired like the running app but on stores
  /// that a widget test can drive.
  ProviderContainer buildContainer(_FakeDatabase database) {
    final settings = InMemorySettingsRepository();
    final profile = InMemoryUserProfileRepository();
    addTearDown(settings.dispose);
    addTearDown(profile.dispose);

    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingsRepositoryProvider.overrideWithValue(settings),
        userProfileRepositoryProvider.overrideWithValue(profile),
      ],
    );
  }

  testWidgets('shows the recovery screen when the database fails to open', (
    tester,
  ) async {
    final database = _FakeDatabase();

    await tester.pumpWidget(
      StartupGate(containerBuilder: () => buildContainer(database)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StartupErrorScreen), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(find.text('App-Daten zurücksetzen'), findsOneWidget);
  });

  testWidgets('retrying opens the app once the database works again', (
    tester,
  ) async {
    final database = _FakeDatabase();

    await tester.pumpWidget(
      StartupGate(containerBuilder: () => buildContainer(database)),
    );
    await tester.pumpAndSettle();

    database.succeed = true;
    await tester.tap(find.text('Erneut versuchen'));
    await tester.pumpAndSettle();

    expect(find.byType(StartupErrorScreen), findsNothing);
    expect(find.text('Startseite'), findsOneWidget);
  });

  testWidgets('cancelling the reset dialog leaves the recovery screen up', (
    tester,
  ) async {
    final database = _FakeDatabase();
    var deleteCalled = false;

    await tester.pumpWidget(
      StartupGate(
        containerBuilder: () => buildContainer(database),
        deleteDatabase: () async => deleteCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('App-Daten zurücksetzen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.byType(StartupErrorScreen), findsOneWidget);
  });

  testWidgets('confirming the reset deletes the database and retries', (
    tester,
  ) async {
    final database = _FakeDatabase();
    var deleteCalled = false;

    await tester.pumpWidget(
      StartupGate(
        containerBuilder: () => buildContainer(database),
        deleteDatabase: () async {
          deleteCalled = true;
          // A fresh file would open cleanly; the fake stands in for that.
          database.succeed = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('App-Daten zurücksetzen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.byType(StartupErrorScreen), findsNothing);
    expect(find.text('Startseite'), findsOneWidget);
  });
}
