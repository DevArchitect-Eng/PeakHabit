import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/day_nutrition.dart';
import '../domain/food.dart';
import 'food_repository.dart';
import 'meal_entry_repository.dart';

/// Access to the catalogue of foods and dishes. Everything that writes to it
/// goes through this one.
final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(ref.watch(databaseProvider)),
);

/// Access to the meal diary.
final mealEntryRepositoryProvider = Provider<MealEntryRepository>(
  (ref) => MealEntryRepository(
    ref.watch(databaseProvider),
    ref.watch(foodRepositoryProvider),
  ),
);

/// Every food, by name, re-emitted on every change.
final foodsProvider = StreamProvider<List<Food>>(
  (ref) => ref.watch(foodRepositoryProvider).watchFoods(),
);

/// Every dish with its ingredients, by name, re-emitted on every change.
final compositeFoodsProvider = StreamProvider<List<CompositeFood>>(
  (ref) => ref.watch(foodRepositoryProvider).watchCompositeFoods(),
);

/// Everything logged on one day, together with its totals, re-emitted on
/// every change.
///
/// The family key is a day; a value carrying a time of day is cut back to it,
/// but two such values are different keys and would open two identical
/// queries — pass a plain day.
///
/// Dropped again once nothing watches it, so a day the user has scrolled past
/// does not keep a query open.
final dayNutritionProvider = StreamProvider.autoDispose
    .family<DayNutrition, DateTime>(
      (ref, day) => ref.watch(mealEntryRepositoryProvider).watchDay(day),
    );
