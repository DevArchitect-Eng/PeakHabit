import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/nutrition_targets_screen.dart';

import '../../../support/pump_app.dart';

void main() {
  Future<void> openNutritionTargets(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ziele'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ernährungsziele'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ernährungsziele'));
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

  Future<void> enter(WidgetTester tester, String label, String value) async {
    await tester.ensureVisible(find.widgetWithText(TextFormField, label));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, label), value);
    await tester.pumpAndSettle();
  }

  testWidgets('opens from the goals screen', (tester) async {
    await pumpApp(tester);

    await openNutritionTargets(tester);

    expect(find.byType(NutritionTargetsScreen), findsOneWidget);
  });

  testWidgets('shows the targets that are already stored', (tester) async {
    await pumpApp(
      tester,
      on: storesWith(
        profile: UserProfile(
          calorieTarget: 2200,
          macros: MacroDistribution(
            carbPercent: 45,
            proteinPercent: 30,
            fatPercent: 25,
          ),
        ),
      ),
    );

    await openNutritionTargets(tester);

    expect(find.widgetWithText(TextFormField, '2200'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '45'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '30'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '25'), findsOneWidget);
  });

  testWidgets('saves a changed calorie target', (tester) async {
    final stores = await pumpApp(tester);
    await openNutritionTargets(tester);

    await enter(tester, 'Kalorienziel', '2400');
    await tapSave(tester);

    expect(stores.profile.profile.calorieTarget, 2400);
    expect(find.text('Ernährungsziele gespeichert'), findsOneWidget);
  });

  testWidgets('refuses a calorie target of zero instead of storing it', (
    tester,
  ) async {
    final stores = await pumpApp(tester);
    await openNutritionTargets(tester);

    await enter(tester, 'Kalorienziel', '0');
    await tapSave(tester);

    expect(
      find.text('Das Kalorienziel muss größer als 0 sein.'),
      findsOneWidget,
    );
    expect(stores.profile.profile, UserProfile.empty);
  });

  group('the macro split', () {
    testWidgets('saves shares that add up to 100', (tester) async {
      final stores = await pumpApp(tester);
      await openNutritionTargets(tester);

      await enter(tester, 'Kohlenhydrate', '50');
      await enter(tester, 'Eiweiß', '25');
      await enter(tester, 'Fett', '25');
      await tapSave(tester);

      expect(
        stores.profile.profile.macros,
        MacroDistribution(carbPercent: 50, proteinPercent: 25, fatPercent: 25),
      );
    });

    testWidgets('refuses shares that do not add up to 100', (tester) async {
      final stores = await pumpApp(tester);
      await openNutritionTargets(tester);

      await enter(tester, 'Kohlenhydrate', '50');
      await tapSave(tester);

      expect(find.text('Summe: 110 % — muss 100 % ergeben.'), findsOneWidget);
      expect(
        find.text('Die Makroverteilung muss 100 % ergeben.'),
        findsOneWidget,
      );
      expect(stores.profile.profile, UserProfile.empty);
    });

    testWidgets('reports a sum of 100 as it stands', (tester) async {
      await pumpApp(tester);

      await openNutritionTargets(tester);

      expect(find.text('Summe: 100 %'), findsOneWidget);
    });

    testWidgets('refuses an empty share instead of storing it', (tester) async {
      final stores = await pumpApp(tester);
      await openNutritionTargets(tester);

      await enter(tester, 'Fett', '');
      await tapSave(tester);

      expect(find.text('Bitte einen Wert.'), findsOneWidget);
      expect(stores.profile.profile, UserProfile.empty);
    });

    testWidgets('shows what the shares come to in grams', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: UserProfile(
            calorieTarget: 2000,
            macros: MacroDistribution(
              carbPercent: 40,
              proteinPercent: 30,
              fatPercent: 30,
            ),
          ),
        ),
      );

      await openNutritionTargets(tester);
      await tester.ensureVisible(find.text('Ergibt bei 2000 kcal'));
      await tester.pumpAndSettle();

      // 40 % of 2000 kcal is 800 kcal at 4 kcal per gram, 30 % is 600 kcal at
      // 4 and at 9 kcal per gram.
      expect(find.text('200 g'), findsOneWidget);
      expect(find.text('150 g'), findsOneWidget);
      expect(find.text('67 g'), findsOneWidget);
    });

    testWidgets('leaves the grams out while no calorie target is set', (
      tester,
    ) async {
      await pumpApp(tester);

      await openNutritionTargets(tester);

      expect(find.textContaining('Ergibt bei'), findsNothing);
    });
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

    Future<void> scrollToCalculation(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Kalorienziel berechnen'));
      await tester.pumpAndSettle();
    }

    testWidgets('names what it is still missing and where it stands', (
      tester,
    ) async {
      await pumpApp(tester);
      await openNutritionTargets(tester);
      await scrollToCalculation(tester);

      expect(
        find.textContaining('ein Gewichtseintrag, die Größe'),
        findsOneWidget,
      );
      // None of it is entered on this screen, so the note has to say where.
      expect(
        find.textContaining('stehen im Profil, das Aktivitätslevel unter'),
        findsOneWidget,
      );
      expect(find.text('Übernehmen'), findsNothing);
    });

    testWidgets('names the weight entry as the only thing missing', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(profile: calculableProfile()));
      await openNutritionTargets(tester);
      await scrollToCalculation(tester);

      expect(
        find.text('Dafür fehlt noch: ein Gewichtseintrag.'),
        findsOneWidget,
      );
      // Weighing happens on the home screen, not in the profile or the goals.
      expect(find.textContaining('stehen im Profil'), findsNothing);
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
      await openNutritionTargets(tester);
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
      await openNutritionTargets(tester);
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
      await openNutritionTargets(tester);
      await scrollToCalculation(tester);

      expect(find.text('2959 kcal'), findsOneWidget);
    });

    testWidgets('puts the result into the field on demand', (tester) async {
      final stores = storesWith(
        profile: calculableProfile(),
        weightEntries: [weighing],
      );
      await pumpApp(tester, on: stores);
      await openNutritionTargets(tester);
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
      await openNutritionTargets(tester);

      await enter(tester, 'Kalorienziel', '2100');
      await tapSave(tester);

      expect(stores.profile.profile.calorieTarget, 2100);
    });
  });

  testWidgets('leaves the rest of the profile alone', (tester) async {
    final stored = UserProfile(
      username: 'mila',
      heightCm: 182,
      sex: BiologicalSex.female,
      birthDate: DateTime(1996, 4, 2),
      activityLevel: ActivityLevel.veryActive,
      goal: WeightGoal.lose,
    );
    final stores = await pumpApp(tester, on: storesWith(profile: stored));
    await openNutritionTargets(tester);

    await enter(tester, 'Kalorienziel', '2500');
    await tapSave(tester);

    final saved = stores.profile.profile;
    expect(saved.calorieTarget, 2500);
    expect(saved.username, 'mila');
    expect(saved.heightCm, 182);
    expect(saved.sex, BiologicalSex.female);
    expect(saved.birthDate, DateTime(1996, 4, 2));
    expect(saved.activityLevel, ActivityLevel.veryActive);
    expect(saved.goal, WeightGoal.lose);
  });
}
