/// One change of the calorie target: from [validFrom] on, the target was
/// [kcal] — or none at all, where [kcal] is `null`.
typedef CalorieTargetChange = ({DateTime validFrom, int? kcal});

/// The calorie targets the profile has had over time, answering which one a
/// given day was lived under.
///
/// A plain value with no database behind it, so the lookup can be tested
/// without one.
class CalorieTargetHistory {
  /// [changes] may come in any order.
  CalorieTargetHistory(Iterable<CalorieTargetChange> changes)
    : _changes = [
        for (final change in changes)
          (validFrom: _dayOf(change.validFrom), kcal: change.kcal),
      ]..sort((a, b) => a.validFrom.compareTo(b.validFrom));

  /// A profile whose target has never been set.
  static final empty = CalorieTargetHistory(const []);

  /// Oldest first.
  final List<CalorieTargetChange> _changes;

  /// The target [day] was measured against, or `null` when it had none.
  ///
  /// That is the last change on or before [day]. A day **before the first
  /// change** falls back to that first one rather than to nothing: the record
  /// only starts when it was introduced, or when the onboarding set the first
  /// target, and a day logged before then was still eaten with a target in
  /// mind — the earliest one known is the best guess at it.
  int? targetOn(DateTime day) {
    if (_changes.isEmpty) return null;

    final date = _dayOf(day);
    var target = _changes.first.kcal;
    for (final change in _changes) {
      if (change.validFrom.isAfter(date)) break;
      target = change.kcal;
    }
    return target;
  }

  static DateTime _dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  String toString() => 'CalorieTargetHistory($_changes)';
}
