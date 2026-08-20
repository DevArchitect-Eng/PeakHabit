/// How far back a look at the weight series reaches.
///
/// The series itself has no period — the repository takes any two days. This
/// is the set the screens offer, so that "the last three months" means the
/// same window wherever it is shown, and so a saved preference for it later
/// has something stable to hold.
enum WeightPeriod {
  month,
  threeMonths,
  year;

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
  DateTime startFrom(DateTime today) => switch (this) {
    WeightPeriod.month => DateTime(today.year, today.month - 1, today.day),
    WeightPeriod.threeMonths => DateTime(
      today.year,
      today.month - 3,
      today.day,
    ),
    WeightPeriod.year => DateTime(today.year - 1, today.month, today.day),
  };
}
