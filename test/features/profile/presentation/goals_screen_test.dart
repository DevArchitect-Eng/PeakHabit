import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/body_weight/domain/body_weight_entry.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/goals_screen.dart';

import '../../../support/pump_app.dart';

void main() {
  Future<void> openGoals(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Optionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ziele'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Speichern'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
  }

  /// Picks [option] from the dropdown currently showing [shown].
  Future<void> pick(
    WidgetTester tester, {
    required String shown,
    required String option,
  }) async {
    await tester.tap(find.text(shown));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  final first = BodyWeightEntry(date: DateTime(2026, 8, 12), weightKg: 82);
  final latest = BodyWeightEntry(date: DateTime(2026, 8, 18), weightKg: 81.4);

  testWidgets('opens from the settings tab', (tester) async {
    await pumpApp(tester);

    await openGoals(tester);

    expect(find.byType(GoalsScreen), findsOneWidget);
  });

  group('the weight summary', () {
    testWidgets('shows the first entry and the most recent one', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [first, latest]));

      await openGoals(tester);

      expect(find.text('Startgewicht (12.08.2026)'), findsOneWidget);
      expect(find.text('82 kg'), findsOneWidget);
      expect(find.text('Aktuelles Gewicht (18.08.2026)'), findsOneWidget);
      expect(find.text('81,4 kg'), findsOneWidget);
    });

    testWidgets('the only weighing is both the start and the current one', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntries: [latest]));

      await openGoals(tester);

      expect(find.text('Startgewicht (18.08.2026)'), findsOneWidget);
      expect(find.text('Aktuelles Gewicht (18.08.2026)'), findsOneWidget);
      expect(find.text('81,4 kg'), findsNWidgets(2));
    });

    testWidgets('says when nothing has been recorded yet', (tester) async {
      await pumpApp(tester);

      await openGoals(tester);

      expect(find.text('Startgewicht'), findsOneWidget);
      expect(find.text('Kein Eintrag'), findsNWidgets(2));
    });

    testWidgets('says so when the entries cannot be read at all', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(weightEntriesUnreadable: true));

      await openGoals(tester);

      // Not "weigh yourself" — a failed read is nothing the user can fix by
      // stepping on the scale.
      expect(
        find.text('Die Gewichtseinträge konnten nicht gelesen werden.'),
        findsOneWidget,
      );
      expect(find.text('Kein Eintrag'), findsNothing);
    });
  });

  testWidgets('shows the goal and activity level that are stored', (
    tester,
  ) async {
    await pumpApp(
      tester,
      on: storesWith(
        profile: UserProfile(
          goal: WeightGoal.lose,
          activityLevel: ActivityLevel.veryActive,
        ),
      ),
    );

    await openGoals(tester);

    expect(find.text('Abnehmen'), findsOneWidget);
    expect(find.text('Sehr aktiv, 5–6× Sport pro Woche'), findsOneWidget);
  });

  testWidgets('saves a changed goal', (tester) async {
    final stores = await pumpApp(tester);
    await openGoals(tester);

    await pick(tester, shown: 'Gewicht halten', option: 'Abnehmen');
    await tapSave(tester);

    expect(stores.profile.profile.goal, WeightGoal.lose);
    expect(find.text('Ziele gespeichert'), findsOneWidget);
  });

  testWidgets('saves a changed activity level', (tester) async {
    final stores = await pumpApp(tester);
    await openGoals(tester);

    await pick(
      tester,
      shown: 'Keine Angabe',
      option: 'Mäßig aktiv, 3–4× Sport pro Woche',
    );
    await tapSave(tester);

    expect(
      stores.profile.profile.activityLevel,
      ActivityLevel.moderatelyActive,
    );
  });

  testWidgets('clears the activity level again', (tester) async {
    final stores = await pumpApp(
      tester,
      on: storesWith(
        profile: UserProfile(activityLevel: ActivityLevel.veryActive),
      ),
    );
    await openGoals(tester);

    await pick(
      tester,
      shown: 'Sehr aktiv, 5–6× Sport pro Woche',
      option: 'Keine Angabe',
    );
    await tapSave(tester);

    expect(stores.profile.profile.activityLevel, isNull);
  });

  testWidgets('leaves the rest of the profile alone', (tester) async {
    final stored = UserProfile(
      username: 'mila',
      heightCm: 182,
      sex: BiologicalSex.female,
      birthDate: DateTime(1996, 4, 2),
      calorieTarget: 2200,
    );
    final stores = await pumpApp(tester, on: storesWith(profile: stored));
    await openGoals(tester);

    await pick(tester, shown: 'Gewicht halten', option: 'Zunehmen');
    await tapSave(tester);

    final saved = stores.profile.profile;
    expect(saved.goal, WeightGoal.gain);
    expect(saved.username, 'mila');
    expect(saved.heightCm, 182);
    expect(saved.sex, BiologicalSex.female);
    expect(saved.birthDate, DateTime(1996, 4, 2));
    expect(saved.calorieTarget, 2200);
    expect(saved.macros, stored.macros);
  });
}
