import 'package:drift/drift.dart';

import '../domain/food.dart';

/// The catalogue of foods.
///
/// Nutrients are always per 100 g, whatever basis the packet used — see
/// [Food] for why. `portion_grams` is what one portion of the food weighs, so
/// a label stated per portion can still be entered and read back.
///
/// `barcode` and `source` are here from the start although only hand-entered
/// foods exist today: a barcode scan against an external food database is
/// planned, and both ways are meant to end up in this one table rather than
/// in a second catalogue next to it.
@DataClassName('FoodRow')
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  /// The manufacturer, `NULL` when there is none worth naming.
  TextColumn get brand => text().nullable()();

  /// Energy of 100 g in kilocalories.
  RealColumn get kcalPer100g => real().named('kcal_per_100g')();

  RealColumn get proteinPer100g => real().named('protein_per_100g')();
  RealColumn get carbsPer100g => real().named('carbs_per_100g')();
  RealColumn get fatPer100g => real().named('fat_per_100g')();

  /// What one portion weighs in grams, `NULL` for a food without a portion
  /// worth naming.
  RealColumn get portionGrams => real().nullable()();

  /// Where the food came from — see [FoodSource]. Stored by name rather than
  /// by index, like every other enum in this database: an index would
  /// silently change meaning as soon as someone reorders the enum.
  TextColumn get source => textEnum<FoodSource>()();

  /// The product's barcode, `NULL` for anything typed by hand. Unique, so a
  /// product scanned twice finds the record that is already there.
  TextColumn get barcode => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// Last change, kept so a later cloud sync has something to order by.
  DateTimeColumn get updatedAt => dateTime()();

  /// The domain model already rejects these, but it is not the only way into
  /// the file — a later migration or a hand-written statement gets here too.
  @override
  List<String> get customConstraints => [
    "CHECK (name <> '')",
    'CHECK (kcal_per_100g >= 0)',
    'CHECK (protein_per_100g >= 0)',
    'CHECK (carbs_per_100g >= 0)',
    'CHECK (fat_per_100g >= 0)',
    'CHECK (portion_grams IS NULL OR portion_grams > 0)',
    'UNIQUE (barcode)',
  ];
}
