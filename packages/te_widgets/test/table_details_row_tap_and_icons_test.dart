import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _TestRowItem {
  final String id;
  final String title;
  final String subtitle;

  const _TestRowItem(this.id, this.title, this.subtitle);
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  final items = [
    const _TestRowItem('1', 'Alpha Item', 'Subtitle A'),
    const _TestRowItem('2', 'Beta Item', 'Subtitle B'),
  ];

  final headers = [
    TTableHeader<_TestRowItem, String>.map('Title', (item) => item.title),
    TTableHeader<_TestRowItem, String>.map('Subtitle', (item) => item.subtitle),
  ];

  group('TTable Details HugeIcons & Row Tap Support', () {
    testWidgets('TTable uses HugeIcon by default for details expand icon', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                builder: (ctx, item, index) => Text('Details Content for ${item.data.title}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // HugeIcon should be rendered in the table row
      expect(find.byType(HugeIcon), findsWidgets);
      expect(find.text('Details Content for Alpha Item'), findsNothing);
    });

    testWidgets('Tapping on a table row card expands its details by default (expandOnRowTap: true)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                builder: (ctx, item, index) => Text('Details Content for ${item.data.title}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Details Content for Alpha Item'), findsNothing);

      // Tap on the row text (not the icon directly)
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle();

      // Details should now be expanded
      expect(find.text('Details Content for Alpha Item'), findsOneWidget);

      // Tapping again collapses the row details
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle();

      expect(find.text('Details Content for Alpha Item'), findsNothing);
    });

    testWidgets('TTable with expandOnRowTap: false does not expand details when row is tapped', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                expandOnRowTap: false,
                builder: (ctx, item, index) => Text('Details Content for ${item.data.title}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the row text
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle();

      // Details should NOT be expanded
      expect(find.text('Details Content for Alpha Item'), findsNothing);

      // Tapping on the expansion icon itself should still expand
      final iconFinder = find.byType(TIcon).first;
      await tester.tap(iconFinder);
      await tester.pumpAndSettle();

      expect(find.text('Details Content for Alpha Item'), findsOneWidget);
    });

    testWidgets('TTable supports custom expandIcon and collapseIcon', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                expandIcon: Icons.add_circle_outline,
                collapseIcon: Icons.remove_circle_outline,
                builder: (ctx, item, index) => Text('Details Content for ${item.data.title}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display custom add icon when collapsed
      expect(find.byIcon(Icons.add_circle_outline), findsWidgets);
      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle();

      // Should display custom remove icon when expanded
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('TTable mobile card view supports row tap to expand details', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              theme: theme.extension<TWidgetThemeExtension>()!.tableTheme.copyWith(forceCardStyle: true),
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                builder: (ctx, item, index) => Text('Mobile Details Content for ${item.data.title}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TTableMobileCard<_TestRowItem, String>), findsWidgets);
      expect(find.text('Mobile Details Content for Alpha Item'), findsNothing);

      // Tap on mobile card
      await tester.tap(find.text('Alpha Item'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Details Content for Alpha Item'), findsOneWidget);
    });

    testWidgets('TTable enables SelectionArea by default and can be disabled via selectableText: false', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Default selectableText: true
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SelectionArea), findsOneWidget);

      // selectableText: false
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: items,
              itemKey: (i) => i.id,
              headers: headers,
              selectableText: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SelectionArea), findsNothing);
    });

    testWidgets('TTable renders dialog mode HugeIcon (strokeRoundedArrowUp02)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: [items.first],
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.dialog,
                builder: (ctx, item, index) => const Text('Details'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hugeIcons = tester.widgetList<HugeIcon>(find.byType(HugeIcon));
      expect(hugeIcons.any((h) => identical(h.icon, HugeIcons.strokeRoundedArrowUp02)), isTrue);
    });

    testWidgets('TTable renders sideOverlay mode HugeIcon (strokeRoundedArrowUpRight01)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: [items.first],
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.sideOverlay,
                builder: (ctx, item, index) => const Text('Details'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hugeIcons = tester.widgetList<HugeIcon>(find.byType(HugeIcon));
      expect(hugeIcons.any((h) => identical(h.icon, HugeIcons.strokeRoundedArrowUpRight01)), isTrue);
    });

    testWidgets('TTable renders side mode HugeIcon (strokeRoundedArrowRight01)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: [items.first],
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.side,
                itemTitle: (i) => i.title,
                builder: (ctx, item, index) => const Text('Details'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hugeIcons = tester.widgetList<HugeIcon>(find.byType(HugeIcon));
      expect(hugeIcons.any((h) => identical(h.icon, HugeIcons.strokeRoundedArrowRight01)), isTrue);
    });

    testWidgets('TTable renders page mode HugeIcon (strokeRoundedLinkForward)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: [items.first],
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.page,
                builder: (ctx, item, index) => const Text('Details'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hugeIcons = tester.widgetList<HugeIcon>(find.byType(HugeIcon));
      expect(hugeIcons.any((h) => identical(h.icon, HugeIcons.strokeRoundedLinkForward)), isTrue);
    });

    testWidgets('TTable renders bottom mode HugeIcon (strokeRoundedArrowDown01)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTable<_TestRowItem, String>(
              items: [items.first],
              itemKey: (i) => i.id,
              headers: headers,
              details: TTableDetails(
                mode: TTableExpansionMode.bottom,
                builder: (ctx, item, index) => const Text('Details'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hugeIcons = tester.widgetList<HugeIcon>(find.byType(HugeIcon));
      expect(hugeIcons.any((h) => identical(h.icon, HugeIcons.strokeRoundedArrowDown01)), isTrue);
    });
  });
}
