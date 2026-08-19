import 'package:flutter/material.dart';

/// One line of a settings list: what it is on the left, what it says on the
/// right.
///
/// The screens of the settings area are lists of these rather than forms with
/// a save button underneath — a row is edited by tapping it, and the editor it
/// opens is where the change is confirmed or dropped.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.onTap,
  });

  final String label;

  /// What the row currently holds, on the right.
  final String value;

  /// Extra wording next to the label, set apart from it — the gram target of a
  /// macro share, say.
  final String? detail;

  /// `null` marks a row that only reports something, like the weights on the
  /// goals screen: it cannot be tapped, and its value is not painted in the
  /// accent colour that marks an editable one.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    final editable = onTap != null;

    // Laid out by hand rather than with ListTile's title and trailing: the
    // trailing gets whatever width it asks for there, and a long value then
    // squeezes the label until it breaks mid-word. Here the value takes its
    // natural width up to a share of the line, and the label gets the rest.
    return ListTile(
      onTap: onTap,
      title: LayoutBuilder(
        builder: (context, constraints) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(child: Text(label)),
                  if (detail != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        detail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * _valueShare,
              ),
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: editable
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How much of a row a value may take before it has to wrap — enough for a
/// weighing with its date, little enough that a label keeps its own line.
const double _valueShare = 0.55;
