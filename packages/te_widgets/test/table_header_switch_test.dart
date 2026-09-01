import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _TestModel {
  String name;
  bool isEnabled;
  bool isArchived;

  _TestModel(this.name, this.isEnabled, this.isArchived);
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  group('TTableHeader.toggle tests', () {
    testWidgets('Renders TSwitch and handles value changes', (tester) async {
      final items = [
        _TestModel('Item 1', true, false),
        _TestModel('Item 2', false, true),
      ];

      final headers = [
        TTableHeader<_TestModel, String>.map('Name', (x) => x.name),
        TTableHeader<_TestModel, String>.toggle(
          'Enabled',
          (x) => x.isEnabled,
          (x, v) => x.isEnabled = v,
        ),
        TTableHeader<_TestModel, String>.toggle(
          'Archived',
          (x) => x.isArchived,
          (x, v) => x.isArchived = v,
          isDisabled: (x) => x.name == 'Item 1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestModel, String>(
              items: items,
              itemKey: (i) => i.name,
              headers: headers,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find switches
      final switches = find.byType(TSwitch);
      expect(switches, findsNWidgets(4)); // 2 rows * 2 switch columns

      // Verify initial values
      final firstRowEnabledSwitch = tester.widget<TSwitch>(switches.at(0));
      final firstRowArchivedSwitch = tester.widget<TSwitch>(switches.at(1));
      expect(firstRowEnabledSwitch.value, isTrue);
      expect(firstRowArchivedSwitch.value, isFalse);
      expect(firstRowArchivedSwitch.disabled, isTrue); // Item 1 isDisabled returned true

      // Toggle first row enabled switch
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();

      expect(items[0].isEnabled, isFalse);
    });
  });
}
