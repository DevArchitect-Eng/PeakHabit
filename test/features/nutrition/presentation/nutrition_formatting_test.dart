import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/nutrition/domain/meal_entry.dart';
import 'package:peakhabit/features/nutrition/presentation/nutrition_formatting.dart';

void main() {
  group('formatDayLabel', () {
    final today = DateTime(2026, 8, 21);

    test('names the two days that are actually being logged', () {
      expect(formatDayLabel(today, today: today), 'Heute');
      expect(formatDayLabel(DateTime(2026, 8, 20), today: today), 'Gestern');
    });

    test('writes anything further out as a date', () {
      expect(formatDayLabel(DateTime(2026, 8, 19), today: today), '19.08.2026');
      expect(formatDayLabel(DateTime(2026, 1, 2), today: today), '02.01.2026');
    });

    test('ignores a time of day riding along', () {
      expect(
        formatDayLabel(DateTime(2026, 8, 21, 23, 59), today: today),
        'Heute',
      );
    });

    test('still calls the day before "Gestern" when the clocks move', () {
      // The two midnights around a spring-forward lie 23 hours apart, which
      // a plain `Duration.inDays` rounds to zero — and yesterday would come
      // out as "Heute". Both directions of the switch are covered; which one
      // this machine's zone actually observes does not matter, because the
      // answer has to be the same either way.
      for (final day in [
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 30),
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
      ]) {
        final before = DateTime(day.year, day.month, day.day - 1);
        expect(
          formatDayLabel(before, today: day),
          'Gestern',
          reason: 'the day before $day',
        );
        expect(formatDayLabel(day, today: day), 'Heute', reason: '$day');
      }
    });
  });

  group('route parameters', () {
    test('a day survives the round trip through the route', () {
      final day = DateTime(2026, 8, 21);

      expect(dayParameter(day), '2026-08-21');
      expect(dayByName(dayParameter(day)), day);
    });

    test('a day that states nothing usable falls back on today', () {
      final today = DateTime.now();
      final fallback = dayByName('nonsense');

      expect(fallback, DateTime(today.year, today.month, today.day));
      expect(dayByName(null), fallback);
    });

    test('a meal name survives the round trip', () {
      for (final mealType in MealType.values) {
        expect(mealTypeByName(mealType.name), mealType);
      }
    });

    test('an unknown meal name falls back rather than throwing', () {
      expect(mealTypeByName('brunch'), MealType.breakfast);
      expect(mealTypeByName(null), MealType.breakfast);
    });
  });
}
