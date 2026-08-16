import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/profile_screen.dart';

import '../../../support/in_memory_settings_repository.dart';
import '../../../support/in_memory_user_profile_repository.dart';
import '../../../support/pump_app.dart';

void main() {
  Future<void> openProfile(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil bearbeiten'));
    await tester.pumpAndSettle();
  }

  /// The button sits below the fold of the test window, so it has to be
  /// scrolled into view before it can be tapped.
  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Speichern'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens from the settings tab', (tester) async {
    await pumpApp(tester);

    await openProfile(tester);

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('shows the values that are already stored', (tester) async {
    final stores = (
      settings: InMemorySettingsRepository(),
      profile: InMemoryUserProfileRepository(
        UserProfile(heightCm: 182, calorieTarget: 2200),
      ),
    );
    addTearDown(stores.settings.dispose);
    addTearDown(stores.profile.dispose);
    await pumpApp(tester, on: stores);

    await openProfile(tester);

    expect(find.widgetWithText(TextFormField, '182'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '2200'), findsOneWidget);
  });

  testWidgets('saves a changed height and calorie target', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '175');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kalorienziel'),
      '2400',
    );
    await tapSave(tester);

    expect(stores.profile.profile.heightCm, 175);
    expect(stores.profile.profile.calorieTarget, 2400);
    expect(find.text('Profil gespeichert'), findsOneWidget);
  });

  testWidgets('saves a changed goal', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await tester.tap(find.text('Gewicht halten'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abnehmen').last);
    await tester.pumpAndSettle();
    await tapSave(tester);

    expect(stores.profile.profile.goal, WeightGoal.lose);
  });

  testWidgets('refuses a height of zero instead of storing it', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '0');
    await tapSave(tester);

    expect(find.text('Die Größe muss größer als 0 sein.'), findsOneWidget);
    expect(stores.profile.profile, UserProfile.empty);
  });

  testWidgets('leaves the macro split alone', (tester) async {
    final stored = UserProfile(
      calorieTarget: 2000,
      macros: MacroDistribution(
        proteinPercent: 40,
        carbPercent: 30,
        fatPercent: 30,
      ),
    );
    final stores = (
      settings: InMemorySettingsRepository(),
      profile: InMemoryUserProfileRepository(stored),
    );
    addTearDown(stores.settings.dispose);
    addTearDown(stores.profile.dispose);
    await pumpApp(tester, on: stores);
    await openProfile(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kalorienziel'),
      '2500',
    );
    await tapSave(tester);

    expect(stores.profile.profile.macros, stored.macros);
  });
}
