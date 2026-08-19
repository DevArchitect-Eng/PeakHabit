import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/goal_warning.dart';
import 'package:peakhabit/features/profile/presentation/goals_screen.dart';
import 'package:peakhabit/features/profile/presentation/setting_row.dart';

import '../../../support/pump_app.dart';
import '../../../support/settings_rows.dart';

void main() {
  Future<void> openGoals(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ziele'));
    await tester.pumpAndSettle();
  }

  /// Picks [option] in the editor the row labelled [label] opens.
  Future<void> pick(
    WidgetTester tester, {
    required String row,
    required String option,
  }) async {
    await openRow(tester, row);
    // The last match is the one in the sheet — the row behind it may well
    // show the same wording as its current value.
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
    await confirmEditor(tester);
  }

  /// Closes the warning dialog a hard rate or a low target puts up.
  Future<void> acknowledge(WidgetTester tester) async {
    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();
  }

  final first = BodyWeightEntry(date: DateTime(2026, 8, 12), weightKg: 82);
  final latest = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 81.4);

  /// A profile the calorie calculation has everything for.
  ///
  /// The age is counted against the current date, so the birth date is set
  /// relative to it: the first of January thirty years back is thirty on every
  /// day of the year.
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

  testWidgets('opens from the settings tab', (tester) async {
    await pumpApp(tester);

    await openGoals(tester);

    expect(find.byType(GoalsScreen), findsOneWidget);
  });

  group('the weights', () {
    testWidgets('report the first entry with its date and the latest one', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [first, latest]));

      await openGoals(tester);

      expect(valueOfRow(tester, 'Startgewicht'), '82 kg am 12.08.26');
      expect(valueOfRow(tester, 'Aktuelles Gewicht'), '81,4 kg');
    });

    testWidgets('cannot be edited from here', (tester) async {
      await pumpApp(tester, on: storesWith(weightEntries: [first, latest]));

      await openGoals(tester);
      await tester.tap(find.widgetWithText(SettingRow, 'Startgewicht'));
      await tester.pumpAndSettle();

      // Weighing happens on the home screen; a tap here opens nothing.
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('say when nothing has been recorded yet', (tester) async {
      await pumpApp(tester);

      await openGoals(tester);

      expect(valueOfRow(tester, 'Startgewicht'), 'Kein Eintrag');
      expect(valueOfRow(tester, 'Aktuelles Gewicht'), 'Kein Eintrag');
    });

    testWidgets('tell a failed read apart from an empty series', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntriesUnreadable: true));

      await openGoals(tester);

      // Not "no entry" — the user has no way to fix a failed read by stepping
      // on the scale.
      expect(valueOfRow(tester, 'Startgewicht'), 'Nicht lesbar');
      expect(valueOfRow(tester, 'Aktuelles Gewicht'), 'Nicht lesbar');
    });
  });

  testWidgets('shows the goal and activity level that are stored', (
    tester,
  ) async {
    await pumpApp(
      tester,
      on: storesWith(
        profile: UserProfile(
          goal: WeightGoal.lose500,
          activityLevel: ActivityLevel.veryActive,
        ),
      ),
    );

    await openGoals(tester);

    // Both rows show the short form; the picker spells them out.
    expect(valueOfRow(tester, 'Ziel'), '−0,5 kg/Woche');
    expect(valueOfRow(tester, 'Aktivitätslevel'), 'Sehr aktiv');
  });

  testWidgets('a confirmed goal is stored right away', (tester) async {
    final stores = await pumpApp(tester);
    await openGoals(tester);

    await pick(tester, row: 'Ziel', option: 'Abnehmen, 0,5 kg pro Woche');

    expect(stores.profile.profile.goal, WeightGoal.lose500);
    expect(find.text('Speichern'), findsNothing);
  });

  testWidgets('a dropped editor changes nothing', (tester) async {
    final stores = await pumpApp(tester);
    await openGoals(tester);

    await openRow(tester, 'Ziel');
    await tester.tap(find.text('Abnehmen, 0,5 kg pro Woche').last);
    await tester.pumpAndSettle();
    await cancelEditor(tester);

    expect(stores.profile.profile.goal, WeightGoal.maintain);
  });

  testWidgets('a confirmed activity level is stored right away', (
    tester,
  ) async {
    final stores = await pumpApp(tester);
    await openGoals(tester);

    await pick(
      tester,
      row: 'Aktivitätslevel',
      option: 'Mäßig aktiv, 3–4× Sport pro Woche',
    );

    expect(
      stores.profile.profile.activityLevel,
      ActivityLevel.moderatelyActive,
    );
  });

  testWidgets('"Keine Angabe" clears the activity level again', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(
        profile: UserProfile(activityLevel: ActivityLevel.veryActive),
      ),
    );
    await openGoals(tester);

    await pick(tester, row: 'Aktivitätslevel', option: 'Keine Angabe');

    expect(stores.profile.profile.activityLevel, isNull);
  });

  group('the calorie target follows', () {
    testWidgets('a changed goal', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile().copyWith(calorieTarget: 2000),
          weightEntries: [weighing],
        ),
      );
      await openGoals(tester);

      await pick(tester, row: 'Ziel', option: 'Abnehmen, 0,5 kg pro Woche');

      // 10 × 80 + 6.25 × 180 − 5 × 30 + 5 = 1780, × 1.55 = 2759, − 500.
      expect(stores.profile.profile.calorieTarget, 2259);
      expect(find.text('Kalorienziel auf 2259 kcal angepasst'), findsOneWidget);
    });

    testWidgets('a changed activity level', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile().copyWith(calorieTarget: 2000),
          weightEntries: [weighing],
        ),
      );
      await openGoals(tester);

      await pick(
        tester,
        row: 'Aktivitätslevel',
        option: 'Sitzend, kaum Bewegung',
      );

      // The same 1780, × 1.2 this time.
      expect(stores.profile.profile.calorieTarget, 2136);
    });

    testWidgets('but not when the picker only confirms what was set', (
      tester,
    ) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile().copyWith(calorieTarget: 2000),
          weightEntries: [weighing],
        ),
      );
      await openGoals(tester);

      // Opening the picker to look at the goal and confirming it must not
      // cost the user the target they typed themselves.
      await pick(tester, row: 'Ziel', option: 'Gewicht halten');

      expect(stores.profile.profile.calorieTarget, 2000);
      expect(find.textContaining('Kalorienziel auf'), findsNothing);
    });

    testWidgets('but stays put while the calculation is short of something', (
      tester,
    ) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          // No weight entry, so there is nothing to calculate from.
          profile: calculableProfile().copyWith(calorieTarget: 2000),
        ),
      );
      await openGoals(tester);

      await pick(tester, row: 'Ziel', option: 'Abnehmen, 0,5 kg pro Woche');

      expect(stores.profile.profile.goal, WeightGoal.lose500);
      expect(stores.profile.profile.calorieTarget, 2000);
      expect(find.textContaining('Kalorienziel auf'), findsNothing);
    });
  });

  group('the warning', () {
    testWidgets('comes up on the steepest deficit', (tester) async {
      final stores = await pumpApp(tester);
      await openGoals(tester);

      await pick(tester, row: 'Ziel', option: 'Abnehmen, 1 kg pro Woche');

      expect(find.text(GoalWarning.deficitTooHigh.message), findsOneWidget);
      // Informing, not blocking: the rate is stored either way.
      expect(stores.profile.profile.goal, WeightGoal.lose1000);
      await acknowledge(tester);
      expect(find.text(GoalWarning.deficitTooHigh.message), findsNothing);
    });

    testWidgets('comes up on the steepest surplus', (tester) async {
      await pumpApp(tester);
      await openGoals(tester);

      await pick(tester, row: 'Ziel', option: 'Zunehmen, 0,8 kg pro Woche');

      expect(find.text(GoalWarning.surplusTooHigh.message), findsOneWidget);
      await acknowledge(tester);
    });

    testWidgets('stays away at a rate that is not a hard one', (tester) async {
      await pumpApp(tester);
      await openGoals(tester);

      await pick(tester, row: 'Ziel', option: 'Abnehmen, 0,5 kg pro Woche');

      expect(find.text('Verstanden'), findsNothing);
    });

    testWidgets('comes up once the target lands under the basal rate', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile().copyWith(
            activityLevel: ActivityLevel.sedentary,
          ),
          weightEntries: [weighing],
        ),
      );
      await openGoals(tester);

      // 1780 × 1.2 = 2136, minus 500 is 1636 — under the 1780 basal rate, at
      // a rate that earns no word of its own.
      await pick(tester, row: 'Ziel', option: 'Abnehmen, 0,5 kg pro Woche');

      expect(find.text(GoalWarning.belowBasalRate.message), findsOneWidget);
      expect(find.text(GoalWarning.deficitTooHigh.message), findsNothing);
      await acknowledge(tester);
    });

    testWidgets('carries both points in one dialog when both apply', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: calculableProfile().copyWith(
            activityLevel: ActivityLevel.sedentary,
          ),
          weightEntries: [weighing],
        ),
      );
      await openGoals(tester);

      // 2136 − 1000 = 1136, well under the basal rate, at the steepest rate.
      await pick(tester, row: 'Ziel', option: 'Abnehmen, 1 kg pro Woche');

      expect(find.text(GoalWarning.deficitTooHigh.message), findsOneWidget);
      expect(find.text(GoalWarning.belowBasalRate.message), findsOneWidget);
      // One dialog for the two of them, not one each.
      expect(find.byType(AlertDialog), findsOneWidget);
      await acknowledge(tester);
    });

    testWidgets(
      'follows a changed activity level under the basal rate, without '
      'repeating the rate the user already picked',
      (tester) async {
        await pumpApp(
          tester,
          on: storesWith(
            profile: calculableProfile(goal: WeightGoal.lose1000),
            weightEntries: [weighing],
          ),
        );
        await openGoals(tester);

        await pick(
          tester,
          row: 'Aktivitätslevel',
          option: 'Sitzend, kaum Bewegung',
        );

        expect(find.text(GoalWarning.belowBasalRate.message), findsOneWidget);
        // The rate did not change here, so it does not get to speak again.
        expect(find.text(GoalWarning.deficitTooHigh.message), findsNothing);
        await acknowledge(tester);
      },
    );
  });

  testWidgets('leaves the rest of the profile alone', (tester) async {
    final stored = UserProfile(
      username: 'mila',
      heightCm: 182,
      sex: BiologicalSex.female,
      birthDate: DateTime(1996, 4, 2),
    );
    final stores = await pumpApp(tester, on: storesWith(profile: stored));
    await openGoals(tester);

    await pick(tester, row: 'Ziel', option: 'Zunehmen, 0,2 kg pro Woche');

    final saved = stores.profile.profile;
    expect(saved.goal, WeightGoal.gain200);
    expect(saved.username, 'mila');
    expect(saved.heightCm, 182);
    expect(saved.sex, BiologicalSex.female);
    expect(saved.birthDate, DateTime(1996, 4, 2));
    expect(saved.macros, stored.macros);
  });
}
