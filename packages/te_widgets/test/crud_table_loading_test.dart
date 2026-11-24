import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _NoForm extends TFormBase {}

void main() {
  testWidgets('first load: the crud table keeps its chrome, shows skeleton rows and skeleton metric values', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TListController<String, String>(itemKey: (s) => s, items: const [], loading: true);
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TCrudTable<String, String, _NoForm>(
          controller: controller,
          itemTitle: (s) => s,
          headers: [TTableHeader.map('Name', (s) => s), TTableHeader.map('Length', (s) => '${s.length}')],
          config: TCrudConfig<String, String>(
            pageTitle: 'Things',
            topBarMetricsBuilder: (items) => [TMetricTile(label: 'Total', value: '${items.length}')],
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Things'), findsOneWidget, reason: 'page chrome renders while loading');
    expect(find.text('Total'), findsOneWidget, reason: 'metric label stays');
    expect(find.text('0'), findsNothing, reason: 'no fake "0" value before data');
    expect(find.byKey(const ValueKey('list_skeleton')), findsOneWidget);

    controller.updateItems(['alpha', 'beta']);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const ValueKey('list_skeleton')), findsNothing);
    expect(find.text('alpha'), findsWidgets);
    expect(find.text('2'), findsWidgets, reason: 'metric value appears once loaded');
  });

  testWidgets('TMetricTile.loading shows a value skeleton, label stays', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TMetricTile(label: 'Total', value: '42', loading: true)),
    ));
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('42'), findsNothing);
    expect(find.byType(TSkeleton), findsOneWidget);
  });
}
