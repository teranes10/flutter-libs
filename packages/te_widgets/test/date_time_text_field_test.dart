import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  group('TDateTimeInputFormatter.format and TDateTimeFormatType.format', () {
    test('Date formatting handles various inputs', () {
      final type = TDateTimeFormatType.date;

      // Null / empty
      expect(type.format(null), 'DD/MM/YYYY');
      expect(type.format(''), 'DD/MM/YYYY');
      expect(type.format('DD/MM/YYYY'), 'DD/MM/YYYY');

      // ISO dates
      expect(type.format('2024-05-18'), '18/05/2024');
      expect(type.format('2024-05-18T14:30:00'), '18/05/2024');
      expect(type.format('2024-05-18T14:30:00.000Z'), '18/05/2024');
      expect(type.format('2024/05/18'), '18/05/2024');
      expect(type.format('2024.05.18'), '18/05/2024');
      expect(type.format('2024-5-8'), '08/05/2024');

      // Standard dates
      expect(type.format('18/05/2024'), '18/05/2024');
      expect(type.format('18-05-2024'), '18/05/2024');
      expect(type.format('18.05.2024'), '18/05/2024');
      expect(type.format('8/5/2024'), '08/05/2024');

      // Raw digits
      expect(type.format('18052024'), '18/05/2024');
      expect(type.format('20240518'), '18/05/2024');
      expect(type.format('1805'), '18/05/YYYY');
      expect(type.format('18'), '18/MM/YYYY');

      // DateTime object
      expect(type.format(DateTime(2024, 5, 18, 14, 30)), '18/05/2024');

      // Time only should not be parsed as date
      expect(type.format('14:30'), 'DD/MM/YYYY');
    });

    test('Time formatting handles various inputs', () {
      final type = TDateTimeFormatType.time;

      // Null / empty
      expect(type.format(null), 'HH:MM');
      expect(type.format(''), 'HH:MM');
      expect(type.format('HH:MM'), 'HH:MM');

      // 24h format
      expect(type.format('14:30'), '14:30');
      expect(type.format('14:30:00'), '14:30');
      expect(type.format('9:30'), '09:30');
      expect(type.format('9:5'), '09:05');

      // 12h AM/PM
      expect(type.format('2:30 PM'), '14:30');
      expect(type.format('2:30 AM'), '02:30');
      expect(type.format('12:30 AM'), '00:30');
      expect(type.format('12:30 PM'), '12:30');
      expect(type.format('10:15 pm'), '22:15');

      // ISO strings
      expect(type.format('2024-05-18T14:30:00'), '14:30');
      expect(type.format('2024-05-18 14:30:00'), '14:30');

      // Raw digits
      expect(type.format('1430'), '14:30');
      expect(type.format('930'), '09:30');
      expect(type.format('14'), '14:MM');

      // DateTime object
      expect(type.format(DateTime(2024, 5, 18, 14, 30)), '14:30');

      // Date only should not be parsed as time
      expect(type.format('2024-05-18'), 'HH:MM');
      expect(type.format('18/05/2024'), 'HH:MM');
    });

    test('DateTime formatting handles various inputs', () {
      final type = TDateTimeFormatType.dateTime;

      // Null / empty
      expect(type.format(null), 'DD/MM/YYYY HH:MM');
      expect(type.format(''), 'DD/MM/YYYY HH:MM');
      expect(type.format('DD/MM/YYYY HH:MM'), 'DD/MM/YYYY HH:MM');

      // ISO strings
      expect(type.format('2024-05-18T14:30:00'), '18/05/2024 14:30');
      expect(type.format('2024-05-18 14:30'), '18/05/2024 14:30');
      expect(type.format('2024-05-18 14:30:00'), '18/05/2024 14:30');

      // Slash and dash formats
      expect(type.format('18/05/2024 14:30'), '18/05/2024 14:30');
      expect(type.format('18-05-2024 14:30'), '18/05/2024 14:30');
      expect(type.format('18.05.2024 14:30'), '18/05/2024 14:30');
      expect(type.format('8/5/2024 9:30'), '08/05/2024 09:30');

      // Date only
      expect(type.format('2024-05-18'), '18/05/2024 HH:MM');
      expect(type.format('18/05/2024'), '18/05/2024 HH:MM');

      // Time only
      expect(type.format('14:30'), 'DD/MM/YYYY 14:30');

      // Raw digits
      expect(type.format('180520241430'), '18/05/2024 14:30');
      expect(type.format('18052024'), '18/05/2024 HH:MM');

      // DateTime object
      expect(type.format(DateTime(2024, 5, 18, 14, 30)), '18/05/2024 14:30');
    });
  });

  group('TDateTimeTextField Widget tests', () {
    final theme = TAppTheme.defaultTheme().lightTheme;

    testWidgets('formats initial value correctly for date, time, and dateTime', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TDateTimeTextField(
                  key: const Key('dateField'),
                  label: 'Date',
                  formatType: TDateTimeFormatType.date,
                  value: '2024-05-18',
                ),
                TDateTimeTextField(
                  key: const Key('timeField'),
                  label: 'Time',
                  formatType: TDateTimeFormatType.time,
                  value: '14:30:00',
                ),
                TDateTimeTextField(
                  key: const Key('dateTimeField'),
                  label: 'DateTime',
                  formatType: TDateTimeFormatType.dateTime,
                  value: '2024-05-18T14:30:00',
                ),
                TDateTimeTextField(
                  key: const Key('rawDigitsField'),
                  label: 'Raw',
                  formatType: TDateTimeFormatType.date,
                  value: '18052024',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify date field text is 18/05/2024
      final dateFinder = find.byKey(const Key('dateField'));
      expect(find.descendant(of: dateFinder, matching: find.text('18/05/2024')), findsOneWidget);

      // Verify time field text is 14:30
      final timeFinder = find.byKey(const Key('timeField'));
      expect(find.descendant(of: timeFinder, matching: find.text('14:30')), findsOneWidget);

      // Verify dateTime field text is 18/05/2024 14:30
      final dateTimeFinder = find.byKey(const Key('dateTimeField'));
      expect(find.descendant(of: dateTimeFinder, matching: find.text('18/05/2024 14:30')), findsOneWidget);

      // Verify raw digits field is formatted
      final rawFinder = find.byKey(const Key('rawDigitsField'));
      expect(find.descendant(of: rawFinder, matching: find.text('18/05/2024')), findsOneWidget);
    });

    testWidgets('auto-formats when external valueNotifier changes', (tester) async {
      final dateNotifier = ValueNotifier<String?>('2024-05-18');

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TDateTimeTextField(
              key: const Key('dateField'),
              label: 'Date',
              formatType: TDateTimeFormatType.date,
              valueNotifier: dateNotifier,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('18/05/2024'), findsOneWidget);

      // Update external value to ISO string
      dateNotifier.value = '2024-12-25';
      await tester.pumpAndSettle();
      expect(find.text('25/12/2024'), findsOneWidget);

      // Update external value to raw digits
      dateNotifier.value = '01012025';
      await tester.pumpAndSettle();
      expect(find.text('01/01/2025'), findsOneWidget);

      // Clear external value
      dateNotifier.value = null;
      await tester.pumpAndSettle();
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller.text, 'DD/MM/YYYY');
    });

    testWidgets('auto-formats when widget value prop changes in parent rebuild', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: _ParentTestWidget(initialDate: '2024-05-18'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('18/05/2024'), findsOneWidget);

      // Tap change button
      await tester.tap(find.byKey(const Key('changeBtn')));
      await tester.pumpAndSettle();
      expect(find.text('25/12/2024'), findsOneWidget);
    });

    testWidgets('formats custom textController on init', (tester) async {
      final controller = TextEditingController(text: '2024-05-18');

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TDateTimeTextField(
              textController: controller,
              formatType: TDateTimeFormatType.date,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(controller.text, '18/05/2024');
    });
  });
}

class _ParentTestWidget extends StatefulWidget {
  final String initialDate;
  const _ParentTestWidget({required this.initialDate});

  @override
  State<_ParentTestWidget> createState() => _ParentTestWidgetState();
}

class _ParentTestWidgetState extends State<_ParentTestWidget> {
  late String? _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TDateTimeTextField(
          key: const Key('dateField'),
          label: 'Date',
          formatType: TDateTimeFormatType.date,
          value: _date,
        ),
        ElevatedButton(
          key: const Key('changeBtn'),
          onPressed: () {
            setState(() {
              _date = '2024-12-25';
            });
          },
          child: const Text('Change Date'),
        ),
      ],
    );
  }
}
