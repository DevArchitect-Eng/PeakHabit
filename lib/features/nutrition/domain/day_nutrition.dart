import 'meal_entry.dart';
import 'nutrients.dart';

/// Everything eaten on one day, and what it adds up to.
///
/// Holds the entries and answers both questions the nutrition tab asks of a
/// day: what stands under each of the four meals, and what the day carries in
/// total. A plain value with no database behind it, so the arithmetic can be
/// tested without one.
class DayNutrition {
  const DayNutrition._(this.date, this._entriesByMeal);

  /// Throws an [ArgumentError] on an entry that belongs to another day —
  /// it would be counted into a total it has nothing to do with.
  factory DayNutrition({
    required DateTime date,
    required List<MealEntry> entries,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final byMeal = {
      for (final mealType in MealType.values) mealType: <MealEntry>[],
    };
    for (final entry in entries) {
      if (entry.date != day) {
        throw ArgumentError.value(
          entry,
          'entries',
          'must all be on $day, not on ${entry.date}',
        );
      }
      byMeal[entry.mealType]!.add(entry);
    }

    return DayNutrition._(day, {
      for (final meal in byMeal.entries)
        meal.key: List.unmodifiable(meal.value),
    });
  }

  /// A day nothing has been logged on yet.
  factory DayNutrition.empty(DateTime date) =>
      DayNutrition(date: date, entries: const []);

  /// The day, at local midnight.
  final DateTime date;

  final Map<MealType, List<MealEntry>> _entriesByMeal;

  /// Everything eaten that day, meal by meal in the order of [MealType].
  List<MealEntry> get entries => [
    for (final mealType in MealType.values) ...entriesOf(mealType),
  ];

  /// What stands under [mealType], empty when nothing does.
  List<MealEntry> entriesOf(MealType mealType) => _entriesByMeal[mealType]!;

  /// What [mealType] adds up to.
  Nutrients totalOf(MealType mealType) => entriesOf(
    mealType,
  ).fold(Nutrients.zero, (sum, entry) => sum + entry.nutrients);

  /// What the whole day adds up to.
  Nutrients get total => MealType.values.fold(
    Nutrients.zero,
    (sum, mealType) => sum + totalOf(mealType),
  );

  /// Whether nothing has been logged that day.
  bool get isEmpty =>
      MealType.values.every((mealType) => entriesOf(mealType).isEmpty);

  @override
  String toString() =>
      'DayNutrition($date, ${entries.length} entries, ${total.kcal}kcal)';
}
