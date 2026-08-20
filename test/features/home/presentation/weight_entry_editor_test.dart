import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/home/presentation/weight_entry_editor.dart';
import 'package:peakhabit/features/profile/presentation/profile_formatting.dart';

void main() {
  group('parseWeightKg', () {
    test('takes the comma a German keyboard produces', () {
      expect(parseWeightKg('82,5'), 82.5);
    });

    test('takes a point just as well', () {
      expect(parseWeightKg('82.5'), 82.5);
    });

    test('takes a whole number', () {
      expect(parseWeightKg('82'), 82);
    });

    test('ignores space around the number', () {
      expect(parseWeightKg('  82,5 '), 82.5);
    });

    test('refuses what is not a number', () {
      expect(parseWeightKg('achtzig'), isNull);
      expect(parseWeightKg('8,2,5'), isNull);
      expect(parseWeightKg(''), isNull);
    });

    test('refuses a weight of zero or less', () {
      expect(parseWeightKg('0'), isNull);
      expect(parseWeightKg('-5'), isNull);
    });

    test('refuses a weight that can only be a slipped decimal point', () {
      expect(parseWeightKg('825'), isNull);
    });

    test('takes a weight just under the ceiling', () {
      expect(parseWeightKg('700'), 700);
    });

    test('rounds to the one decimal the app shows', () {
      // Otherwise the entry holds a number no screen prints, and reopening the
      // editor on the rounded form would write a different weighing than the
      // one on record.
      expect(parseWeightKg('82,55'), 82.6);
      expect(parseWeightKg('82,54'), 82.5);
      expect(parseWeightKg('77,777'), 77.8);
    });

    test('what it returns survives being shown and typed back in', () {
      for (final typed in ['82,55', '80,25', '77,77', '64,321']) {
        final stored = parseWeightKg(typed)!;
        expect(parseWeightKg(formatDecimal(stored, 1)), stored, reason: typed);
      }
    });
  });
}
