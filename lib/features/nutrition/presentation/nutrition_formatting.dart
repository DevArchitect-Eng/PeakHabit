import 'package:flutter/material.dart';

import '../domain/meal_entry.dart';
import '../domain/nutrients.dart';

/// The German labels and number formats the nutrition screens share.
///
/// In one place for the same reason the profile screens keep theirs there: the
/// tab, the meal and the food picker all name the same four meals and print
/// the same kinds of numbers, and a second copy of a label is one that gets
/// changed in one screen and forgotten in the other.

extension MealTypeLabel on MealType {
  String get label => switch (this) {
    MealType.breakfast => 'Frühstück',
    MealType.lunch => 'Mittag',
    MealType.dinner => 'Abend',
    MealType.snacks => 'Snacks',
  };

  IconData get icon => switch (this) {
    MealType.breakfast => Icons.free_breakfast_outlined,
    MealType.lunch => Icons.lunch_dining_outlined,
    MealType.dinner => Icons.dinner_dining_outlined,
    MealType.snacks => Icons.cookie_outlined,
  };
}

/// The meal [name] stands for, or [MealType.breakfast] when it stands for
/// none.
///
/// The fallback keeps a hand-typed or restored route on a real meal instead of
/// throwing — the same way an unknown weight period falls back to the default.
MealType mealTypeByName(String? name) => MealType.values.firstWhere(
  (mealType) => mealType.name == name,
  orElse: () => MealType.breakfast,
);

/// A day as `2026-08-21`, the form the meal route carries it in.
///
/// Not the German display format: a route parameter is read back by
/// [dayByName], and a form that sorts and parses without ambiguity is worth
/// more there than one that reads well.
String dayParameter(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// The day [text] states, or today when it states none.
DateTime dayByName(String? text) {
  final parsed = text == null ? null : DateTime.tryParse(text);
  return DateUtils.dateOnly(parsed ?? DateTime.now());
}

/// How a day is named over the meals: `Heute`, `Gestern`, or the date itself.
///
/// The two nearest days carry a name because they are the ones actually being
/// logged, and "Heute" answers at a glance what a date makes the reader work
/// out.
String formatDayLabel(DateTime day, {DateTime? today}) {
  final reference = DateUtils.dateOnly(today ?? DateTime.now());
  final difference = DateUtils.dateOnly(day).difference(reference).inDays;

  return switch (difference) {
    0 => 'Heute',
    -1 => 'Gestern',
    _ =>
      '${day.day.toString().padLeft(2, '0')}.'
          '${day.month.toString().padLeft(2, '0')}.'
          '${day.year}',
  };
}

/// Kilocalories as the whole number every screen prints: `420 kcal`.
///
/// Rounded rather than cut off with a decimal: the energy of a portion is
/// already an estimate off a packet, and a tenth of a kilocalorie suggests a
/// precision the number does not have.
String formatKcal(double kcal) => '${kcal.round()} kcal';

/// The three macronutrients on one line: `P 24 g · KH 51 g · F 9 g`.
///
/// Abbreviated because the line sits under a meal name and has to survive a
/// large system text size without wrapping into three.
String formatMacros(Nutrients nutrients) =>
    'P ${_grams(nutrients.proteinGrams)} · '
    'KH ${_grams(nutrients.carbGrams)} · '
    'F ${_grams(nutrients.fatGrams)}';

/// An amount in grams, rounded to whole ones: `51 g`.
String formatGrams(double grams) => _grams(grams);

String _grams(double grams) => '${grams.round()} g';
