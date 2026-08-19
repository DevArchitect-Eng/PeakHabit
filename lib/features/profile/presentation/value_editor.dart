import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The editors the settings rows open, and the frame they share.
///
/// Every one of them is confirmed with the check or dropped with the cross —
/// there is no save button on the screens themselves, so the sheet is where a
/// change becomes final. A sheet that cannot be confirmed yet says why instead
/// of letting the value through and complaining later.

/// Asks for a line of text, and hands back what was confirmed — or `null` when
/// the editor was dropped.
///
/// [validate] returns the reason a value cannot be confirmed, or `null` while
/// it is fine; the check stays out of reach until it is.
Future<String?> showTextEditor(
  BuildContext context, {
  required String title,
  required String initialValue,
  String? suffix,
  bool digitsOnly = false,
  String? Function(String value)? validate,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _TextEditorSheet(
      title: title,
      initialValue: initialValue,
      suffix: suffix,
      digitsOnly: digitsOnly,
      validate: validate,
    ),
  );
}

/// Asks for one of [options], and hands back the choice wrapped in a record.
///
/// The wrapper is what tells the two empty answers apart: `null` means the
/// editor was dropped, `(value: null)` means "Keine Angabe" was picked.
Future<({T? value})?> showChoiceEditor<T>(
  BuildContext context, {
  required String title,
  required T? value,
  required List<T> options,
  required String Function(T option) labelOf,
  String? noneLabel,
}) {
  return showModalBottomSheet<({T? value})>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ChoiceEditorSheet<T>(
      title: title,
      value: value,
      options: options,
      labelOf: labelOf,
      noneLabel: noneLabel,
    ),
  );
}

/// The head of every editor: drop on the left, what is being edited in the
/// middle, confirm on the right.
class EditorHeader extends StatelessWidget {
  const EditorHeader({super.key, required this.title, required this.onConfirm});

  final String title;

  /// `null` while the value cannot be confirmed — a share that does not add up,
  /// a name that is empty.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Abbrechen',
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Bestätigen',
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

/// Lifts the sheet above the keyboard, which would otherwise cover the field
/// it belongs to.
///
/// What is left over between the keyboard and the top of the screen can be
/// less than the sheet needs — a large system text size on a small phone gets
/// there quickly. The content scrolls in that case instead of overflowing,
/// which would cut off the very line explaining why the check is out of reach.
class EditorSheet extends StatelessWidget {
  const EditorSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
        ),
      ),
    );
  }
}

class _TextEditorSheet extends StatefulWidget {
  const _TextEditorSheet({
    required this.title,
    required this.initialValue,
    required this.suffix,
    required this.digitsOnly,
    required this.validate,
  });

  final String title;
  final String initialValue;
  final String? suffix;
  final bool digitsOnly;
  final String? Function(String value)? validate;

  @override
  State<_TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<_TextEditorSheet> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.validate?.call(_controller.text);

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: widget.title,
            onConfirm: error == null
                ? () => Navigator.of(context).pop(_controller.text)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: widget.digitsOnly
                  ? TextInputType.number
                  : TextInputType.text,
              inputFormatters: widget.digitsOnly
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              decoration: InputDecoration(
                labelText: widget.title,
                suffixText: widget.suffix,
                errorText: error,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: error == null
                  ? (value) => Navigator.of(context).pop(value)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceEditorSheet<T> extends StatefulWidget {
  const _ChoiceEditorSheet({
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.noneLabel,
  });

  final String title;
  final T? value;
  final List<T> options;
  final String Function(T option) labelOf;
  final String? noneLabel;

  @override
  State<_ChoiceEditorSheet<T>> createState() => _ChoiceEditorSheetState<T>();
}

class _ChoiceEditorSheetState<T> extends State<_ChoiceEditorSheet<T>> {
  late T? _selected = widget.value;

  @override
  Widget build(BuildContext context) {
    final noneLabel = widget.noneLabel;

    return EditorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorHeader(
            title: widget.title,
            onConfirm: () => Navigator.of(context).pop((value: _selected)),
          ),
          RadioGroup<T?>(
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (noneLabel != null)
                  RadioListTile<T?>(value: null, title: Text(noneLabel)),
                for (final option in widget.options)
                  RadioListTile<T?>(
                    value: option,
                    title: Text(widget.labelOf(option)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
