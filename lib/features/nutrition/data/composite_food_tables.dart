import 'package:drift/drift.dart';

import 'food_table.dart';

/// The dishes the user puts together themselves.
///
/// The row holds no nutrients at all: they follow from the ingredients in
/// [CompositeFoodIngredients], which is what makes a correction to one food
/// reach every dish it is part of.
///
/// `prepared_grams` is what the finished dish weighs. Cooking changes the
/// weight without changing the nutrients — 100 g of raw rice leave the pot as
/// roughly 260 g — so without it an amount weighed off the plate would count
/// as that amount of raw ingredients. `NULL` means nothing was weighed and
/// the ingredients are taken to add up.
@DataClassName('CompositeFoodRow')
class CompositeFoods extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  RealColumn get preparedGrams => real().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (name <> '')",
    'CHECK (prepared_grams IS NULL OR prepared_grams > 0)',
  ];
}

/// What goes into a dish, and how much of it.
///
/// The pair of dish and food is the primary key: listing one food twice in a
/// dish is two amounts of the same thing, which belongs in one row. Only
/// plain foods are ingredients, never other dishes — a dish of dishes would
/// need a cycle check for something nobody has asked for.
///
/// Deleting a dish takes its ingredient rows with it; they belong to it and
/// mean nothing on their own. Deleting a food that is part of a dish is
/// refused instead, because it would silently change what that dish carries.
@DataClassName('CompositeFoodIngredientRow')
class CompositeFoodIngredients extends Table {
  IntColumn get compositeFoodId =>
      integer().references(CompositeFoods, #id, onDelete: KeyAction.cascade)();

  IntColumn get foodId =>
      integer().references(Foods, #id, onDelete: KeyAction.restrict)();

  /// How much of the food goes in, in grams.
  RealColumn get grams => real()();

  @override
  Set<Column> get primaryKey => {compositeFoodId, foodId};

  @override
  List<String> get customConstraints => ['CHECK (grams > 0)'];
}
