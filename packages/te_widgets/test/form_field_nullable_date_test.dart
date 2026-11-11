import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('TFormField.date and dateTime accept an optional (null) date', (tester) async {
    final startsAt = TFieldProp<DateTime?>(null);
    final endsAt = TFieldProp<DateTime?>(DateTime(2026, 12, 31));
    final required = TFieldProp<DateTime>(DateTime(2026, 1, 1));

    final fields = [
      TFormField.date(startsAt, 'Starts', clearable: true),
      TFormField.dateTime(endsAt, 'Ends', clearable: true),
      TFormField.date(required, 'Required'), // existing non-null usage still infers
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: TAppTheme.defaultTheme().lightTheme,
        home: Scaffold(body: Column(children: [for (final f in fields) Expanded(child: f.builder((_) {}))])),
      ),
    );
    await tester.pump();

    expect(startsAt.value, isNull);
    expect(endsAt.value, DateTime(2026, 12, 31));
    expect(find.byType(TDatePicker), findsNWidgets(2));
    expect(find.byType(TDateTimePicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
