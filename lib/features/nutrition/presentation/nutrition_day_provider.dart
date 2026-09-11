import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The day the nutrition tab shows, today until something moves it.
///
/// Held here rather than inside the screen, and still not in the route: the
/// tab moves between days as a control on itself, not as navigation (see
/// `NutritionScreen`), but it is not the only one that moves it any more —
/// the week on the home screen opens a day there as well.
final nutritionDayProvider = NotifierProvider<NutritionDay, DateTime>(
  NutritionDay.new,
);

class NutritionDay extends Notifier<DateTime> {
  @override
  DateTime build() => DateUtils.dateOnly(DateTime.now());

  /// Puts the tab on [day], cut back to the day itself — a value carrying a
  /// time of day would key a second, identical query for it.
  void show(DateTime day) => state = DateUtils.dateOnly(day);
}
