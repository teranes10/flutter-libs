import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;
  for (final type in [TButtonType.tonal, TButtonType.solid]) {
    testWidgets('fill $type', (tester) async {
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Scaffold(
              body: SizedBox(
                  width: 300,
                  child: TAlignedRow(
                      moveAllToSecondRow: true,
                      wrapperExpanded: true,
                      wrapperModeThreshold: 2,
                      left: [TButton(type: type, text: 'Add New', onPressed: (_) {})],
                      right: [SizedBox(width: 275, height: 38), SizedBox(width: 40, height: 38)])))));
      for (final t in [ElevatedButton, Ink, Container]) {
        final f = find.descendant(of: find.byType(TButton), matching: find.byType(t)).first;
        debugPrint('$type $t ${tester.getSize(f)}');
      }
      await tester.pump();
      await tester.pump();
      for (final t in [Ink]) {
        debugPrint('after ${tester.getSize(find.descendant(of: find.byType(TButton), matching: find.byType(t)).first)}');
      }
      debugPrint('TButton ${tester.getSize(find.byType(TButton))}');
    });
  }
}
