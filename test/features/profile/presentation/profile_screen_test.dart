import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
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
      on: storesWith(
        profile: UserProfile(
          username: 'mila',
          heightCm: 182,
          calorieTarget: 2200,
        ),
      ),
    );

    await openProfile(tester);

    expect(find.widgetWithText(TextFormField, 'mila'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '182'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '2200'), findsOneWidget);
  });

  testWidgets('saves a changed username, height and calorie target', (
    tester,
  ) async {
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kalorienziel'),
      '2400',
    );
    await tapSave(tester);

    expect(stores.profile.profile.username, 'ben');
    expect(stores.profile.profile.heightCm, 175);
    expect(stores.profile.profile.calorieTarget, 2400);
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

  group('calorie calculation', () {
    /// A profile the calculation has everything for, save the weight entry.
    ///
    /// The screen counts the age against the current date, so the birth date
    /// is set relative to it: the first of January thirty years back is thirty
    /// on every day of the year, while a fixed date would age the profile out
    /// of the expected numbers.
    UserProfile calculableProfile({WeightGoal goal = WeightGoal.maintain}) =>
        UserProfile(
          username: 'mila',
          heightCm: 180,
          sex: BiologicalSex.male,
          birthDate: DateTime(DateTime.now().year - 30, 1, 1),
          activityLevel: ActivityLevel.moderatelyActive,
          goal: goal,
        );

    final weighing = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 80);

    /// The calculation sits below the fold of the test window.
    Future<void> scrollToCalculation(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Kalorienziel berechnen'));
      await tester.pumpAndSettle();
    }

    testWidgets('names what it is still missing', (tester) async {
      await pumpApp(tester);
      await openProfile(tester);
      await scrollToCalculation(tester);

      expect(
        find.textContaining('ein Gewichtseintrag, die Größe'),
        findsOneWidget,
      );
      expect(find.text('Übernehmen'), findsNothing);
    });

    testWidgets('names the weight entry as the only thing missing', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(profile: calculableProfile()));
      await openProfile(tester);
      await scrollToCalculation(tester);

      expect(
        find.text('Dafür fehlt noch: ein Gewichtseintrag.'),
        findsOneWidget,
      );
    });

    testWidgets('says so when the entries cannot be read at all', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile(),
          weightEntriesUnreadable: true,
        ),
      );
      await openProfile(tester);
      await scrollToCalculation(tester);

      // Not "make an entry" — the user has no way to fix a failed read by
      // stepping on the scale.
      expect(
        find.text('Das letzte Gewicht konnte nicht gelesen werden.'),
        findsOneWidget,
      );
    });

    testWidgets('shows every step of the calculation', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile(goal: WeightGoal.lose),
          weightEntries: [weighing],
        ),
      );
      await openProfile(tester);
      await scrollToCalculation(tester);

      // 10 × 80 + 6.25 × 180 − 5 × 30 + 5 = 1780, × 1.55 = 2759, − 500.
      expect(find.text('80 kg'), findsOneWidget);
      expect(find.text('1780 kcal'), findsOneWidget);
      expect(find.text('Aktivität (× 1,55)'), findsOneWidget);
      expect(find.text('2759 kcal'), findsOneWidget);
      expect(find.text('Abnehmen (−500 g pro Woche)'), findsOneWidget);
      expect(find.text('−500 kcal'), findsOneWidget);
      expect(find.text('2259 kcal'), findsOneWidget);
    });

    testWidgets('follows the goal stored on the goals screen', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile(goal: WeightGoal.gain),
          weightEntries: [weighing],
        ),
      );
      await openProfile(tester);
      await scrollToCalculation(tester);

      expect(find.text('2959 kcal'), findsOneWidget);
    });

    testWidgets('puts the result into the field on demand', (tester) async {
      final stores = storesWith(
        profile: calculableProfile(),
        weightEntries: [weighing],
      );
      await pumpApp(tester, on: stores);
      await openProfile(tester);
      await scrollToCalculation(tester);

      await tester.tap(find.text('Übernehmen'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, '2759'), findsOneWidget);
      // Taking it over is not saving it — that stays the user's own step.
      expect(stores.profile.profile.calorieTarget, isNull);

      await tapSave(tester);

      expect(stores.profile.profile.calorieTarget, 2759);
    });

    testWidgets('leaves a target entered by hand alone', (tester) async {
      final stores = storesWith(
        profile: calculableProfile(),
        weightEntries: [weighing],
      );
      await pumpApp(tester, on: stores);
      await openProfile(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kalorienziel'),
        '2100',
      );
      await tapSave(tester);

      expect(stores.profile.profile.calorieTarget, 2100);
    });
  });

  testWidgets('leaves the macro split alone', (tester) async {
    final stored = UserProfile(
      username: 'mila',
      calorieTarget: 2000,
      macros: MacroDistribution(
        proteinPercent: 40,
        carbPercent: 30,
        fatPercent: 30,
      ),
    );
    final stores = storesWith(profile: stored);
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
