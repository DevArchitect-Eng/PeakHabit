import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

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
        goal: 'Abnehmen',
        heightCm: '180',
        weightKg: '82,5',
      );
      await tester.tap(find.text('Ja, ich gebe es ein'));
      await tester.pumpAndSettle();
      await enterText(tester, 'Kalorienziel', '2200');
      await tapFertig(tester);

      expect(stores.profile.profile.username, 'ben');
      expect(stores.profile.profile.heightCm, 180);
      expect(stores.profile.profile.goal, WeightGoal.lose);
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
