import 'nutrients.dart';

/// Where a food came from.
///
/// Only [manual] is ever written today. The value exists because a barcode
/// scan against an external food database is planned (#8), and an imported
/// record has to be told apart from one the user typed: an import may be
/// refreshed or corrected against its source, an entry of one's own never is.
/// Keeping the column from the start means that feature adds a value here
/// instead of a migration over rows whose origin nobody can reconstruct.
enum FoodSource {
  /// Entered by the user. Also the way out when a scanned product is missing
  /// from the external database.
  manual,

  /// Taken from an external food database, found by its barcode.
  scanned,
}

/// Anything that can be logged into a meal.
///
/// Either a [Food] — one product, with the nutrients off its packet — or a
/// [CompositeFood], a dish put together from several of them. A meal entry
/// holds one of the two and does not care which: both answer what 100 g of
/// them carry.
sealed class FoodItem {
  const FoodItem();

  /// `null` until the item has been saved, and the row id afterwards.
  int? get id;

  String get name;

  /// What 100 g of this item carry.
  Nutrients get nutrientsPer100g;

  /// What [grams] of this item carry.
  Nutrients nutrientsFor(double grams) {
    if (!grams.isFinite || grams < 0) {
      throw ArgumentError.value(grams, 'grams', 'must not be negative');
    }

    return nutrientsPer100g.scaled(grams / 100);
  }
}

/// One food as it stands on its packet: a name and what 100 g of it carry.
///
/// Nutrients are always kept per 100 g, even for a product whose label states
/// them per portion — [portionGrams] then says how much a portion weighs, and
/// the two are one conversion apart. Storing whichever basis the label
/// happened to use would mean every sum had to ask each food what its numbers
/// refer to.
class Food extends FoodItem {
  const Food._({
    required this.id,
    required this.name,
    required this.brand,
    required this.nutrientsPer100g,
    required this.portionGrams,
    required this.source,
    required this.barcode,
  });

  /// Throws an [ArgumentError] on a name that is blank or a portion that
  /// cannot be meant seriously.
  ///
  /// [brand] and [barcode] are trimmed, and a blank one counts as not given —
  /// they are optional, so an empty text field means the same as no answer.
  factory Food({
    int? id,
    required String name,
    String? brand,
    required Nutrients nutrientsPer100g,
    double? portionGrams,
    FoodSource source = FoodSource.manual,
    String? barcode,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be blank');
    }
    if (portionGrams != null && (!portionGrams.isFinite || portionGrams <= 0)) {
      throw ArgumentError.value(
        portionGrams,
        'portionGrams',
        'must be positive',
      );
    }

    return Food._(
      id: id,
      name: trimmedName,
      brand: _orNull(brand),
      nutrientsPer100g: nutrientsPer100g,
      portionGrams: portionGrams,
      source: source,
      barcode: _orNull(barcode),
    );
  }

  @override
  final int? id;

  @override
  final String name;

  /// The manufacturer, `null` when there is none worth naming.
  ///
  /// Kept apart from the name because an external database always carries the
  /// two separately, and because it is what tells two products of the same
  /// name apart.
  final String? brand;

  @override
  final Nutrients nutrientsPer100g;

  /// What one portion of this food weighs, `null` when the food has no
  /// portion worth naming — a bar or a slice does, flour does not.
  final double? portionGrams;

  final FoodSource source;

  /// The product's barcode, `null` for anything typed by hand.
  ///
  /// Unique across the catalogue, so a product scanned twice finds the record
  /// that is already there instead of adding a second one.
  final String? barcode;

  /// The same food, carrying the row id it was saved under.
  Food withId(int id) => Food._(
    id: id,
    name: name,
    brand: brand,
    nutrientsPer100g: nutrientsPer100g,
    portionGrams: portionGrams,
    source: source,
    barcode: barcode,
  );

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is Food &&
      other.id == id &&
      other.name == name &&
      other.brand == brand &&
      other.nutrientsPer100g == nutrientsPer100g &&
      other.portionGrams == portionGrams &&
      other.source == source &&
      other.barcode == barcode;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    nutrientsPer100g,
    portionGrams,
    source,
    barcode,
  );

  @override
  String toString() => 'Food(id: $id, name: $name, brand: $brand)';
}

/// One food and how much of it goes into a [CompositeFood].
class CompositeFoodIngredient {
  const CompositeFoodIngredient._(this.food, this.grams);

