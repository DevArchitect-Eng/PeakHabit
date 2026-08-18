/// One weighing: what the scale showed, and on which day.
///
/// The day is the identity of an entry — there is at most one per calendar
/// day, and weighing again on the same day corrects the earlier value instead
/// of adding a second one. A weight taken in the morning and one taken in the
/// evening differ by more than most real change, so keeping both would suggest
/// a precision the number does not have.
///
/// Stored in kilograms. A display unit (kg or lbs) is a later setting and a
/// question of presentation; converting on the way into storage would make the
/// stored series depend on when each value was entered.
class BodyWeightEntry {
  /// Throws an [ArgumentError] on a weight that cannot be meant seriously.
  ///
  /// Checked here rather than by an `assert`, which only holds in debug
  /// builds: a release build would store a negative weight and then fail
  /// somewhere entirely different, in a chart or an average, far away from
  /// where the value came from.
  factory BodyWeightEntry({required DateTime date, required double weightKg}) {
    if (!weightKg.isFinite || weightKg <= 0) {
      throw ArgumentError.value(weightKg, 'weightKg', 'must be positive');
    }

    return BodyWeightEntry._(
      // Normalised to local midnight, the same form `DateOnlyConverter` hands
      // back. Without this an entry would not be `==` to itself after a round
      // trip through the database, and two weighings on one day would look
      // like different days to everything but the database.
      date: DateTime(date.year, date.month, date.day),
      weightKg: weightKg,
    );
  }

  const BodyWeightEntry._({required this.date, required this.weightKg});

  /// The day of the weighing, at local midnight.
  final DateTime date;

  /// Body weight in kilograms.
  final double weightKg;

  /// A copy with individual values replaced.
  BodyWeightEntry copyWith({DateTime? date, double? weightKg}) =>
      BodyWeightEntry(
        date: date ?? this.date,
        weightKg: weightKg ?? this.weightKg,
      );

  @override
  bool operator ==(Object other) =>
      other is BodyWeightEntry &&
      other.date == date &&
      other.weightKg == weightKg;

  @override
  int get hashCode => Object.hash(date, weightKg);

  @override
  String toString() => 'BodyWeightEntry(date: $date, weightKg: $weightKg)';
}
