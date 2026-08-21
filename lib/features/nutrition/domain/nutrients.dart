/// Energy and the three macronutrients of some amount of food.
///
/// Always an absolute amount, never a rate: a food carries the nutrients of
/// 100 g of it, a meal entry those of the portion that was eaten. What the
/// numbers refer to is decided by whoever holds them — [scaled] is the one way
/// from one basis to another.
///
/// Grams throughout, kilocalories for the energy. A joule display and a
/// pounds-per-ounce display are questions of presentation, the same way the
/// weight series stores kilograms and leaves the unit to the screen.
class Nutrients {
  const Nutrients._(
    this.kcal,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
  );

  /// Throws an [ArgumentError] on a value that cannot be meant seriously.
  ///
  /// Checked here rather than by an `assert`, which only holds in debug
  /// builds: a release build would carry a negative amount into a daily total
  /// and quietly make it too small, far away from where the value came from.
  factory Nutrients({
    required double kcal,
    required double proteinGrams,
    required double carbGrams,
    required double fatGrams,
  }) {
    _requireAmount('kcal', kcal);
    _requireAmount('proteinGrams', proteinGrams);
    _requireAmount('carbGrams', carbGrams);
    _requireAmount('fatGrams', fatGrams);

    return Nutrients._(kcal, proteinGrams, carbGrams, fatGrams);
  }

  /// Nothing at all — the starting point of every sum.
  static const zero = Nutrients._(0, 0, 0, 0);

  /// Energy in kilocalories.
  final double kcal;

  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;

  /// The two amounts added up, macronutrient by macronutrient.
  Nutrients operator +(Nutrients other) => Nutrients._(
    kcal + other.kcal,
    proteinGrams + other.proteinGrams,
    carbGrams + other.carbGrams,
    fatGrams + other.fatGrams,
  );

  /// This amount taken [factor] times.
  ///
  /// The energy is scaled along with the macronutrients instead of being
  /// derived from them: the two do not have to match exactly. A label rounds
  /// its numbers, alcohol and fibre carry energy without being any of the
  /// three, and recomputing the kcal from the grams would silently correct
  /// what the user typed off the packet.
  Nutrients scaled(double factor) {
    _requireAmount('factor', factor);

    return Nutrients._(
      kcal * factor,
      proteinGrams * factor,
      carbGrams * factor,
      fatGrams * factor,
    );
  }

  static void _requireAmount(String name, double value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(value, name, 'must not be negative');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Nutrients &&
      other.kcal == kcal &&
      other.proteinGrams == proteinGrams &&
      other.carbGrams == carbGrams &&
      other.fatGrams == fatGrams;

  @override
  int get hashCode => Object.hash(kcal, proteinGrams, carbGrams, fatGrams);

  @override
  String toString() =>
      'Nutrients(${kcal}kcal, ${proteinGrams}g protein, ${carbGrams}g carbs, '
      '${fatGrams}g fat)';
}
