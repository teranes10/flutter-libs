import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? TAppTheme.defaultTheme().lightTheme,
      home: Scaffold(body: Center(child: SizedBox(width: 340, child: child))),
    );

void main() {
  testWidgets('single: tapping a day reports it', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(_wrap(TCalendarPicker.single(
      value: DateTime(2024, 3, 10),
      onChanged: (d) => picked = d,
    )));
    expect(find.text('March 2024'), findsOneWidget);
    await tester.tap(find.text('15'));
    expect(picked, DateTime(2024, 3, 15));
  });

  testWidgets('single: days outside first/last are not selectable', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(_wrap(TCalendarPicker.single(
      value: DateTime(2024, 3, 10),
      firstDate: DateTime(2024, 3, 5),
      lastDate: DateTime(2024, 3, 20),
      onChanged: (d) => picked = d,
    )));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('25'));
    expect(picked, isNull);
    await tester.tap(find.text('7'));
    expect(picked, DateTime(2024, 3, 7));
  });

  testWidgets('month navigation and year/month jump', (tester) async {
    await tester.pumpWidget(_wrap(TCalendarPicker.single(value: DateTime(2024, 3, 10), onChanged: (_) {})));
    await tester.tap(find.byIcon(Icons.chevron_right).evaluate().isEmpty ? find.byType(TIcon).last : find.byIcon(Icons.chevron_right));
    await tester.pump();
    expect(find.text('April 2024'), findsOneWidget);
    await tester.tap(find.text('April 2024'));
    await tester.pump();
    expect(find.text('Jun'), findsOneWidget);
    await tester.tap(find.text('Jun'));
    await tester.pump();
    expect(find.text('June 2024'), findsOneWidget);
  });

  testWidgets('range: start, end, restart and tap-before-start', (tester) async {
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day);
    DateTime? s, e;
    await tester.pumpWidget(_wrap(StatefulBuilder(builder: (context, setState) {
      return TCalendarPicker.range(
        start: s,
        end: e,
        onRangeChanged: (a, b) => setState(() {
          s = a;
          e = b;
        }),
      );
    })));
    await tester.tap(find.text('10'));
    await tester.pump();
    expect((s, e), (d(10), null));
    await tester.tap(find.text('5'));
    await tester.pump();
    expect((s, e), (d(5), null), reason: 'before start moves the start');
    await tester.tap(find.text('12'));
    await tester.pump();
    expect((s, e), (d(5), d(12)));
    await tester.tap(find.text('20'));
    await tester.pump();
    expect((s, e), (d(20), null), reason: 'tap after a complete range starts a new one');
  });

  for (final glass in [false, true]) {
    testWidgets('TDatePicker / TDateRangePicker popups open (glass=$glass)', (tester) async {
      var theme = TAppTheme.defaultTheme().lightTheme;
      if (glass) theme = theme.copyWith(extensions: [theme.extension<TWidgetThemeExtension>()!.copyWith(glass: const TGlassStyle())]);

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      DateTimeRange? range;
      await tester.pumpWidget(_wrap(
        Column(mainAxisSize: MainAxisSize.min, children: [
          TDatePicker(label: 'D'),
          TDateRangePicker(label: 'R', onValueChanged: (r) => range = r),
        ]),
        theme: theme,
      ));

      await tester.tap(find.byType(TIcon).first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.byType(TCalendarPicker), findsOneWidget);
      await tester.tapAt(const Offset(5, 5)); // dismiss
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.byType(TIcon).at(1));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      final now = DateTime.now();
      await tester.tap(find.text('10').first);
      await tester.pump();
      await tester.tap(find.text('20').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(range, DateTimeRange(start: DateTime(now.year, now.month, 10), end: DateTime(now.year, now.month, 20)));
    });
  }
}
