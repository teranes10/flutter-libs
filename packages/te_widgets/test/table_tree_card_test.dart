import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _Node {
  final String id;
  final String name;
  final List<_Node> children;
  const _Node(this.id, this.name, [this.children = const []]);
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;
  const tree = [
    _Node('a', 'Alpha', [
      _Node('a1', 'Alpha One', [_Node('a11', 'Deep Leaf')]),
    ]),
    _Node('b', 'Beta'),
  ];

  for (final width in [1200.0, 420.0]) {
    testWidgets('hierarchical TTable renders nested TTreeCards at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = TListController<_Node, String>(
        items: tree,
        itemKey: (n) => n.id,
        itemChildren: (n) => n.children,
        expansionMode: TExpansionMode.multiple,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_Node, String>(
            controller: controller,
            headers: [TTableHeader<_Node, String>('Name', map: (n) => n.name)],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Alpha One'), findsNothing);

      controller.expand('a');
      await tester.pumpAndSettle();
      expect(find.text('Alpha One'), findsOneWidget);
      expect(find.text('Deep Leaf'), findsNothing);

      controller.expand('a1');
      await tester.pumpAndSettle();
      expect(find.text('Deep Leaf'), findsOneWidget);
      expect(find.byType(TTreeCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('nested rows keep non-first columns straight (only the first column gives up the indent)', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = TListController<_Node, String>(
      items: tree,
      itemKey: (n) => n.id,
      itemChildren: (n) => n.children,
      expansionMode: TExpansionMode.multiple,
    );
    addTearDown(controller.dispose);
    controller.expand('a');
    controller.expand('a1');

    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: TTable<_Node, String>(
          controller: controller,
          headers: [
            TTableHeader<_Node, String>('Name', map: (n) => n.name),
            TTableHeader<_Node, String>('Code', map: (n) => 'code-${n.id}', minWidth: 120, maxWidth: 120),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final xs = [
      for (final id in ['a', 'a1', 'a11', 'b']) tester.getTopLeft(find.text('code-$id')).dx
    ];
    expect(xs.toSet().length, 1, reason: 'Code column x positions: $xs');
    final nameXs = [
      for (final n in ['Alpha', 'Alpha One', 'Deep Leaf']) tester.getTopLeft(find.text(n)).dx
    ];
    expect(nameXs[1], greaterThan(nameXs[0]));
    expect(nameXs[2], greaterThan(nameXs[1]));
  });
}
