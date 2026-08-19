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

    return ListTile(
      onTap: onTap,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          if (detail != null) ...[
            const SizedBox(width: 8),
            Text(
              detail,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: editable
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
