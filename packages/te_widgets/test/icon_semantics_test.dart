import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('a labelled icon is announced even without a tap handler (e.g. a drag handle)', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              TIcon(icon: HugeIcons.strokeRoundedGripVertical, semanticLabel: 'Drag to reorder'),
              TIcon(icon: HugeIcons.strokeRoundedGripVertical, semanticLabel: 'Padded', padding: EdgeInsets.all(4)),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Drag to reorder'), findsOneWidget);
    expect(find.bySemanticsLabel('Padded'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a tappable labelled icon is still a button', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TIcon(icon: HugeIcons.strokeRoundedCancel01, semanticLabel: 'Close', onTap: () => taps++)),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Close'));
    expect(taps, 1);
    semantics.dispose();
  });
}
