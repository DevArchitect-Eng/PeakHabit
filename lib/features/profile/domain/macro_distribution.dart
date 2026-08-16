/// How the daily calorie target is split across the three macronutrients.
///
/// The three shares are percentages of the calorie target and always add up to
/// 100. A split that does not is rejected right here, so an invalid one can
/// never reach the database or the UI.
class MacroDistribution {
  const MacroDistribution._(
    this.proteinPercent,
    this.carbPercent,
    this.fatPercent,
  );

  factory MacroDistribution({
    required int proteinPercent,
    required int carbPercent,
    required int fatPercent,
  }) {
    _requireNonNegativeShare('proteinPercent', proteinPercent);
    _requireNonNegativeShare('carbPercent', carbPercent);
    _requireNonNegativeShare('fatPercent', fatPercent);

    final total = proteinPercent + carbPercent + fatPercent;
    if (total != 100) {
      throw ArgumentError.value(
        total,
        'total',
        'protein, carbohydrates and fat must add up to 100 percent',
      );
    }

    return MacroDistribution._(proteinPercent, carbPercent, fatPercent);
  }

  /// What a profile starts with until the user picks something else.
  static const standard = MacroDistribution._(30, 40, 30);

  /// Energy per gram: protein and carbohydrates carry 4 kcal, fat 9 kcal.
  static const _kcalPerGramProtein = 4;
  static const _kcalPerGramCarbs = 4;
  static const _kcalPerGramFat = 9;

  final int proteinPercent;
  final int carbPercent;
  final int fatPercent;

  /// The gram targets this split produces for a daily [calorieTarget] in kcal.
  ///
  /// Derived on every call instead of being stored, so the grams follow the
  /// calorie target on their own whenever it changes.
  MacroTargets gramsFor(int calorieTarget) {
    if (calorieTarget < 0) {
      throw ArgumentError.value(
        calorieTarget,
        'calorieTarget',
        'must not be negative',
      );
    }

    return MacroTargets(
      proteinGrams: calorieTarget * proteinPercent / 100 / _kcalPerGramProtein,
      carbGrams: calorieTarget * carbPercent / 100 / _kcalPerGramCarbs,
      fatGrams: calorieTarget * fatPercent / 100 / _kcalPerGramFat,
    );
  }

  static void _requireNonNegativeShare(String name, int value) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'must not be negative');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is MacroDistribution &&
      other.proteinPercent == proteinPercent &&
      other.carbPercent == carbPercent &&
      other.fatPercent == fatPercent;

  @override
  int get hashCode => Object.hash(proteinPercent, carbPercent, fatPercent);

  @override
  String toString() =>
      'MacroDistribution($proteinPercent% protein, $carbPercent% carbs, '
      '$fatPercent% fat)';
}

/// The daily gram targets per macronutrient.
class MacroTargets {
  const MacroTargets({
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
  });

  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;

  @override
  bool operator ==(Object other) =>
      other is MacroTargets &&
      other.proteinGrams == proteinGrams &&
      other.carbGrams == carbGrams &&
      other.fatGrams == fatGrams;

  @override
  int get hashCode => Object.hash(proteinGrams, carbGrams, fatGrams);

  @override
  String toString() =>
      'MacroTargets(${proteinGrams}g protein, ${carbGrams}g carbs, '
      '${fatGrams}g fat)';
}
