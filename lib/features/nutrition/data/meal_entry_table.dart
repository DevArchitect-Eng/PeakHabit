import 'package:drift/drift.dart';

import '../../../core/database/date_only_converter.dart';
import '../domain/meal_entry.dart';
import 'composite_food_tables.dart';
import 'food_table.dart';

/// What was eaten: the diary behind the nutrition tab.
///
/// An entry points at either a food or a dish, never at both and never at
/// neither — the check constraint below is what says so. Two nullable columns
/// rather than one id plus a kind: an id that means a row in one of two
/// tables cannot carry a foreign key, and without one nothing would stop an
/// entry from outliving what it refers to.
///
/// The nutrients are not copied in here. They are read through the food, so
/// correcting a food's numbers corrects every day it was eaten on; deleting a
/// food that has been eaten is refused instead of taking the history with it.
@DataClassName('MealEntryRow')
class MealEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The day the entry belongs to, as `yyyy-MM-dd` — see [DateOnlyConverter]
  /// for why this is not a `dateTime()` column.
  TextColumn get date => text().map(const DateOnlyConverter())();

  /// Which of the four meals — see [MealType].
  TextColumn get mealType => textEnum<MealType>()();

  IntColumn get foodId => integer().nullable().references(
    Foods,
    #id,
    onDelete: KeyAction.restrict,
  )();

  IntColumn get compositeFoodId => integer().nullable().references(
    CompositeFoods,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// How much was eaten, in grams.
  RealColumn get grams => real()();

  DateTimeColumn get createdAt => dateTime()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (grams > 0)',
    // Exactly one of the two: `<>` on two booleans is "one but not both".
    'CHECK ((food_id IS NULL) <> (composite_food_id IS NULL))',
  ];
}
