import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('TColorPicker renders onlyPlusIcon mode correctly', (WidgetTester tester) async {
    final notifier = ValueNotifier<Color?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TColorPicker(
            label: 'Test Color',
            valueNotifier: notifier,
            onlyPlusIcon: true,
          ),
        ),
      ),
    );

    expect(find.text('Test Color'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('TFormField.colorPicker creates valid form field', (WidgetTester tester) async {
    final colorProp = TFieldProp<Color?>(null);
    final formField = TFormField.colorPicker(
      colorProp,
      'Form Color',
      onlyPlusIcon: true,
    );

    expect(formField, isNotNull);
  });
}
