import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TNumberField with splitStepper and inlineFloating centers floatingLabelAlignment', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TNumberField<int>(
            label: 'Width',
            value: 800,
            splitStepper: true,
            theme: TNumberFieldTheme.defaultTheme(theme.colorScheme).copyWith(
              labelPosition: TLabelPosition.inlineFloating,
              splitStepper: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final inputDecoratorFinder = find.byType(InputDecorator);
    expect(inputDecoratorFinder, findsOneWidget);

    final inputDecorator = tester.widget<InputDecorator>(inputDecoratorFinder);
    expect(inputDecorator.decoration.floatingLabelAlignment, equals(FloatingLabelAlignment.center));
  });

  testWidgets('TNumberField with splitStepper and no label centers value vertically', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TNumberField<int>(
            value: 800,
            splitStepper: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.textAlignVertical, equals(TextAlignVertical.center));
    expect(textField.textAlign, equals(TextAlign.center));
  });
}
