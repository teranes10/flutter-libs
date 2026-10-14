import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

Widget _host(Widget child, {double width = 700}) => MaterialApp(
      builder: (context, home) => MediaQuery(data: MediaQueryData(size: Size(width, 800)), child: home!),
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: SizedBox(width: width, child: Align(alignment: Alignment.topLeft, child: child)))),
    );

List<Widget> _tiles() => const [
      TMetricTile(label: 'Total', value: '1'),
      TMetricTile(label: 'A much longer label here', value: 'Rs. 3,200,000'),
      TMetricTile(label: 'Mid', value: '22'),
    ];

List<double> _widths(WidgetTester tester) =>
    tester.widgetList(find.byType(TMetricTile)).map((e) => tester.getSize(find.byWidget(e)).width).toList();

void main() {
  testWidgets('min: content-sized, shrink-wrapped', (tester) async {
    await tester.pumpWidget(_host(TGrid(mainAxisSize: TGridMainAxisSize.min, children: _tiles())));
    final w = _widths(tester);
    expect(w[0], lessThan(w[1]));
    expect(tester.getSize(find.byType(TGrid)).width, lessThan(700));
  });

  testWidgets('uniformWidth: all tiles equal, capped at maxTileWidth', (tester) async {
    await tester.pumpWidget(_host(TGrid(mainAxisSize: TGridMainAxisSize.min, uniformWidth: true, maxTileWidth: 120, children: _tiles())));
    expect(_widths(tester).toSet(), {120.0});
  });

  testWidgets('max: grows to fill; auto grows on mobile only', (tester) async {
    await tester.pumpWidget(_host(TGrid(mainAxisSize: TGridMainAxisSize.max, children: _tiles())));
    expect(tester.getSize(find.byType(TGrid)).width, 700);
    await tester.pumpWidget(_host(TGrid(children: _tiles())));
    expect(tester.getSize(find.byType(TGrid)).width, lessThan(700));
    await tester.pumpWidget(_host(TGrid(children: _tiles()), width: 400));
    expect(tester.getSize(find.byType(TGrid)).width, 400);
  });

  testWidgets('TMetricGrid alias still works', (tester) async {
    await tester.pumpWidget(_host(TMetricGrid(minTileWidth: 0, children: _tiles())));
    expect(find.byType(TGrid), findsOneWidget);
  });
}
