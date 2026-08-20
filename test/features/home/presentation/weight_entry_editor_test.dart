import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/home/presentation/weight_entry_editor.dart';

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
  });
}
