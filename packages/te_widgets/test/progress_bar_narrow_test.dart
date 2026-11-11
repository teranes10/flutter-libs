import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('TProgressBar label and value do not overflow in a narrow cell', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 80,
          child: TProgressBar(value: 0.45, label: 'Completion', showPercentage: true),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Completion'), findsOneWidget);
  });
}
