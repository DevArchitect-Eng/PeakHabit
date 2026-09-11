import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/core/theme/app_theme.dart';
import 'package:peakhabit/features/home/presentation/nutrition_card.dart';
import 'package:peakhabit/features/home/presentation/week_calorie_card.dart';
import 'package:peakhabit/features/nutrition/data/nutrition_providers.dart';
import 'package:peakhabit/features/nutrition/domain/food.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/domain/nutrients.dart';
import 'package:peakhabit/features/nutrition/presentation/nutrition_formatting.dart';
import 'package:peakhabit/features/profile/data/user_profile_providers.dart';
import 'package:peakhabit/features/profile/domain/user_profile.dart';

import '../../../support/pump_app.dart';

void main() {
  /// A Wednesday: two days behind it in the week, four still to come.
  final wednesday = DateTime(2026, 9, 9);
  final monday = DateTime(2026, 9, 7);
  final tuesday = DateTime(2026, 9, 8);

  /// 100 kcal per 100 g, so the grams logged are the kilocalories eaten.
  final plain = Food(
    id: 1,
    name: 'Testkost',
    nutrientsPer100g: Nutrients(
      kcal: 100,
      proteinGrams: 0,
      carbGrams: 0,
      fatGrams: 0,
    ),
  );

  MealEntry ate(double kcal, {required DateTime on}) => MealEntry(
    date: on,
    mealType: MealType.breakfast,
    item: plain,
    grams: kcal,
  );

  final withTarget = UserProfile(username: 'Max', calorieTarget: 2000);

  /// A target of 2000 kcal that has been in place since long before the
  /// pinned week.
  final steadyTarget = [(validFrom: DateTime(2026, 1, 1), kcal: 2000)];

  /// Pumps the card alone on the pinned [wednesday], without the router —
  /// for everything that depends on where today falls in the week.
  Future<void> pumpCard(
    WidgetTester tester, {
    required AppStores stores,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(stores.profile),
          foodRepositoryProvider.overrideWithValue(stores.foods),
          mealEntryRepositoryProvider.overrideWithValue(stores.mealEntries),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.dark,
          home: Scaffold(body: WeekCalorieCard(today: wednesday)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder dayOf(DateTime day) => find.byKey(ValueKey(day));

  CircularProgressIndicator ringOf(WidgetTester tester, DateTime day) =>
      tester.widget(
        find.descendant(
          of: dayOf(day),
          matching: find.byType(CircularProgressIndicator),
        ),
      );

  group('calorieMarkFor', () {
    test('counts 50 kcal either side as on the target', () {
      expect(calorieMarkFor(kcal: 1950, target: 2000), CalorieMark.onTarget);
      expect(calorieMarkFor(kcal: 2000, target: 2000), CalorieMark.onTarget);
      expect(calorieMarkFor(kcal: 2050, target: 2000), CalorieMark.onTarget);
    });

    test('marks a day past the tolerance as over', () {
      expect(calorieMarkFor(kcal: 2050.5, target: 2000), CalorieMark.over);
    });

    test('leaves a day below the tolerance as simply under', () {
      expect(calorieMarkFor(kcal: 1949, target: 2000), CalorieMark.under);
      expect(calorieMarkFor(kcal: 0, target: 2000), CalorieMark.under);
    });

    test('judges nothing without a target', () {
      expect(calorieMarkFor(kcal: 2000, target: null), CalorieMark.noTarget);
    });
  });

  group('weekOf', () {
    test('runs Monday to Sunday around a day in the middle', () {
      expect(weekOf(wednesday), [
        for (var day = 7; day <= 13; day++) DateTime(2026, 9, day),
      ]);
    });

    test('starts on the day itself on a Monday', () {
      expect(weekOf(monday).first, monday);
    });

    test('ends on the day itself on a Sunday', () {
      final sunday = DateTime(2026, 9, 13);
      expect(weekOf(sunday).first, monday);
      expect(weekOf(sunday).last, sunday);
    });

    test('reaches across the end of a month', () {
      // Thursday 1 October 2026 sits in a week that began in September.
      expect(weekOf(DateTime(2026, 10, 1)).first, DateTime(2026, 9, 28));
      expect(weekOf(DateTime(2026, 10, 1)).last, DateTime(2026, 10, 4));
    });

    test('keeps seven separate days through a change of clocks', () {
      // Clocks go back in Europe on 25 October 2026 — a day of 25 hours.
      final week = weekOf(DateTime(2026, 10, 25));
      expect(week.map((day) => day.day), [19, 20, 21, 22, 23, 24, 25]);
    });
  });

  group('the week', () {
    testWidgets('shows seven days from Monday to Sunday with their dates', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
        ),
      );

      for (final label in const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']) {
        expect(find.text(label), findsOneWidget);
      }
      for (var day = 7; day <= 13; day++) {
        expect(find.text('$day.9.'), findsOneWidget);
      }
      final lefts = [
        for (var day = 7; day <= 13; day++)
          tester.getTopLeft(dayOf(DateTime(2026, 9, day))).dx,
      ];
      expect(lefts, orderedEquals([...lefts]..sort()));
    });

    testWidgets('sets today apart from the other days', (tester) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
        ),
      );

      final todayLabel = tester.widget<Text>(find.text('Mi'));
      final otherLabel = tester.widget<Text>(find.text('Di'));
      expect(todayLabel.style?.fontWeight, FontWeight.bold);
      expect(otherLabel.style?.fontWeight, isNot(FontWeight.bold));
      expect(todayLabel.style?.color, isNot(otherLabel.style?.color));
      expect(find.bySemanticsLabel(RegExp(r'^Heute, Mittwoch')), findsOne);
    });

    testWidgets('fills each ring by the share of its target that was eaten', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          foods: [plain],
          mealEntries: [
            ate(500, on: monday),
            ate(1500, on: tuesday),
          ],
        ),
      );

      expect(ringOf(tester, monday).value, closeTo(0.25, 0.001));
      expect(ringOf(tester, tuesday).value, closeTo(0.75, 0.001));
    });

    testWidgets('shows a day nothing was logged on as an empty ring', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
        ),
      );

      expect(ringOf(tester, wednesday).value, 0);
      expect(find.textContaining('nicht geladen'), findsNothing);
    });

    testWidgets('marks a day on its target green, with a check', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          foods: [plain],
          // 40 kcal over: still within the tolerance.
          mealEntries: [ate(2040, on: tuesday)],
        ),
      );

      expect(ringOf(tester, tuesday).value, 1);
      expect(ringOf(tester, tuesday).color, const Color(0xFF4ADE80));
      expect(
        find.descendant(of: dayOf(tuesday), matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
    });

    testWidgets('marks a day past the tolerance in a colour other than green, '
        'with an arrow', (tester) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          foods: [plain],
          mealEntries: [ate(2300, on: tuesday)],
        ),
      );

      final ring = ringOf(tester, tuesday);
      // Capped at a full ring; the colour and the arrow carry the overrun.
      expect(ring.value, 1);
      expect(ring.color, AppTheme.dark.colorScheme.tertiary);
      expect(ring.color, isNot(const Color(0xFF4ADE80)));
      expect(
        find.descendant(
          of: dayOf(tuesday),
          matching: find.byIcon(Icons.arrow_upward),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('zu viel')), findsOne);
    });

    testWidgets('leaves a day short of its target unmarked', (tester) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          foods: [plain],
          mealEntries: [ate(1200, on: tuesday)],
        ),
      );

      expect(ringOf(tester, tuesday).color, AppTheme.dark.colorScheme.primary);
      expect(
        find.descendant(of: dayOf(tuesday), matching: find.byType(Icon)),
        findsNothing,
      );
    });

    testWidgets('keeps the green readable in the light theme too', (
      tester,
    ) async {
      await pumpCard(
        tester,
        theme: AppTheme.light,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          foods: [plain],
          mealEntries: [ate(2000, on: tuesday)],
        ),
      );

      expect(ringOf(tester, tuesday).color, const Color(0xFF15803D));
    });

    testWidgets('measures a past day against the target it had', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          // 2500 until Tuesday, 2000 from today on.
          calorieTargetChanges: [
            (validFrom: DateTime(2026, 1, 1), kcal: 2500),
            (validFrom: wednesday, kcal: 2000),
          ],
          foods: [plain],
          mealEntries: [ate(2500, on: tuesday)],
        ),
      );

      // Right on Tuesday's own target — against today's it would be 500 over.
      expect(
        find.descendant(of: dayOf(tuesday), matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
    });

    testWidgets('leaves the days to come empty and closed', (tester) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
        ),
      );

      for (var day = 10; day <= 13; day++) {
        final date = DateTime(2026, 9, day);
        expect(ringOf(tester, date).value, 0);
        final tap = tester.widget<InkWell>(
          find.descendant(of: dayOf(date), matching: find.byType(InkWell)),
        );
        expect(tap.onTap, isNull);
      }
    });

    testWidgets('without a target it says so instead of judging the days', (
      tester,
    ) async {
      await pumpCard(
        tester,
        stores: storesWith(
          foods: [plain],
          mealEntries: [ate(2000, on: monday)],
        ),
      );

      expect(find.textContaining('Noch kein Kalorienziel'), findsOneWidget);
      expect(ringOf(tester, monday).value, 0);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
    });

    testWidgets('reports a week that cannot be read', (tester) async {
      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
          mealEntriesUnreadable: true,
        ),
      );

      expect(
        find.textContaining('Woche konnte nicht geladen werden'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('survives the largest system text size on a phone', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpCard(
        tester,
        stores: storesWith(
          profile: withTarget,
          calorieTargetChanges: steadyTarget,
        ),
      );

      // An overflow fails the test on its own; the seven days still sit in
      // one row.
      final tops = {
        for (var day = 7; day <= 13; day++)
          tester.getTopLeft(dayOf(DateTime(2026, 9, day))).dy,
      };
      expect(tops, hasLength(1));
    });
  });

  group('the card on the home screen', () {
    testWidgets('stands above the nutrition card', (tester) async {
      await pumpApp(tester, on: storesWith(profile: withTarget));

      expect(
        tester.getTopLeft(find.byType(WeekCalorieCard)).dy,
        lessThan(tester.getTopLeft(find.byType(NutritionCard)).dy),
      );
    });

    testWidgets('a day opens the nutrition tab on that day', (tester) async {
      await pumpApp(tester, on: storesWith(profile: withTarget));

      // Monday of the real week — the one day that is always there to tap,
      // whichever weekday the test runs on.
      final monday = weekOf(DateTime.now()).first;
      await tester.tap(find.byKey(ValueKey(monday)));
      await tester.pumpAndSettle();

      expect(find.text('Tagessumme'), findsOneWidget);
      expect(find.text(formatDayLabel(monday)), findsOneWidget);
    });
  });
}
