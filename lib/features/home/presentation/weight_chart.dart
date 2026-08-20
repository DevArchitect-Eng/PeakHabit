import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../body_weight/domain/body_weight_entry.dart';
import '../../profile/presentation/profile_formatting.dart';

/// The weight series of a period, drawn as a line over the days it covers.
///
/// Painted by hand rather than with a charting package: one line with two
/// labelled bounds is little enough that a dependency would cost more than it
/// saves, and the app's package strategy is deliberately reserved.
///
/// Every colour comes from the theme, so the chart follows dark and light
/// along with the rest of the app instead of carrying its own palette.
class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.entries,
    required this.from,
    required this.to,
  });

  /// The weighings to draw, oldest first. Must not be empty.
  final List<BodyWeightEntry> entries;

  /// First and last day of the period — the horizontal bounds. They come from
  /// the period rather than from the entries so that the line keeps its place
  /// on the time axis: three weighings in the last week sit at the right-hand
  /// edge of a three-month chart, not spread across it.
  final DateTime from;
  final DateTime to;

  /// How tall the chart draws. Enough for the line to show a shape, little
  /// enough that the card stays a card.
  static const double height = 160;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11);

    return Semantics(
      label: _semanticsLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeightChartPainter(
            entries: entries,
            from: from,
            to: to,
            lineColor: theme.colorScheme.primary,
            // A wash rather than a solid: it has to read as "under the line"
            // in both themes, where the surface behind it is nearly black in
            // one and nearly white in the other.
            fillColor: theme.colorScheme.primary.withValues(alpha: 0.14),
            gridColor: theme.colorScheme.outlineVariant,
            labelStyle: labelStyle,
          ),
        ),
      ),
    );
  }

  /// What a screen reader gets instead of the drawing.
  String get _semanticsLabel {
    final first = entries.first;
    final last = entries.last;
    final range =
        'vom ${formatShortDate(first.date)} '
        'bis ${formatShortDate(last.date)}';
    if (entries.length == 1) {
      return 'Gewichtsverlauf: eine Wiegung, '
          '${formatDecimal(last.weightKg, 1)} kg '
          'am ${formatShortDate(last.date)}';
    }
    return 'Gewichtsverlauf $range: '
        'von ${formatDecimal(first.weightKg, 1)} kg '
        'auf ${formatDecimal(last.weightKg, 1)} kg, '
        '${entries.length} Wiegungen';
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.entries,
    required this.from,
    required this.to,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<BodyWeightEntry> entries;
  final DateTime from;
  final DateTime to;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final TextStyle labelStyle;

  /// Room on the left for the two weight labels, and at the bottom for the two
  /// dates. Both are measured rather than guessed, so a large system text size
  /// widens the margin instead of painting the line over the labels.
  static const double _gap = 6;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final (:low, :high) = _weightBounds();
    final topLabel = _label('${formatDecimal(high, 1)} kg');
    final bottomLabel = _label('${formatDecimal(low, 1)} kg');
    final fromLabel = _label(formatShortDate(from));
    final toLabel = _label(formatShortDate(to));

    final left =
        [topLabel.width, bottomLabel.width].reduce((a, b) => a > b ? a : b) +
        _gap;
    // The weight labels are centred on the lines they name, so each needs half
    // of itself in hand above the top line and below the bottom one.
    final labelHalf = topLabel.height / 2;
    final bottom = size.height - fromLabel.height - _gap;
    final plot = Rect.fromLTRB(left, labelHalf, size.width, bottom - labelHalf);
    if (plot.width <= 0 || plot.height <= 0) return;

    _paintGrid(canvas, plot, gridColor);
    topLabel.paint(
      canvas,
      Offset(left - _gap - topLabel.width, plot.top - labelHalf),
    );
    bottomLabel.paint(
      canvas,
      Offset(left - _gap - bottomLabel.width, plot.bottom - labelHalf),
    );
    fromLabel.paint(canvas, Offset(left, bottom + _gap / 2));
    toLabel.paint(
      canvas,
      Offset(size.width - toLabel.width, bottom + _gap / 2),
    );

    final points = [
      for (final entry in entries)
        Offset(
          plot.left + _horizontal(entry.date) * plot.width,
          plot.bottom - _vertical(entry.weightKg, low, high) * plot.height,
        ),
    ];

    _paintArea(canvas, plot, points);
    _paintLine(canvas, points);
    _paintDot(canvas, points.last);
  }

  /// The weight range the vertical axis spans.
  ///
  /// A series that never moves — a single weighing, or the same number twice —
  /// would collapse the axis to zero height and put the line on an edge. It
  /// gets half a kilo of air on either side instead, which draws it through
  /// the middle.
  ({double low, double high}) _weightBounds() {
    var low = entries.first.weightKg;
    var high = low;
    for (final entry in entries) {
      if (entry.weightKg < low) low = entry.weightKg;
      if (entry.weightKg > high) high = entry.weightKg;
    }
    if (high - low < 0.1) return (low: low - 0.5, high: high + 0.5);
    return (low: low, high: high);
  }

  /// Where [date] sits between [from] and [to], from 0 to 1.
  double _horizontal(DateTime date) {
    final span = _dayNumber(to) - _dayNumber(from);
    if (span <= 0) return 1;
    final offset = _dayNumber(date) - _dayNumber(from);
    return (offset / span).clamp(0.0, 1.0);
  }

  double _vertical(double weightKg, double low, double high) =>
      ((weightKg - low) / (high - low)).clamp(0.0, 1.0);

  /// The day as a plain count of days.
  ///
  /// Counted in UTC on purpose: the difference between two local midnights is
  /// 23 or 25 hours across a daylight saving change, and `inDays` on that
  /// rounds a full day down to none. UTC has no such days, so the count stays
  /// the calendar distance.
  int _dayNumber(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  void _paintGrid(Canvas canvas, Rect plot, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (final y in [plot.top, plot.bottom]) {
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
    }
  }

  void _paintArea(Canvas canvas, Rect plot, List<Offset> points) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, plot.bottom);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path
      ..lineTo(points.last.dx, plot.bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = fillColor);
  }

  void _paintLine(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Marks the most recent weighing — and is the whole drawing when it is the
  /// only one, where a line has nothing to connect.
  void _paintDot(Canvas canvas, Offset point) {
    canvas.drawCircle(point, 3.5, Paint()..color = lineColor);
  }

  TextPainter _label(String text) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      !listEquals(old.entries, entries) ||
      old.from != from ||
      old.to != to ||
      old.lineColor != lineColor ||
      old.fillColor != fillColor ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle;
}
