import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peakhabit/features/profile/presentation/setting_row.dart';

/// Helpers for the settings screens, which are lists of [SettingRow]s edited
/// through a sheet that is confirmed with the check or dropped with the cross.

/// What the row labelled [label] currently shows on its right.
String valueOfRow(WidgetTester tester, String label) {
  final row = tester.widget<SettingRow>(
    find.widgetWithText(SettingRow, label).first,
  );
  return row.value;
}

/// Taps the row labelled [label] and waits for its editor.
Future<void> openRow(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.widgetWithText(SettingRow, label).first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(SettingRow, label).first);
  await tester.pumpAndSettle();
}

Finder get _confirmButton => find.widgetWithIcon(IconButton, Icons.check);

/// Whether the open editor can be confirmed at all — it cannot while the value
/// in it is one the screen would refuse.
bool confirmIsOffered(WidgetTester tester) =>
    tester.widget<IconButton>(_confirmButton).onPressed != null;

Future<void> confirmEditor(WidgetTester tester) async {
  await tester.tap(_confirmButton);
  await tester.pumpAndSettle();
}

Future<void> cancelEditor(WidgetTester tester) async {
  await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
  await tester.pumpAndSettle();
}
