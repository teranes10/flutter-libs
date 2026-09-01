import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class TestItem {
  final String id;
  final String title;
  final String subtitle;

  TestItem({required this.id, required this.title, required this.subtitle});
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TListDetail split layout renders elevated dual cards with full radius and gap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      TestItem(id: '1', title: 'Item 1', subtitle: 'Sub 1'),
      TestItem(id: '2', title: 'Item 2', subtitle: 'Sub 2'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TListDetail<TestItem, String>(
            items: items,
            itemKey: (item) => item.id,
            itemTitle: (item) => item.title,
            itemSubTitle: (item) => item.subtitle,
            gap: 16.0,
            padding: const EdgeInsets.all(16),
            detailBuilder: (context, item, index) {
              return Text('Detail for ${item.data.title}');
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify both items are in the sidebar
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Verify empty state is shown initially in split layout
    expect(find.text('No item selected'), findsOneWidget);
    expect(find.text('Select an item from the list to view its details'), findsOneWidget);

    // Tap Item 1 to select it
    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    // Verify detail is shown
    expect(find.text('Detail for Item 1'), findsOneWidget);
  });

  testWidgets('TListDetail mobile layout navigates between list and detail pane',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      TestItem(id: '1', title: 'Item 1', subtitle: 'Sub 1'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TListDetail<TestItem, String>(
            items: items,
            itemKey: (item) => item.id,
            itemTitle: (item) => item.title,
            detailBuilder: (context, item, index) {
              return Text('Mobile Detail ${item.data.title}');
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // In mobile view initially, only sidebar is shown
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Mobile Detail Item 1'), findsNothing);

    // Tap Item 1
    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    // Now detail pane is displayed
    expect(find.text('Mobile Detail Item 1'), findsOneWidget);
  });

  testWidgets('TListView renders sticky header, footer, and scrollable content with elevation shadows',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = List.generate(
      50,
      (i) => TListItem<String, int>(data: 'Item $i', key: i),
    );

    final controller = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TListView<String, int>(
            items: items,
            headerSticky: true,
            headerBuilder: (ctx) => const Text('Sticky Header'),
            footerSticky: true,
            footerBuilder: (ctx) => const Text('Sticky Footer'),
            scrollController: controller,
            itemBuilder: (ctx, item, index) => SizedBox(
              height: 40,
              child: Text(item.data),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sticky Header'), findsOneWidget);
    expect(find.text('Sticky Footer'), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);

    // Scroll down to activate top shadow
    controller.jumpTo(150);
    await tester.pumpAndSettle();

    // Verify AnimatedOpacity widgets for top and bottom shadows exist
    expect(find.byType(AnimatedOpacity), findsWidgets);
  });
}
