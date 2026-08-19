import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/domain/macro_distribution.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/nutrition_targets_screen.dart';
import 'package:peakhabit/features/profile/presentation/value_editor.dart';

import '../../../support/pump_app.dart';
import '../../../support/settings_rows.dart';

void main() {
  Future<void> openNutritionTargets(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ziele'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ernährungsziele'));
    await tester.pumpAndSettle();
  }

  /// Types [value] into the field labelled [label] of the open editor.
  Future<void> enter(WidgetTester tester, String label, String value) async {
    await tester.enterText(find.widgetWithText(TextField, label), value);
    await tester.pumpAndSettle();
  }

  UserProfile withMacros(int carb, int protein, int fat, {int? calories}) =>
      UserProfile(
        calorieTarget: calories,
        macros: MacroDistribution(
          carbPercent: carb,
          proteinPercent: protein,
          fatPercent: fat,
        ),
      );

  testWidgets('opens from the goals screen', (tester) async {
    await pumpApp(tester);

    await openNutritionTargets(tester);

    expect(find.byType(NutritionTargetsScreen), findsOneWidget);
  });

  testWidgets('the calorie calculation is no longer shown here', (
    tester,
  ) async {
    await pumpApp(tester);

    await openNutritionTargets(tester);

    // The goals screen keeps the target in step on its own; there is nothing
    // to take over by hand any more.
    expect(find.text('Kalorienziel berechnen'), findsNothing);
    expect(find.text('Übernehmen'), findsNothing);
    expect(find.text('Speichern'), findsNothing);
  });

  testWidgets('shows the targets that are already stored', (tester) async {
    await pumpApp(
      tester,
      on: storesWith(profile: withMacros(45, 30, 25, calories: 2200)),
    );

    await openNutritionTargets(tester);

    expect(valueOfRow(tester, 'Kalorien'), '2200');
    expect(valueOfRow(tester, 'Kohlenhydrate'), '45 %');
    expect(valueOfRow(tester, 'Eiweiß'), '30 %');
    expect(valueOfRow(tester, 'Fett'), '25 %');
  });

  testWidgets('a confirmed calorie target is stored right away', (
    tester,
  ) async {
    final stores = await pumpApp(tester);
    await openNutritionTargets(tester);

    await openRow(tester, 'Kalorien');
    await tester.enterText(find.byType(TextField), '2400');
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    expect(stores.profile.profile.calorieTarget, 2400);
    expect(valueOfRow(tester, 'Kalorien'), '2400');
  });

  testWidgets('a calorie target of zero cannot be confirmed', (tester) async {
    final stores = await pumpApp(tester);
    await openNutritionTargets(tester);

    await openRow(tester, 'Kalorien');
    await tester.enterText(find.byType(TextField), '0');
    await tester.pumpAndSettle();

    expect(
      find.text('Das Kalorienziel muss größer als 0 sein.'),
      findsOneWidget,
    );
    expect(confirmIsOffered(tester), isFalse);

    await cancelEditor(tester);
    expect(stores.profile.profile.calorieTarget, isNull);
  });

  group('the macro split', () {
    testWidgets('shows what the shares come to in grams', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(profile: withMacros(40, 30, 30, calories: 2000)),
      );

      await openNutritionTargets(tester);

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

      expect(find.textContaining(' g'), findsNothing);
    });

    testWidgets('a confirmed split is stored right away', (tester) async {
      final stores = await pumpApp(tester);
      await openNutritionTargets(tester);

      await openRow(tester, 'Kohlenhydrate');
      await enter(tester, 'Kohlenhydrate', '50');
      await enter(tester, 'Eiweiß', '25');
      await enter(tester, 'Fett', '25');
      await confirmEditor(tester);

      expect(
        stores.profile.profile.macros,
        MacroDistribution(carbPercent: 50, proteinPercent: 25, fatPercent: 25),
      );
    });

    testWidgets('every share opens the same editor', (tester) async {
      await pumpApp(tester);
      await openNutritionTargets(tester);

      // A share cannot be changed on its own without breaking the 100 the
      // three have to add up to, so tapping "Fett" offers all three.
      await openRow(tester, 'Fett');

      expect(find.widgetWithText(TextField, 'Kohlenhydrate'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Eiweiß'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Fett'), findsOneWidget);
    });

    testWidgets('shares that do not add up to 100 cannot be confirmed', (
      tester,
    ) async {
      final stores = await pumpApp(tester);
      await openNutritionTargets(tester);

      await openRow(tester, 'Kohlenhydrate');
      await enter(tester, 'Kohlenhydrate', '50');

      expect(
        find.text(
          'Die drei Anteile müssen zusammen 100 % ergeben (aktuell 110 %).',
        ),
        findsOneWidget,
      );
      expect(confirmIsOffered(tester), isFalse);

      await cancelEditor(tester);
      expect(stores.profile.profile.macros, MacroDistribution.standard);
    });

    testWidgets('an empty share cannot be confirmed either', (tester) async {
      await pumpApp(tester);
      await openNutritionTargets(tester);

      await openRow(tester, 'Kohlenhydrate');
      await enter(tester, 'Fett', '');

      // Not passed off as a zero share: 40 / 30 / nothing would otherwise look
      // like a valid split.
      expect(confirmIsOffered(tester), isFalse);
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

    await openRow(tester, 'Kalorien');
    await tester.enterText(find.byType(TextField), '2500');
    await tester.pumpAndSettle();
    await confirmEditor(tester);

    final saved = stores.profile.profile;
    expect(saved.calorieTarget, 2500);
    expect(saved.username, 'mila');
    expect(saved.heightCm, 182);
    expect(saved.sex, BiologicalSex.female);
    expect(saved.birthDate, DateTime(1996, 4, 2));
    expect(saved.activityLevel, ActivityLevel.veryActive);
    expect(saved.goal, WeightGoal.lose);
  });

  testWidgets('the editor stays usable when the keyboard squeezes it', (
    tester,
  ) async {
    await pumpApp(tester);
    await openNutritionTargets(tester);

    // A small phone with the system text size turned up and the keyboard
    // open: the sheet no longer fits, and has to scroll rather than cut its
    // own error line off.
    tester.view.physicalSize = const Size(375, 667);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();

    await openRow(tester, 'Kohlenhydrate');

    expect(find.byType(EditorSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
