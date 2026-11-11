import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('TTreeCard expands and collapses children', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TTreeCard(
            header: const Text('Parent'),
            children: [
              TTile(title: 'Child A').card(),
              TTreeCard(header: TTile(title: 'Child B'), initiallyExpanded: true, children: [
                TTile(title: 'Leaf', values: [TKeyValue('K', value: 'V')]).card()
              ])
            ],
          ),
        ),
      ),
    ));
    expect(find.text('Child A'), findsNothing);
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(find.text('Child A'), findsOneWidget);
    expect(find.text('Child B'), findsOneWidget);
    expect(find.text('Leaf'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(find.text('Child A'), findsNothing);
  });

  testWidgets('Widget.treeCard extension builds a TTreeCard', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: const Text('P').treeCard(initiallyExpanded: true, children: const [Text('C')])),
    ));
    expect(find.byType(TTreeCard), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });
}
