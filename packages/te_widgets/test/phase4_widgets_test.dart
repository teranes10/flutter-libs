import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TSplitPane Tests', () {
    testWidgets('renders leading and trailing panes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TSplitPane(
                leading: Text('Left Pane Content'),
                trailing: Text('Right Pane Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Left Pane Content'), findsOneWidget);
      expect(find.text('Right Pane Content'), findsOneWidget);
    });

    testWidgets('supports programmatic resizing and collapse via controller', (tester) async {
      final controller = TSplitPaneController(initialRatio: 0.5);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TSplitPane(
                controller: controller,
                leading: const Text('Left Pane'),
                trailing: const Text('Right Pane'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.ratio, equals(0.5));
      expect(controller.isLeadingCollapsed, isFalse);

      // Collapse leading
      controller.collapseLeading();
      await tester.pumpAndSettle();
      expect(controller.isLeadingCollapsed, isTrue);
      expect(find.text('Left Pane'), findsNothing);

      // Expand
      controller.expand();
      await tester.pumpAndSettle();
      expect(controller.isLeadingCollapsed, isFalse);
      expect(find.text('Left Pane'), findsOneWidget);

      // Collapse trailing
      controller.collapseTrailing();
      await tester.pumpAndSettle();
      expect(controller.isTrailingCollapsed, isTrue);
      expect(find.text('Right Pane'), findsNothing);
    });

    testWidgets('dragging divider resizes panes', (tester) async {
      double latestRatio = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TSplitPane(
                initialRatio: 0.5,
                onResized: (r) => latestRatio = r,
                leading: const Text('Left Pane'),
                trailing: const Text('Right Pane'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the divider and drag it to the right
      final gestureFinder = find.byType(GestureDetector);
      expect(gestureFinder, findsWidgets);

      await tester.drag(gestureFinder.first, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(latestRatio, greaterThan(0.5));
    });
  });

  group('TWatermark Tests', () {
    testWidgets('renders child content and watermark overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TWatermark(
              text: 'CONFIDENTIAL',
              child: Text('Protected Records'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protected Records'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('disabled watermark does not render overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TWatermark(
              text: 'CONFIDENTIAL',
              enabled: false,
              child: Text('Normal Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Normal Content'), findsOneWidget);
    });
  });

  group('TTransferList Tests', () {
    testWidgets('renders source and target lists and transfers checked item', (tester) async {
      final source = ['Apple', 'Banana', 'Orange', 'Mango'];
      final target = <String>['Grape'];

      List<String> currentSource = List.from(source);
      List<String> currentTarget = List.from(target);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: TTransferList<String>(
                  sourceItems: currentSource,
                  targetItems: currentTarget,
                  onTargetChanged: (newTarget) {
                    setState(() => currentTarget = newTarget);
                  },
                  onSourceChanged: (newSource) {
                    setState(() => currentSource = newSource);
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both lists are rendered
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Grape'), findsOneWidget);

      // Check 'Apple'
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // Tap transfer to right ('>')
      final rightBtn = find.byTooltip('Transfer Selected to Right');
      expect(rightBtn, findsOneWidget);
      await tester.tap(rightBtn);
      await tester.pumpAndSettle();

      // Apple should now be in target and removed from source
      expect(currentTarget.contains('Apple'), isTrue);
      expect(currentSource.contains('Apple'), isFalse);
    });

    testWidgets('transfers all items on >> button', (tester) async {
      List<String> currentSource = ['Item 1', 'Item 2'];
      List<String> currentTarget = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: TTransferList<String>(
                  sourceItems: currentSource,
                  targetItems: currentTarget,
                  onTargetChanged: (newTarget) {
                    setState(() => currentTarget = newTarget);
                  },
                  onSourceChanged: (newSource) {
                    setState(() => currentSource = newSource);
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap transfer all to right ('>>')
      final moveAllRightBtn = find.byTooltip('Transfer All to Right');
      await tester.tap(moveAllRightBtn);
      await tester.pumpAndSettle();

      expect(currentTarget.length, equals(2));
      expect(currentSource.isEmpty, isTrue);
    });

    testWidgets('filters items via search query', (tester) async {
      final currentSource = ['California', 'Texas', 'New York', 'Florida'];
      final currentTarget = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TTransferList<String>(
              sourceItems: currentSource,
              targetItems: currentTarget,
              onTargetChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('California'), findsOneWidget);
      expect(find.text('Texas'), findsOneWidget);

      // Enter search text in first search field
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Calif');
      await tester.pumpAndSettle();

      expect(find.text('California'), findsOneWidget);
      expect(find.text('Texas'), findsNothing);
    });
  });
}
