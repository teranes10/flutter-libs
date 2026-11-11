import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('TAlignedRow accepts children that contain a LayoutBuilder', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: TAlignedRow(
            left: [LayoutBuilder(builder: (_, c) => const SizedBox(width: 120, height: 30, child: Text('left')))],
            right: [LayoutBuilder(builder: (_, c) => const SizedBox(width: 120, height: 30, child: Text('right')))],
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('left'), findsOneWidget);
    expect(find.text('right'), findsOneWidget);
  });
}
