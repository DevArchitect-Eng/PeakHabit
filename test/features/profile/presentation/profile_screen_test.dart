import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/profile_screen.dart';

import '../../../support/pump_app.dart';
import '../../../support/settings_rows.dart';

void main() {
  Future<void> openProfile(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil bearbeiten'));
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
      on: storesWith(
        profile: UserProfile(
          username: 'mila',
          heightCm: 182,
          sex: BiologicalSex.female,
          birthDate: DateTime(1996, 4, 2),
        ),
      ),
    );

    await openProfile(tester);

    expect(valueOfRow(tester, 'Benutzername'), 'mila');
    expect(valueOfRow(tester, 'Größe'), '182 cm');
    expect(valueOfRow(tester, 'Geschlecht'), 'weiblich');
    expect(valueOfRow(tester, 'Geburtsdatum'), '02.04.1996');
  });

  testWidgets('names what has not been filled in yet', (tester) async {
    await pumpApp(tester);

    await openProfile(tester);

    expect(find.text('Keine Angabe'), findsNWidgets(4));
  });

  testWidgets('a confirmed username is stored right away', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );
    await openProfile(tester);

    await openRow(tester, 'Benutzername');
    await tester.enterText(find.byType(TextField), 'ben');
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    // No save button anywhere — confirming the editor is the whole of it.
    expect(stores.profile.profile.username, 'ben');
    expect(find.text('Speichern'), findsNothing);
  });

  testWidgets('a dropped editor changes nothing', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );
    await openProfile(tester);

    await openRow(tester, 'Benutzername');
    await tester.enterText(find.byType(TextField), 'ben');
    await tester.pumpAndSettle();
    await cancelEditor(tester);

    expect(stores.profile.profile.username, 'mila');
    expect(valueOfRow(tester, 'Benutzername'), 'mila');
  });

  testWidgets('an empty username cannot be confirmed', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(username: 'mila')),
    );
    await openProfile(tester);

    await openRow(tester, 'Benutzername');
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Bitte einen Benutzernamen eingeben.'), findsOneWidget);
    expect(confirmIsOffered(tester), isFalse);

    await cancelEditor(tester);
    expect(stores.profile.profile.username, 'mila');
  });

  testWidgets('a confirmed height is stored right away', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await openRow(tester, 'Größe');
    await tester.enterText(find.byType(TextField), '175');
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    expect(stores.profile.profile.heightCm, 175);
    expect(valueOfRow(tester, 'Größe'), '175 cm');
  });

  testWidgets('a height of zero cannot be confirmed', (tester) async {
    await pumpApp(tester);
    await openProfile(tester);

    await openRow(tester, 'Größe');
    await tester.enterText(find.byType(TextField), '0');
    await tester.pumpAndSettle();

    expect(find.text('Die Größe muss größer als 0 sein.'), findsOneWidget);
    expect(confirmIsOffered(tester), isFalse);
  });

  testWidgets('a confirmed sex is stored right away', (tester) async {
    final stores = await pumpApp(tester);
    await openProfile(tester);

    await openRow(tester, 'Geschlecht');
    await tester.tap(find.text('männlich').last);
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    expect(stores.profile.profile.sex, BiologicalSex.male);
  });

  testWidgets('"Keine Angabe" clears a sex that was set', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(profile: UserProfile(sex: BiologicalSex.female)),
    );
    await openProfile(tester);

    await openRow(tester, 'Geschlecht');
    await tester.tap(
      find.widgetWithText(RadioListTile<BiologicalSex?>, 'Keine Angabe'),
    );
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    expect(stores.profile.profile.sex, isNull);
  });

  testWidgets('leaves the goals and the nutrition targets alone', (
    tester,
  ) async {
    final stored = UserProfile(
      username: 'mila',
      goal: WeightGoal.lose500,
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

    await openRow(tester, 'Größe');
    await tester.enterText(find.byType(TextField), '175');
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    final saved = stores.profile.profile;
    expect(saved.heightCm, 175);
    expect(saved.goal, WeightGoal.lose500);
    expect(saved.activityLevel, ActivityLevel.veryActive);
    expect(saved.calorieTarget, 2000);
    expect(saved.macros, stored.macros);
  });
}
