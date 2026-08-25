import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TTabs with Axis.vertical expands all tabs to the width of the widest tab', (WidgetTester tester) async {
    final tabs = [
      TTab<String>(value: 'short', text: 'Short', icon: Icons.person),
      TTab<String>(value: 'long', text: 'A Very Long Tab Title For Width Testing', icon: Icons.badge),
      TTab<String>(value: 'med', text: 'Medium Title', icon: Icons.settings),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TTabs<String>(
              axis: Axis.vertical,
              tabs: tabs,
            ),
          ),
        ),
      ),
    );

    // Find the InkWell widgets for each tab
    final inkWells = find.byType(InkWell);
    expect(inkWells, findsNWidgets(3));

    final size0 = tester.getSize(inkWells.at(0));
    final size1 = tester.getSize(inkWells.at(1));
    final size2 = tester.getSize(inkWells.at(2));

    // All tabs should have the exact same width equal to the widest tab
    expect(size0.width, equals(size1.width));
    expect(size1.width, equals(size2.width));
    expect(size0.width, greaterThan(150.0));
  });

  testWidgets('TTabs with Axis.vertical expands to available space when constrained by parent', (WidgetTester tester) async {
    final tabs = [
      TTab<String>(value: 'tab1', text: 'Tab 1', icon: Icons.person),
      TTab<String>(value: 'tab2', text: 'Tab 2', icon: Icons.badge),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: TTabs<String>(
                axis: Axis.vertical,
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
    );

    final inkWells = find.byType(InkWell);
    expect(inkWells, findsNWidgets(2));

    final size0 = tester.getSize(inkWells.at(0));
    final size1 = tester.getSize(inkWells.at(1));

    // Both tabs should have identical width, expanding to fill the parent
    expect(size0.width, equals(size1.width));
    expect(tester.getSize(find.byType(TTabs<String>)).width, equals(280.0));
  });

  testWidgets('TTabs with Axis.vertical and scrollable expands tabs to widest tab', (WidgetTester tester) async {
    final tabs = [
      TTab<String>(value: 'short', text: 'Short', icon: Icons.person),
      TTab<String>(value: 'long', text: 'Another Very Long Tab Name In Scrollable Mode', icon: Icons.badge),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 200,
              child: TTabs<String>(
                axis: Axis.vertical,
                scrollable: true,
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
    );

    final inkWells = find.byType(InkWell);
    expect(inkWells, findsNWidgets(2));

    final size0 = tester.getSize(inkWells.at(0));
    final size1 = tester.getSize(inkWells.at(1));

    expect(size0.width, equals(size1.width));
    expect(size0.width, greaterThan(200.0));
  });
}
