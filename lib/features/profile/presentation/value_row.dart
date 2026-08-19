import 'package:flutter/material.dart';

/// One line of a summary: what it is on the left, what it says on the right.
///
/// Used by the weight summary on the goals screen and by every step of the
/// calorie calculation, which is why it lives next to them rather than inside
/// one of the two.
class ValueRow extends StatelessWidget {
  const ValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;

  /// Set on the line that carries the result, so it stands out from the steps
  /// leading up to it.
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasised
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}
