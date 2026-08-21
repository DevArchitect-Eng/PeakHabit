import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../profile/presentation/profile_formatting.dart';
import '../../profile/presentation/value_editor.dart';
import '../domain/food.dart';
import 'food_editor.dart';
import 'nutrition_formatting.dart';

/// Asks how much of [item] was eaten and hands back the grams — or `null` when
/// the editor was dropped.
///
/// Shows what the amount currently comes to while it is being typed: the
/// number that matters is the kilocalories, and grams are only the way to say
/// it. A food that names a portion weight offers it as a button, so the usual
/// case is one tap rather than a weight looked up on the packet.
Future<double?> showPortionEditor(
  BuildContext context, {
  required FoodItem item,
  double? initialGrams,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        _PortionEditorSheet(item: item, initialGrams: initialGrams),
  );
}

class _PortionEditorSheet extends StatefulWidget {
  const _PortionEditorSheet({required this.item, required this.initialGrams});

  final FoodItem item;

  /// The amount of an entry being corrected. A new entry starts on the food's
  /// portion where it names one, and empty otherwise.
  final double? initialGrams;

  @override
  State<_PortionEditorSheet> createState() => _PortionEditorSheetState();
}

class _PortionEditorSheetState extends State<_PortionEditorSheet> {
  late final _controller = TextEditingController(
    text: widget.initialGrams == null
        ? ''
        : formatDecimal(widget.initialGrams!, 1),
  );

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
    final theme = Theme.of(context);
    final grams = _grams();
    final text = _controller.text.trim();
    final item = widget.item;
    final portion = item is Food ? item.portionGrams : null;

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: widget.item.name,
            onConfirm: grams == null ? null : () => _confirm(grams),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                labelText: 'Menge',
                suffixText: 'g',
                errorText: grams == null && text.isNotEmpty
                    ? 'Bitte eine Menge größer als 0 eintragen.'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: grams == null ? null : (_) => _confirm(grams),
            ),
          ),
          if (portion != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ActionChip(
                  avatar: const Icon(Icons.restaurant, size: 18),
                  label: Text('1 Portion (${formatGrams(portion)})'),
                  onPressed: () => _setGrams(portion),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                grams == null
                    ? '—'
                    : '${formatKcal(widget.item.nutrientsFor(grams).kcal)} · '
                          '${formatMacros(widget.item.nutrientsFor(grams))}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setGrams(double grams) {
    _controller.text = formatDecimal(grams, 1);
    setState(() {});
  }

  void _confirm(double grams) => Navigator.of(context).pop(grams);

  /// The amount the field states, `null` while it states none the entry would
  /// take — a meal entry refuses zero and less.
  double? _grams() {
    final grams = parseAmount(_controller.text);
    return grams == null || grams <= 0 ? null : grams;
  }
}
