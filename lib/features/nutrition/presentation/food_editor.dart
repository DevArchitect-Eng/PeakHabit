import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../profile/presentation/profile_formatting.dart';
import '../../profile/presentation/value_editor.dart';
import '../domain/food.dart';
import '../domain/nutrients.dart';

/// Asks for a food and hands back what was confirmed — or `null` when the
/// editor was dropped.
///
/// The food is **not** saved here; the caller writes it, because only the
/// caller knows whether it is going into the catalogue on its own or straight
/// into a meal afterwards. With [initial] given the sheet corrects that food
/// and the result carries its id.
///
/// Nutrients are asked per 100 g, the one basis the catalogue keeps — see
/// [Food]. A label stating its numbers per portion has to be converted, which
/// is a calculator the user brings; offering both bases here would mean every
/// sum had to ask each food what its numbers refer to.
Future<Food?> showFoodEditor(BuildContext context, {Food? initial}) {
  return showModalBottomSheet<Food>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FoodEditorSheet(initial: initial),
  );
}

/// The number [text] states, or `null` when it does not state one.
///
/// Takes the comma German keyboards produce as readily as the point, the same
/// way the weight field does.
double? parseAmount(String text) {
  final number = double.tryParse(text.trim().replaceAll(',', '.'));
  if (number == null || !number.isFinite || number < 0) return null;
  return number;
}

class _FoodEditorSheet extends StatefulWidget {
  const _FoodEditorSheet({required this.initial});

  final Food? initial;

  @override
  State<_FoodEditorSheet> createState() => _FoodEditorSheetState();
}

class _FoodEditorSheetState extends State<_FoodEditorSheet> {
  late final _name = _controller(widget.initial?.name);
  late final _brand = _controller(widget.initial?.brand);
  late final _kcal = _amountController(widget.initial?.nutrientsPer100g.kcal);
  late final _protein = _amountController(
    widget.initial?.nutrientsPer100g.proteinGrams,
  );
  late final _carbs = _amountController(
    widget.initial?.nutrientsPer100g.carbGrams,
  );
  late final _fat = _amountController(
    widget.initial?.nutrientsPer100g.fatGrams,
  );
  late final _portion = _amountController(widget.initial?.portionGrams);

  @override
  void dispose() {
    for (final controller in [
      _name,
      _brand,
      _kcal,
      _protein,
      _carbs,
      _fat,
      _portion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = _food();

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: widget.initial == null
                ? 'Lebensmittel anlegen'
                : 'Lebensmittel bearbeiten',
            onConfirm: food == null
                ? null
                : () => Navigator.of(context).pop(food),
          ),
          _field(
            controller: _name,
            label: 'Name',
            autofocus: widget.initial == null,
            // Nothing typed yet is not an error worth pointing at — the check
            // is out of reach either way, and a red field on an untouched
            // sheet only scolds.
            error: _name.text.trim().isEmpty && _name.text.isNotEmpty
                ? 'Bitte einen Namen eintragen.'
                : null,
          ),
          _field(controller: _brand, label: 'Marke (optional)'),
          const _SectionLabel('Nährwerte je 100 g'),
          _amountField(
            controller: _kcal,
            label: 'Kalorien',
            suffix: 'kcal',
            error: _amountError(_kcal),
          ),
          _amountField(
            controller: _protein,
            label: 'Protein',
            suffix: 'g',
            error: _amountError(_protein),
          ),
          _amountField(
            controller: _carbs,
            label: 'Kohlenhydrate',
            suffix: 'g',
            error: _amountError(_carbs),
          ),
          _amountField(
            controller: _fat,
            label: 'Fett',
            suffix: 'g',
            error: _amountError(_fat),
          ),
          const _Hint('Leer gelassene Nährwerte zählen als 0.'),
          _amountField(
            controller: _portion,
            label: 'Portion (optional)',
            suffix: 'g',
            // A portion of zero is not "no portion", it is a typo — the domain
            // model refuses it, so the sheet says so instead of letting the
            // check throw.
            error: _portion.text.trim().isNotEmpty && _portionGrams() == null
                ? 'Eine Portion wiegt mehr als 0 g.'
                : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// The food the fields currently describe, or `null` while they do not
  /// describe one that can be saved.
  Food? _food() {
    final name = _name.text.trim();
    if (name.isEmpty) return null;

    for (final field in [_kcal, _protein, _carbs, _fat]) {
      if (_amountError(field) != null) return null;
    }
    if (_portion.text.trim().isNotEmpty && _portionGrams() == null) return null;

    return Food(
      id: widget.initial?.id,
      name: name,
      brand: _brand.text,
      nutrientsPer100g: Nutrients(
        kcal: _amount(_kcal),
        proteinGrams: _amount(_protein),
        carbGrams: _amount(_carbs),
        fatGrams: _amount(_fat),
      ),
      portionGrams: _portionGrams(),
      // Typed by hand, whatever the food started as: a scanned record whose
      // numbers were corrected here is no longer what the external database
      // holds.
      source: FoodSource.manual,
      barcode: widget.initial?.barcode,
    );
  }

  /// What a nutrient field is worth: what it states, and zero where it states
  /// nothing.
  ///
  /// A blank field counts as none of that nutrient rather than blocking the
  /// sheet. Most packets leave at least one of the four at zero, and a check
  /// that stays grey until every field has a `0` typed into it would be one
  /// nothing on screen explains.
  double _amount(TextEditingController field) =>
      field.text.trim().isEmpty ? 0 : parseAmount(field.text) ?? 0;

  /// Why a nutrient field cannot be taken, or `null` while it can.
  String? _amountError(TextEditingController field) {
    final text = field.text.trim();
    if (text.isEmpty) return null;
    return parseAmount(text) == null
        ? 'Bitte eine Zahl wie 12,5 eintragen.'
        : null;
  }

  /// The portion the field states, `null` when it states none or states one
  /// that cannot be meant.
  double? _portionGrams() {
    final grams = parseAmount(_portion.text);
    return grams == null || grams <= 0 ? null : grams;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, errorText: error),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _amountField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          errorText: error,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  TextEditingController _controller(String? text) =>
      TextEditingController(text: text ?? '');

  /// A field starting on a number already stored, printed the way the app
  /// prints it everywhere — so confirming it unchanged writes back the same
  /// value instead of a longer one nobody typed.
  TextEditingController _amountController(double? value) =>
      TextEditingController(text: value == null ? '' : formatDecimal(value, 1));
}

/// The line under the nutrient fields, saying what an empty one means.
class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// The heading that separates the food's name from its numbers.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
