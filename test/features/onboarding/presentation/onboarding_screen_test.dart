import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';
import 'package:peakhabit/features/profile/presentation/goal_warning.dart';
import 'package:peakhabit/features/profile/presentation/profile_formatting.dart';

import '../../../support/pump_app.dart';

void main() {
  /// Types into a field and lets the frame settle.
  ///
  /// The pump is what makes the difference: the button below reads the field
  /// on rebuild, and a tap that follows `enterText` without one lands on a
  /// button that is still disabled.
  Future<void> enterText(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    await tester.enterText(find.widgetWithText(TextField, label), value);
    await tester.pumpAndSettle();
  }

  Future<void> tapWeiter(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Weiter'));
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
  }

  Future<void> tapFertig(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Fertig'));
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
  }

  /// Closes the warning dialog a hard rate or a low target puts up.
  Future<void> acknowledge(WidgetTester tester) async {
    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();
  }

  Future<void> fillUpToCalorieStep(
    WidgetTester tester, {
    required String username,
    required String goal,
    required String heightCm,
    required String weightKg,
  }) async {
    await tapWeiter(tester); // welcome
    await enterText(tester, 'Benutzername', username);
    await tapWeiter(tester);
    await tester.tap(find.text(goal));
    await tester.pumpAndSettle();
    await tapWeiter(tester);
    await enterText(tester, 'Größe', heightCm);
    await tapWeiter(tester);
    await enterText(tester, 'Aktuelles Gewicht', weightKg);
    await tapWeiter(tester);
  }

  group('the goal step', () {
    /// Walks to the goal step, which is the third of the flow.
    Future<void> openGoalStep(WidgetTester tester) async {
      await tapWeiter(tester); // welcome
      await enterText(tester, 'Benutzername', 'ben');
      await tapWeiter(tester);
    }

    testWidgets('offers all eight rates, not the three old directions', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(onboardingCompleted: false));

      await openGoalStep(tester);

      for (final goal in WeightGoal.values) {
        expect(find.text(goal.label), findsOneWidget, reason: 'for $goal');
      }
      // The picker spells the rate out — the bare directions are gone.
      expect(find.text('Abnehmen'), findsNothing);
      expect(find.text('Zunehmen'), findsNothing);
    });

    testWidgets('warns at a hard rate and lets the flow go on', (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);
      await openGoalStep(tester);

      await tester.tap(find.text(WeightGoal.lose1000.label));
      await tester.pumpAndSettle();

      expect(find.text(GoalWarning.deficitTooHigh.message), findsOneWidget);

      await acknowledge(tester);
      await tapWeiter(tester);

      // The rate survives the dialog, and the step is behind us.
      expect(find.text('Größe'), findsOneWidget);
    });

    testWidgets('stays quiet at a rate that is not a hard one', (tester) async {
      await pumpApp(tester, on: storesWith(onboardingCompleted: false));
      await openGoalStep(tester);

      await tester.tap(find.text(WeightGoal.lose500.label));
      await tester.pumpAndSettle();

      expect(find.text('Verstanden'), findsNothing);
    });
  });

  testWidgets('appears on the first start', (tester) async {
    await pumpApp(tester, on: storesWith(onboardingCompleted: false));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Kurz einrichten'), findsOneWidget);
  });

  testWidgets('does not appear once already completed', (tester) async {
    await pumpApp(tester, on: storesWith(onboardingCompleted: true));

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('keeps "Weiter" disabled until the current step is filled in', (
    tester,
  ) async {
    await pumpApp(tester, on: storesWith(onboardingCompleted: false));

    await tapWeiter(tester); // welcome -> username

    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Weiter'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await enterText(tester, 'Benutzername', 'ben');

    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Weiter'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'completing the flow with a manual calorie target saves the profile, '
    'the weight entry and marks onboarding as done',
    (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);

      await fillUpToCalorieStep(
        tester,
        username: 'ben',
        goal: 'Abnehmen, 0,5 kg pro Woche',
        heightCm: '180',
        weightKg: '82,5',
      );
      await tester.tap(find.text('Ja, ich gebe es ein'));
      await tester.pumpAndSettle();
      await enterText(tester, 'Kalorienziel', '2200');
      await tapFertig(tester);

      expect(stores.profile.profile.username, 'ben');
      expect(stores.profile.profile.heightCm, 180);
      expect(stores.profile.profile.goal, WeightGoal.lose500);
      expect(stores.profile.profile.calorieTarget, 2200);
      expect(stores.bodyWeight.entries, hasLength(1));
      expect(stores.bodyWeight.entries.single.weightKg, 82.5);
      expect(await stores.settings.readOnboardingCompleted(), isTrue);

      // The router-driven app takes over once onboarding is done.
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Hallo, ben!'), findsOneWidget);
    },
  );

  testWidgets(
    'body data that calculates to a non-positive target says so instead of '
    'offering a "Fertig" that cannot go through',
    (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);

      // Height mistyped as 1 rather than 170. With 60 kg, sedentary, female
      // and a deficit the formula lands at −146 kcal — a target the profile
      // refuses, so completing on it used to throw out of `_finish` unseen
      // and leave this flow, which cannot be skipped, permanently stuck.
      await fillUpToCalorieStep(
        tester,
        username: 'ben',
        goal: 'Abnehmen, 0,5 kg pro Woche',
        heightCm: '1',
        weightKg: '60',
      );
      await tester.tap(find.text('Nein, für mich berechnen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('weiblich'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Auswählen'));
      await tester.tap(find.text('Auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sitzend, kaum Bewegung'));
      await tester.tap(find.text('Sitzend, kaum Bewegung'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('kein sinnvolles Kalorienziel'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: find.text('Fertig'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );
      // Nothing written, and the flow is still up rather than wedged.
      expect(await stores.settings.readOnboardingCompleted(), isFalse);
      expect(stores.bodyWeight.entries, isEmpty);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );

  testWidgets(
    'warns on the way out when the calculated target lands under the basal '
    'rate, and completes anyway',
    (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);

      // 180 cm and 80 kg at 30 make a basal rate of 1780 kcal. Sedentary that
      // is 2136, and half a kilo a week off leaves 1636 — under what the body
      // burns lying still, at a rate that earns no word of its own.
      await fillUpToCalorieStep(
        tester,
        username: 'ben',
        goal: 'Abnehmen, 0,5 kg pro Woche',
        heightCm: '180',
        weightKg: '80',
      );
      await tester.tap(find.text('Nein, für mich berechnen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('männlich'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Auswählen'));
      await tester.tap(find.text('Auswählen'));
      await tester.pumpAndSettle();
      // The picker opens on thirty years back, which is the age above.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sitzend, kaum Bewegung'));
      await tester.tap(find.text('Sitzend, kaum Bewegung'));
      await tester.pumpAndSettle();
      await tapFertig(tester);

      expect(find.text(GoalWarning.belowBasalRate.message), findsOneWidget);
      // Nothing is written while the dialog is up — this is the last moment
      // the user can still go back and change something.
      expect(await stores.settings.readOnboardingCompleted(), isFalse);

      await acknowledge(tester);

      expect(stores.profile.profile.calorieTarget, 1636);
      expect(await stores.settings.readOnboardingCompleted(), isTrue);
    },
  );

  testWidgets(
    'stays quiet about the basal rate once the target is typed by hand, even '
    'after a look at the calculator',
    (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);

      await fillUpToCalorieStep(
        tester,
        username: 'ben',
        goal: 'Abnehmen, 0,5 kg pro Woche',
        heightCm: '180',
        weightKg: '80',
      );
      // A look at the calculator first — this is what leaves sex, birth date
      // and activity level behind in the state.
      await tester.tap(find.text('Nein, für mich berechnen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('männlich'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Auswählen'));
      await tester.tap(find.text('Auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sitzend, kaum Bewegung'));
      await tester.tap(find.text('Sitzend, kaum Bewegung'));
      await tester.pumpAndSettle();

      // Then a change of mind: a target of their own, well above the basal
      // rate the calculation would have landed under.
      await tester.tap(find.text('Ja, ich gebe es ein'));
      await tester.pumpAndSettle();
      await enterText(tester, 'Kalorienziel', '2500');
      await tapFertig(tester);

      // The 1636 the calculator would have produced is not what is stored,
      // so it has no business warning about it.
      expect(find.text(GoalWarning.belowBasalRate.message), findsNothing);
      expect(stores.profile.profile.calorieTarget, 2500);
      expect(stores.profile.profile.sex, isNull);
      expect(await stores.settings.readOnboardingCompleted(), isTrue);
    },
  );

  testWidgets(
    'letting the app calculate the calorie target needs sex, birth date and '
    'activity level, since onboarding collects nothing else the calculation '
    'needs',
    (tester) async {
      final stores = storesWith(onboardingCompleted: false);
      await pumpApp(tester, on: stores);

      await fillUpToCalorieStep(
        tester,
        username: 'ben',
        goal: 'Gewicht halten',
        heightCm: '180',
        weightKg: '82,5',
      );
      await tester.tap(find.text('Nein, für mich berechnen'));
      await tester.pumpAndSettle();

      // Not fillable yet: sex, birth date and activity level are still open.
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: find.text('Fertig'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.text('männlich'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Auswählen'));
      await tester.tap(find.text('Auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Mäßig aktiv, 3–4× Sport pro Woche'),
      );
      await tester.tap(find.text('Mäßig aktiv, 3–4× Sport pro Woche'));
      await tester.pumpAndSettle();
      await tapFertig(tester);

      expect(stores.profile.profile.username, 'ben');
      expect(stores.profile.profile.sex, BiologicalSex.male);
      expect(
        stores.profile.profile.activityLevel,
        ActivityLevel.moderatelyActive,
      );
      expect(stores.profile.profile.calorieTarget, isNotNull);
      expect(await stores.settings.readOnboardingCompleted(), isTrue);
      expect(find.byType(OnboardingScreen), findsNothing);
    },
  );
}