  /// Throws an [ArgumentError] on an amount that cannot be meant seriously.
  factory CompositeFoodIngredient({required Food food, required double grams}) {
    if (!grams.isFinite || grams <= 0) {
      throw ArgumentError.value(grams, 'grams', 'must be positive');
    }

    return CompositeFoodIngredient._(food, grams);
  }

  final Food food;

  /// How much of [food] goes in, in grams.
  final double grams;

  /// What this ingredient contributes to the dish.
  Nutrients get nutrients => food.nutrientsFor(grams);

  @override
  bool operator ==(Object other) =>
      other is CompositeFoodIngredient &&
      other.food == food &&
      other.grams == grams;

  @override
  int get hashCode => Object.hash(food, grams);

  @override
  String toString() => 'CompositeFoodIngredient(${food.name}, ${grams}g)';
}

/// A dish put together from several foods — what the user cooks themselves.
///
/// Its nutrients are never entered, they follow from the ingredients and their
/// amounts. Correcting one ingredient therefore corrects every dish it is part
/// of, which is the whole reason to build a dish out of foods instead of
/// typing a second set of numbers for it.
///
/// Ingredients are plain [Food]s, never other dishes: a dish of dishes would
/// need a cycle check for something nobody has asked for.
class CompositeFood extends FoodItem {
  const CompositeFood._({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.preparedGrams,
  });

  /// Throws an [ArgumentError] without ingredients, on a blank name, or on a
  /// food listed twice.
  factory CompositeFood({
    int? id,
    required String name,
    required List<CompositeFoodIngredient> ingredients,
    double? preparedGrams,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be blank');
    }
    if (ingredients.isEmpty) {
      throw ArgumentError.value(
        ingredients,
        'ingredients',
        'must not be empty',
      );
    }
    final ids = ingredients.map((it) => it.food.id).whereType<int>().toList();
    if (ids.toSet().length != ids.length) {
      throw ArgumentError.value(
        ingredients,
        'ingredients',
        'must not list one food twice',
      );
    }
    if (preparedGrams != null &&
        (!preparedGrams.isFinite || preparedGrams <= 0)) {
      throw ArgumentError.value(
        preparedGrams,
        'preparedGrams',
        'must be positive',
      );
    }

    return CompositeFood._(
      id: id,
      name: trimmedName,
      ingredients: List.unmodifiable(ingredients),
      preparedGrams: preparedGrams,
    );
  }

  @override
  final int? id;

  @override
  final String name;

  final List<CompositeFoodIngredient> ingredients;

  /// What the finished dish weighs, `null` when nothing was weighed and the
  /// ingredients are taken to add up.
  ///
  /// Cooking changes the weight without changing the nutrients: 100 g of raw
  /// rice come out of the pot as roughly 260 g. Without this the dish would
  /// carry the nutrients of the raw ingredients spread over the raw weight,
  /// and weighing 200 g off the plate would count more than two and a half
  /// times what was actually eaten.
  final double? preparedGrams;

  /// What the whole dish weighs — [preparedGrams] when it was weighed, the
  /// ingredients added up otherwise.
  double get totalGrams =>
      preparedGrams ??
      ingredients.fold(0, (sum, ingredient) => sum + ingredient.grams);

  /// What the whole dish carries.
  Nutrients get totalNutrients => ingredients.fold(
    Nutrients.zero,
    (sum, ingredient) => sum + ingredient.nutrients,
  );

  @override
  Nutrients get nutrientsPer100g => totalNutrients.scaled(100 / totalGrams);

  /// The same dish, carrying the row id it was saved under.
  CompositeFood withId(int id) => CompositeFood._(
    id: id,
    name: name,
    ingredients: ingredients,
    preparedGrams: preparedGrams,
  );

  @override
  bool operator ==(Object other) =>
      other is CompositeFood &&
      other.id == id &&
      other.name == name &&
      other.preparedGrams == preparedGrams &&
      _sameIngredients(other.ingredients);

  bool _sameIngredients(List<CompositeFoodIngredient> other) {
    if (other.length != ingredients.length) return false;
    for (var i = 0; i < ingredients.length; i++) {
      if (other[i] != ingredients[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, preparedGrams, Object.hashAll(ingredients));

  @override
  String toString() =>
      'CompositeFood(id: $id, name: $name, ${ingredients.length} ingredients)';
}
