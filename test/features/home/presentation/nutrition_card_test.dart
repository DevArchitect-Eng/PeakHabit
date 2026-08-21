import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/home/presentation/body_weight_card.dart';
import 'package:peakhabit/features/home/presentation/nutrition_card.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

import '../../../support/pump_app.dart';

void main() {
  /// Counted from the real today because the card always shows `DateTime.now()`
  /// — a fixed date would drift out of view as soon as the test ran on a later
  /// day.
  DateTime dayBefore(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - days);
  }

  final oats = Food(
    id: 1,
    name: 'Haferflocken',
    nutrientsPer100g: Nutrients(
      kcal: 370,
      proteinGrams: 13,
      carbGrams: 59,
      fatGrams: 7,
    ),
  );

  MealEntry ate(
    Food food, {
    required int daysAgo,
    MealType mealType = MealType.breakfast,
    double grams = 100,
  }) => MealEntry(
    date: dayBefore(daysAgo),
    mealType: mealType,
    item: food,
    grams: grams,
  );

  /// A profile carrying a calorie target, which the standard 30/40/30 split
  /// turns into 150 g protein, 200 g carbohydrates and 66,7 g fat.
  final withTarget = UserProfile(username: 'Max', calorieTarget: 2000);

  group('against the targets from the profile', () {
    testWidgets('puts today against the calorie target', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0)],
        ),
      );

      // 370 kcal of a 2000 kcal day, the eaten figure inside the ring.
      expect(find.text('370'), findsOneWidget);
      expect(find.text('von 2000 kcal'), findsOneWidget);
    });

    testWidgets('puts every macro against its gram target', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0)],
        ),
      );

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Kohlenhydrate'), findsOneWidget);
      expect(find.text('Fett'), findsOneWidget);
      // What has been eaten of each, inside its ring.
      expect(find.text('13 g'), findsOneWidget);
      expect(find.text('59 g'), findsOneWidget);
      expect(find.text('7 g'), findsOneWidget);
    });

    testWidgets('says how much of each is still open', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0)],
        ),
      );

      expect(find.text('1630 kcal übrig'), findsOneWidget);
      expect(find.text('137 g übrig'), findsOneWidget);
      expect(find.text('141 g übrig'), findsOneWidget);
      expect(find.text('60 g übrig'), findsOneWidget);
    });

    testWidgets('names the overrun instead of a negative remainder', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          // 1000 g of a 370 kcal food: 3700 kcal against a target of 2000, and
          // 590 g of carbohydrates against 200.
          mealEntries: [ate(oats, daysAgo: 0, grams: 1000)],
        ),
      );

      expect(find.text('1700 kcal zu viel'), findsOneWidget);
      expect(find.text('390 g zu viel'), findsOneWidget);
      expect(find.text('3 g zu viel'), findsOneWidget);
      // Protein is the one still under its target on that day.
      expect(find.text('20 g übrig'), findsOneWidget);
      expect(find.textContaining('kcal übrig'), findsNothing);
    });

    testWidgets('marks an overrun in colour as well as in words', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 1000)],
        ),
      );

      final scheme = Theme.of(
        tester.element(find.byType(NutritionCard)),
      ).colorScheme;
      final over = tester.widget<Text>(find.text('1700 kcal zu viel'));
      final under = tester.widget<Text>(find.text('20 g übrig'));

      expect(over.style?.color, scheme.tertiary);
      expect(under.style?.color, isNot(scheme.tertiary));
    });

    testWidgets('counts today only, not what was logged on other days', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [
            ate(oats, daysAgo: 0),
            ate(oats, daysAgo: 1, grams: 500),
            ate(oats, daysAgo: 3, grams: 500),
          ],
        ),
      );

      expect(find.text('370'), findsOneWidget);
      expect(find.text('1630 kcal übrig'), findsOneWidget);
    });

    testWidgets('shows a day nothing was logged on as an empty ring', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(profile: withTarget));

      expect(find.text('0'), findsOneWidget);
      expect(find.text('2000 kcal übrig'), findsOneWidget);
    });
  });

  group('without a calorie target', () {
    testWidgets('shows the bare sums and says where the target is set', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(foods: [oats], mealEntries: [ate(oats, daysAgo: 0)]),
      );

      expect(find.textContaining('Noch kein Kalorienziel'), findsOneWidget);
      expect(find.text('370 kcal'), findsOneWidget);
      expect(find.text('P 13 g · KH 59 g · F 7 g'), findsOneWidget);
      // No remainder is invented from a target that is not there.
      expect(find.textContaining('übrig'), findsNothing);
      expect(find.textContaining('von 2000 kcal'), findsNothing);
    });
  });

  group('the card on the home screen', () {
    testWidgets('stands above the weight card', (tester) async {
      await pumpApp(tester, on: storesWith(profile: withTarget));

      expect(
        tester.getTopLeft(find.byType(NutritionCard)).dy,
        lessThan(tester.getTopLeft(find.byType(BodyWeightCard)).dy),
      );
    });

    testWidgets('reports a day that cannot be read', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(profile: withTarget, mealEntriesUnreadable: true),
      );

      expect(
        find.textContaining('Tagessumme konnte nicht geladen werden'),
        findsOneWidget,
      );
      // Not a zero day dressed up as a real one.
      expect(find.text('von 2000 kcal'), findsNothing);
      // The rest of the home screen still stands.
      expect(find.byType(BodyWeightCard), findsOneWidget);
    });
  });
}
