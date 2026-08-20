import 'food.dart';
import 'nutrients.dart';

/// The four meals a day is split into.
///
/// Fixed, not user-defined: they are the columns of the nutrition tab, and a
/// list the user can extend would turn the daily view into something that has
/// to lay itself out for an unknown number of sections. Anything outside the
/// three main meals goes to [snacks].
enum MealType { breakfast, lunch, dinner, snacks }

/// One thing eaten: how much of what, on which day, at which meal.
///
/// The item is held as a whole rather than as a reference, and the nutrients
/// follow from it — correcting a food's numbers therefore corrects every day
/// it was eaten on. Freezing them into the entry instead would leave a typo
/// standing in the history forever, which is the opposite of what someone
/// correcting their own catalogue means to happen.
class MealEntry {
  const MealEntry._({
    required this.id,
    required this.date,
    required this.mealType,
    required this.item,
    required this.grams,
  });

  /// Throws an [ArgumentError] on an amount that cannot be meant seriously.
  factory MealEntry({
    int? id,
    required DateTime date,
    required MealType mealType,
    required FoodItem item,
    required double grams,
  }) {
    if (!grams.isFinite || grams <= 0) {
      throw ArgumentError.value(grams, 'grams', 'must be positive');
    }

    return MealEntry._(
      id: id,
      // Normalised to local midnight, the same form the stored date comes
      // back as — see `DateOnlyConverter`. Without this an entry would not be
      // `==` to itself after a round trip through the database.
      date: DateTime(date.year, date.month, date.day),
      mealType: mealType,
      item: item,
      grams: grams,
    );
  }

  /// `null` until the entry has been saved, and the row id afterwards.
  final int? id;

  /// The day the entry belongs to, at local midnight.
  final DateTime date;

  final MealType mealType;

  /// What was eaten — a [Food] or a [CompositeFood].
  final FoodItem item;

  /// How much of [item] was eaten, in grams.
  final double grams;

  /// What this entry contributes to the day.
  Nutrients get nutrients => item.nutrientsFor(grams);

  /// The same entry, carrying the row id it was saved under.
  MealEntry withId(int id) => MealEntry._(
    id: id,
    date: date,
    mealType: mealType,
    item: item,
    grams: grams,
  );

  @override
  bool operator ==(Object other) =>
      other is MealEntry &&
      other.id == id &&
      other.date == date &&
      other.mealType == mealType &&
      other.item == item &&
      other.grams == grams;

  @override
  int get hashCode => Object.hash(id, date, mealType, item, grams);

  @override
  String toString() =>
      'MealEntry(id: $id, date: $date, ${mealType.name}, ${item.name}, '
      '${grams}g)';
}
