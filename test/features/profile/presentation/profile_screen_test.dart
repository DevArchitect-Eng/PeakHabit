import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/profile_screen.dart';

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
    await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila', heightCm: 182)),
    );

    await openProfile(tester);

    expect(find.widgetWithText(TextFormField, 'mila'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '182'), findsOneWidget);
  });

  testWidgets('saves a changed username and height', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );
    await openProfile(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Benutzername'),
      'ben',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '175');
    await tapSave(tester);

    expect(stores.profile.profile.username, 'ben');
    expect(stores.profile.profile.heightCm, 175);
    expect(find.text('Profil gespeichert'), findsOneWidget);
  });

  testWidgets('refuses an empty username instead of storing it', (
    tester,
  ) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );
    await openProfile(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Benutzername'),
      '',
    );
    await tapSave(tester);

    expect(find.text('Bitte einen Benutzernamen eingeben.'), findsOneWidget);
    expect(stores.profile.profile.username, 'mila');
  });

  testWidgets('refuses a height of zero instead of storing it', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '0');
    await tapSave(tester);

    expect(find.text('Die Größe muss größer als 0 sein.'), findsOneWidget);
    expect(stores.profile.profile, UserProfile.empty);
  });

  testWidgets('leaves the goals and the nutrition targets alone', (
    tester,
  ) async {
    final stored = UserProfile(
      username: 'mila',
      goal: WeightGoal.lose,
      activityLevel: ActivityLevel.veryActive,
      calorieTarget: 2000,
      macros: MacroDistribution(
        carbPercent: 30,
        proteinPercent: 40,
        fatPercent: 30,
      ),
    );
    final stores = await pumpApp(tester, on: storesWith(profile: stored));
    await openProfile(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '175');
    await tapSave(tester);

    final saved = stores.profile.profile;
    expect(saved.heightCm, 175);
    expect(saved.goal, WeightGoal.lose);
    expect(saved.activityLevel, ActivityLevel.veryActive);
    expect(saved.calorieTarget, 2000);
    expect(saved.macros, stored.macros);
  });
}
