import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)));

const _items = [
  TRadioGroupItem(value: 'urgent', label: 'Urgent', icon: HugeIcons.strokeRoundedBolt, description: 'Within 2 h'),
  TRadioGroupItem(value: 'same_day', label: 'Same-day', icon: HugeIcons.strokeRoundedCalendar03, description: 'Today'),
];

void main() {
  testWidgets('vertical tiles: one row, icon above label, description as tooltip, tick on the selected, no field box', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(_host(TRadioGroup<String>(
      label: 'Service',
      tile: true,
      tileDirection: Axis.vertical,
      items: _items,
      onValueChanged: (v) => picked = v,
    )));
    expect(tester.takeException(), isNull);
    expect(find.byType(InputDecorator), findsNothing, reason: 'tiles are boxes: no field box around them');
    expect(find.textContaining('Service', findRichText: true), findsOneWidget);

    final urgent = tester.getCenter(find.text('Urgent'));
    final sameDay = tester.getCenter(find.text('Same-day'));
    expect(urgent.dy, sameDay.dy, reason: 'side by side');
    expect(find.byType(TTooltip), findsNWidgets(2));
    expect(find.text('Within 2 h'), findsNothing, reason: 'description is a tooltip, not body text');

    final tiles = find.byType(TOptionTile);
    expect(tester.getSize(tiles.at(0)).height, tester.getSize(tiles.at(1)).height);

    await tester.tap(find.text('Same-day'));
    await tester.pumpAndSettle();
    expect(picked, 'same_day');
    expect(tester.widgetList<TOptionTile>(tiles).map((t) => t.selected), [false, true]);
  });

  testWidgets('row tiles keep the description under the label', (tester) async {
    await tester.pumpWidget(_host(TRadioGroup<String>(label: 'Service', tile: true, items: _items)));
    expect(tester.takeException(), isNull);
    expect(find.text('Within 2 h'), findsOneWidget);
    expect(tester.getCenter(find.text('Urgent')).dy, lessThan(tester.getCenter(find.text('Same-day')).dy));
  });
}
