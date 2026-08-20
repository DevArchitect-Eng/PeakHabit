/// How far back a look at the weight series reaches.
///
/// The series itself has no period — the repository takes any two days. This
/// is the set the screens offer, so that "the last three months" means the
/// same window wherever it is shown, and so a saved preference for it later
/// has something stable to hold.
enum WeightPeriod {
  allTime,
  year,
  sixMonths,
  threeMonths,
  twoMonths,
  month,
  week;

  /// The first day this period covers, counting back from [today].
  ///
  /// Built with the [DateTime] constructor rather than by subtracting a
  /// [Duration]: around a daylight saving change a day is 23 or 25 hours long,
  /// and 30×24 hours taken off local midnight lands on the wrong day. An
  /// overflowing month or day value is what the constructor normalises for us.
  ///
  /// Counting in calendar months also means the window follows the calendar
  /// rather than a fixed number of days — a month back from 31 March is 3
  /// March, because February has no 31st.
  ///
  /// [allTime] has no fixed offset from [today] — it depends on the earliest
  /// entry on record, which this type does not know. Callers read that
  /// separately (`bodyWeightSeriesProvider` does, from
  /// `firstBodyWeightProvider`) rather than asking here.
  DateTime startFrom(DateTime today) => switch (this) {
    WeightPeriod.allTime => throw UnsupportedError(
      'allTime has no fixed start — read the earliest entry instead',
    ),
    WeightPeriod.year => DateTime(today.year - 1, today.month, today.day),
    WeightPeriod.sixMonths => DateTime(today.year, today.month - 6, today.day),
    WeightPeriod.threeMonths => DateTime(
      today.year,
      today.month - 3,
      today.day,
    ),
    WeightPeriod.twoMonths => DateTime(today.year, today.month - 2, today.day),
    WeightPeriod.month => DateTime(today.year, today.month - 1, today.day),
    WeightPeriod.week => DateTime(today.year, today.month, today.day - 7),
  };
}
