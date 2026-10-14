import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

Widget _host(Widget child) => MaterialApp(
      theme: TAppTheme.defaultTheme().lightTheme,
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: SizedBox(width: 400, child: child))),
    );

void main() {
  testWidgets('TTile shrinks without trailing and expands with it', (tester) async {
    await tester.pumpWidget(_host(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TTile(key: Key('a'), title: 'Short', icon: Icons.star),
      TTile(key: Key('b'), title: 'Short', icon: Icons.star, trailing: Icon(Icons.chevron_right)),
    ])));
    expect(tester.getSize(find.byKey(const Key('a'))).width, lessThan(200));
    expect(tester.getSize(find.byKey(const Key('b'))).width, 400);
  });

  testWidgets('TTile iconOnTop stacks icon above title', (tester) async {
    await tester.pumpWidget(_host(const TTile(iconOnTop: true, title: 'Hub', icon: Icons.star)));
    expect(tester.getTopLeft(find.byIcon(Icons.star)).dy, lessThan(tester.getTopLeft(find.text('Hub')).dy));
  });

  testWidgets('.card wraps in TCard with shadow level', (tester) async {
    await tester.pumpWidget(_host(const Text('x').card(shadow: TCardShadow.lg)));
    expect(tester.widget<TCard>(find.byType(TCard)).shadowLevel, TCardShadow.lg);
  });

  testWidgets('TAccordion shows image-tile header trailing and expands', (tester) async {
    await tester.pumpWidget(_host(const TAccordion(
      size: TTileSize.md,
      title: 'Watch',
      subtitle: 'SKU 1',
      trailing: Text('\$9'),
      content: Text('details'),
    )));
    expect(find.text('\$9'), findsOneWidget);
    await tester.tap(find.text('Watch'));
    await tester.pumpAndSettle();
    expect(find.text('details'), findsOneWidget);
  });
}
