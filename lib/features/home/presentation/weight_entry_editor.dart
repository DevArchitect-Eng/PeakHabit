import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../profile/presentation/profile_formatting.dart';
import '../../profile/presentation/value_editor.dart';

/// Asks for a weighing, and hands back the kilograms and the date confirmed —
/// or `null` when the editor was dropped.
///
/// Built on the same [EditorSheet] and [EditorHeader] the settings rows use, so
/// entering a weight is confirmed with the check and dropped with the cross
/// like every other value in the app. It brings its own field rather than
/// going through `showTextEditor`, which types whole numbers only: a weight is
/// the one value in the app with a decimal place.
Future<({double weightKg, DateTime date})?> showWeightEditor(
  BuildContext context, {
  double? initialWeightKg,
}) {
  return showModalBottomSheet<({double weightKg, DateTime date})>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WeightEditorSheet(initialWeightKg: initialWeightKg),
  );
}

/// The kilograms [text] states, or `null` when it does not state any.
///
/// Takes the comma German keyboards produce as readily as the point, and
/// rejects what the entry itself would refuse — a weight of zero or less, or
/// one so far off that it can only be a typo.
///
/// Rounded to the one decimal the app shows everywhere. Without that, typing
/// 82,55 would store a number no screen ever prints: the card would show
/// 82,5 kg, the editor would open on 82,5 the next time, and confirming that
/// unchanged would quietly write a different weighing than the one on record.
/// A scale reading past the first decimal is noise anyway.
double? parseWeightKg(String text) {
  final number = double.tryParse(text.trim().replaceAll(',', '.'));
  if (number == null || !number.isFinite) return null;
  if (number <= 0 || number > _maxWeightKg) return null;
  return (number * 10).roundToDouble() / 10;
}

/// The heaviest weight the field takes. Above the heaviest person on record,
/// so it only ever catches a slipped decimal point.
const double _maxWeightKg = 700;

class _WeightEditorSheet extends StatefulWidget {
  const _WeightEditorSheet({required this.initialWeightKg});

  final double? initialWeightKg;

  @override
  State<_WeightEditorSheet> createState() => _WeightEditorSheetState();
}

class _WeightEditorSheetState extends State<_WeightEditorSheet> {
  late final _controller = TextEditingController(
    // The last weighing, so a correction of half a kilo is a keystroke rather
    // than a number typed out again. Selected, so typing replaces it.
    text: widget.initialWeightKg == null
        ? ''
        : formatDecimal(widget.initialWeightKg!, 1),
  );

  // Today by default — the usual case, entering the day's own weighing, stays
  // a single tap on the check.
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final weightKg = parseWeightKg(text);
    // Nothing typed yet is not an error worth pointing at — the check is out
    // of reach either way, and a red field on an untouched sheet only scolds.
    final error = weightKg == null && text.trim().isNotEmpty
        ? 'Bitte ein Gewicht wie 82,5 eintragen.'
        : null;

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: 'Gewicht eintragen',
            onConfirm: weightKg == null
                ? null
                : () => Navigator.of(
                    context,
                  ).pop((weightKg: weightKg, date: _date)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Gewicht',
                suffixText: 'kg',
                errorText: error,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: weightKg == null
                  ? null
                  : (_) => Navigator.of(
                      context,
                    ).pop((weightKg: weightKg, date: _date)),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            leading: const Icon(Icons.calendar_today),
            title: const Text('Datum'),
            trailing: Text(formatDate(_date)),
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }
}
