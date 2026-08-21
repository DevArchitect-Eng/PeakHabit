import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

import '../../../support/pump_app.dart';

void main() {
  /// Counted from the real today because the tab opens on `DateTime.now()` —
  /// a fixed date would drift out of view as soon as the test ran on a later
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
    portionGrams: 50,
  );
  final banana = Food(
    id: 2,
    name: 'Banane',
    brand: 'Chiquita',
    nutrientsPer100g: Nutrients(
      kcal: 89,
      proteinGrams: 1,
      carbGrams: 23,
      fatGrams: 0,
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

  /// Opens the nutrition tab, which is where every one of these starts.
  Future<void> openTab(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Ernährung'));
    await tester.pumpAndSettle();
  }

  /// Opens one of the four meals by tapping its row.
  Future<void> openMeal(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// Goes back to the day view.
  ///
  /// Not `tester.pageBack()`: that one looks for the English tooltip, and the
  /// app runs on German localizations only.
  Future<void> goBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  group('the day view', () {
    testWidgets('shows all four meals on a day nothing was logged on', (
      tester,
    ) async {
      await pumpApp(tester);
      await openTab(tester);

      for (final label in const ['Frühstück', 'Mittag', 'Abend', 'Snacks']) {
        expect(find.text(label), findsOneWidget);
      }
      // The empty day reports zero rather than hiding the meals — four of
      // them plus the day's own total.
      expect(find.text('0 kcal'), findsNWidgets(5));
      expect(find.text('Tagessumme'), findsOneWidget);
    });

    testWidgets('adds a meal up and carries it into the day total', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats, banana],
          mealEntries: [
            ate(oats, daysAgo: 0, grams: 100),
            ate(banana, daysAgo: 0, mealType: MealType.snacks, grams: 100),
          ],
        ),
      );
      await openTab(tester);

      expect(find.text('370 kcal'), findsOneWidget);
      expect(find.text('89 kcal'), findsOneWidget);
      // 370 + 89, on the summary card at the top.
      expect(find.text('459 kcal'), findsOneWidget);
    });

    testWidgets('leaves the other days out and steps back to them', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 1, grams: 100)],
        ),
      );
      await openTab(tester);

      expect(find.text('Heute'), findsOneWidget);
      expect(find.text('370 kcal'), findsNothing);

      await tester.tap(find.byTooltip('Vorheriger Tag'));
      await tester.pumpAndSettle();

      expect(find.text('Gestern'), findsOneWidget);
      expect(find.text('370 kcal'), findsWidgets);
    });

    testWidgets('does not offer a day that has not happened yet', (
      tester,
    ) async {
      await pumpApp(tester);
      await openTab(tester);

      final forward = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );
      expect(forward.onPressed, isNull);
    });
  });

  group('entering and removing food', () {
    testWidgets('a food picked from the catalogue lands in its meal and in '
        'the day total', (tester) async {
      final stores = await pumpApp(tester, on: storesWith(foods: [oats]));
      await openTab(tester);
      await openMeal(tester, 'Frühstück');

      await tester.tap(find.byTooltip('Lebensmittel hinzufügen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Haferflocken'));
      await tester.pumpAndSettle();

      // The portion the food names, offered as the starting amount.
      expect(find.widgetWithText(TextField, 'Menge'), findsOneWidget);
      await tester.tap(find.byTooltip('Bestätigen'));
      await tester.pumpAndSettle();

      expect(stores.mealEntries.entries, hasLength(1));
      expect(stores.mealEntries.entries.single.grams, 50);
      expect(stores.mealEntries.entries.single.mealType, MealType.breakfast);
      // 50 g of a food carrying 370 kcal per 100 g.
      expect(find.text('185 kcal'), findsWidgets);

      await goBack(tester);

      expect(find.text('185 kcal'), findsNWidgets(2));
    });

    testWidgets('the "+" of a meal row goes straight to the food picker', (
      tester,
    ) async {
      await pumpApp(tester, on: storesWith(foods: [oats]));
      await openTab(tester);

      await tester.tap(find.byTooltip('Snacks ergänzen'));
      await tester.pumpAndSettle();

      expect(find.text('Lebensmittel wählen'), findsOneWidget);

      // Dropping the picker lands on the meal it was opened for, not back on
      // the tab — the entry would have gone there.
      await goBack(tester);

      expect(find.text('Snacks'), findsOneWidget);
      expect(
        find.text('Für diese Mahlzeit ist noch nichts eingetragen.'),
        findsOneWidget,
      );
    });

    testWidgets('a blank nutrient field counts as none of it', (tester) async {
      final stores = await pumpApp(tester);
      await openTab(tester);
      await openMeal(tester, 'Snacks');

      await tester.tap(find.byTooltip('Lebensmittel hinzufügen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Lebensmittel anlegen'));
      await tester.pumpAndSettle();

      // Only the name and the energy, the way a drink off a bottle reads.
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Cola');
      await tester.enterText(find.widgetWithText(TextField, 'Kalorien'), '42');
      await tester.pump();
      await tester.tap(find.byTooltip('Bestätigen'));
      await tester.pumpAndSettle();

      final saved = stores.foods.foods.single;
      expect(saved.name, 'Cola');
      expect(saved.nutrientsPer100g.kcal, 42);
      expect(saved.nutrientsPer100g.proteinGrams, 0);
      expect(saved.nutrientsPer100g.carbGrams, 0);
      expect(saved.nutrientsPer100g.fatGrams, 0);
    });

    testWidgets('a food typed in while logging is saved and picked at once', (
      tester,
    ) async {
      final stores = await pumpApp(tester);
      await openTab(tester);
      await openMeal(tester, 'Mittag');

      await tester.tap(find.byTooltip('Lebensmittel hinzufügen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Lebensmittel anlegen'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Magerquark',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Kalorien'), '67');
      await tester.enterText(find.widgetWithText(TextField, 'Protein'), '12');
      await tester.enterText(
        find.widgetWithText(TextField, 'Kohlenhydrate'),
        '4',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Fett'), '0,3');
      await tester.pump();
      await tester.tap(find.byTooltip('Bestätigen'));
      await tester.pumpAndSettle();

      expect(stores.foods.foods.single.name, 'Magerquark');

      await tester.enterText(find.widgetWithText(TextField, 'Menge'), '250');
      await tester.pump();
      await tester.tap(find.byTooltip('Bestätigen'));
      await tester.pumpAndSettle();

      expect(stores.mealEntries.entries.single.grams, 250);
      expect(stores.mealEntries.entries.single.mealType, MealType.lunch);
    });

    testWidgets('tapping an entry corrects its amount', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);
      await openMeal(tester, 'Frühstück');

      await tester.tap(find.text('Haferflocken'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Menge'), '80');
      await tester.pump();
      await tester.tap(find.byTooltip('Bestätigen'));
      await tester.pumpAndSettle();

      expect(stores.mealEntries.entries.single.grams, 80);
      expect(stores.mealEntries.entries, hasLength(1));
    });

    testWidgets('swiping an entry away removes it', (tester) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);
      await openMeal(tester, 'Frühstück');

      await tester.drag(find.text('Haferflocken'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(stores.mealEntries.entries, isEmpty);
      expect(find.text('Haferflocken'), findsNothing);
    });
  });

  group('the day against its target', () {
    /// A profile carrying a calorie target, which the standard 30/40/30 split
    /// turns into 150 g protein, 200 g carbohydrates and 66,7 g fat.
    final withTarget = UserProfile(username: 'Max', calorieTarget: 2000);

    testWidgets('puts the day total and every macro against its target', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);

      // 370 kcal of a 2000 kcal day.
      expect(find.text('370'), findsOneWidget);
      expect(find.text('/ 2000 kcal'), findsOneWidget);
      expect(find.text('13 / 150 g'), findsOneWidget);
      expect(find.text('59 / 200 g'), findsOneWidget);
      expect(find.text('7 / 67 g'), findsOneWidget);
    });

    testWidgets('says how much of each is still open', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);

      expect(find.text('1630 kcal übrig'), findsOneWidget);
      expect(find.text('noch 137 g'), findsOneWidget);
      expect(find.text('noch 141 g'), findsOneWidget);
      expect(find.text('noch 60 g'), findsOneWidget);
    });

    testWidgets('names the overrun instead of a negative remainder', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          // 1000 g of a 370 kcal food: 3700 against a target of 2000.
          mealEntries: [ate(oats, daysAgo: 0, grams: 1000)],
        ),
      );
      await openTab(tester);

      expect(find.text('1700 kcal zu viel'), findsOneWidget);
      expect(find.text('1630 kcal übrig'), findsNothing);
    });

    testWidgets('without a target it shows the bare sums and says where the '
        'target is set', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);

      expect(find.textContaining('Noch kein Kalorienziel'), findsOneWidget);
      expect(find.text('/ 2000 kcal'), findsNothing);
      expect(find.textContaining('übrig'), findsNothing);
      // The sums themselves are still there — the day's and the meal's.
      expect(find.text('370 kcal'), findsWidgets);
    });

    testWidgets('a meal keeps its bare sums even where the day has a target', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          profile: withTarget,
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 100)],
        ),
      );
      await openTab(tester);
      await openMeal(tester, 'Frühstück');

      // No share of the daily target is invented for a single meal.
      expect(find.textContaining('/ 2000 kcal'), findsNothing);
      expect(find.textContaining('übrig'), findsNothing);
      expect(find.text('370 kcal'), findsWidgets);
    });
  });

  group('what was eaten, without opening the meal', () {
    testWidgets('lists the foods under their meal row', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats, banana],
          mealEntries: [
            ate(oats, daysAgo: 0, grams: 50),
            ate(banana, daysAgo: 0, mealType: MealType.snacks, grams: 120),
          ],
        ),
      );
      await openTab(tester);

      // Still on the tab — nothing was tapped.
      expect(find.text('Tagessumme'), findsOneWidget);
      expect(find.text('Haferflocken'), findsOneWidget);
      expect(find.text('50 g · 185 kcal'), findsOneWidget);
      expect(find.text('Banane'), findsOneWidget);
      expect(find.text('120 g · 107 kcal'), findsOneWidget);
    });

    testWidgets('lists nothing under a meal nothing was logged at', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 50)],
        ),
      );
      await openTab(tester);

      expect(find.text('Haferflocken'), findsOneWidget);
      expect(find.textContaining('· 0 kcal'), findsNothing);
    });

    testWidgets('a line leads into the meal, like the row above it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [ate(oats, daysAgo: 0, grams: 50)],
        ),
      );
      await openTab(tester);

      await tester.tap(find.text('50 g · 185 kcal'));
      await tester.pumpAndSettle();

      expect(find.text('Lebensmittel hinzufügen'), findsNothing);
      expect(find.byTooltip('Lebensmittel hinzufügen'), findsOneWidget);
      expect(find.text('Frühstück'), findsWidgets);
    });
  });

  group('repeating the previous day', () {
    testWidgets('suggests the meal of the day before, with what it came to', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats, banana],
          mealEntries: [
            ate(oats, daysAgo: 1, grams: 100),
            ate(banana, daysAgo: 1, grams: 100),
          ],
        ),
      );
      await openTab(tester);

      expect(find.text('Vom Vortag: Haferflocken, Banane'), findsOneWidget);
      expect(
        find.text('459 kcal · nach rechts wischen zum Übernehmen'),
        findsOneWidget,
      );
    });

    testWidgets('swiping the suggestion right copies the meal onto today', (
      tester,
    ) async {
      final stores = await pumpApp(
        tester,
        on: storesWith(
          foods: [oats, banana],
          mealEntries: [
            ate(oats, daysAgo: 1, grams: 100),
            ate(banana, daysAgo: 1, grams: 60),
          ],
        ),
      );
      await openTab(tester);

      await tester.drag(
        find.text('Vom Vortag: Haferflocken, Banane'),
        const Offset(600, 0),
      );
      await tester.pumpAndSettle();

      final today = dayBefore(0);
      final copied = stores.mealEntries.entries
          .where((entry) => entry.date == today)
          .toList();
      expect(copied.map((entry) => entry.grams), [100, 60]);
      expect(
        copied.every((entry) => entry.mealType == MealType.breakfast),
        isTrue,
      );
      // The suggestion has done its job and no longer applies.
      expect(find.textContaining('Vom Vortag'), findsNothing);
      expect(find.text('423 kcal'), findsWidgets);
    });

    testWidgets('offers nothing on a meal that already holds something', (
      tester,
    ) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats],
          mealEntries: [
            ate(oats, daysAgo: 1, grams: 100),
            ate(oats, daysAgo: 0, grams: 30),
          ],
        ),
      );
      await openTab(tester);

      expect(find.textContaining('Vom Vortag'), findsNothing);
    });

    testWidgets('offers nothing when the day before was empty too', (
      tester,
    ) async {
      await pumpApp(tester);
      await openTab(tester);

      expect(find.textContaining('Vom Vortag'), findsNothing);
    });

    testWidgets('suggests each meal on its own', (tester) async {
      await pumpApp(
        tester,
        on: storesWith(
          foods: [oats, banana],
          mealEntries: [
            ate(oats, daysAgo: 1, mealType: MealType.breakfast),
            ate(banana, daysAgo: 1, mealType: MealType.dinner),
          ],
        ),
      );
      await openTab(tester);

      expect(find.text('Vom Vortag: Haferflocken'), findsOneWidget);
      expect(find.text('Vom Vortag: Banane'), findsOneWidget);
    });
  });

  group('when the day cannot be read', () {
    testWidgets('says so instead of showing an empty day', (tester) async {
      await pumpApp(tester, on: storesWith(mealEntriesUnreadable: true));
      await openTab(tester);

      expect(find.text('Der Tag konnte nicht geladen werden.'), findsOneWidget);
      expect(find.text('Tagessumme'), findsNothing);
    });
  });
}
