import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TKanbanBoard Tests', () {
    testWidgets('renders columns and cards', (tester) async {
      final columns = [
        const TKanbanColumn<String>(
          id: 'col_1',
          title: 'To Do',
          items: [
            TKanbanCardItem(id: 'c1', title: 'Task 1', description: 'Description 1'),
            TKanbanCardItem(id: 'c2', title: 'Task 2'),
          ],
        ),
        const TKanbanColumn<String>(
          id: 'col_2',
          title: 'Done',
          items: [
            TKanbanCardItem(id: 'c3', title: 'Task 3'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TKanbanBoard<String>(columns: columns),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
    });

    testWidgets('fires onCardMoved when dragged to target column', (tester) async {
      TKanbanCardItem<String>? movedItem;
      String? sourceCol;
      String? targetCol;

      final columns = [
        const TKanbanColumn<String>(
          id: 'col_todo',
          title: 'To Do',
          items: [
            TKanbanCardItem(id: 'card_move', title: 'Move Me'),
          ],
        ),
        const TKanbanColumn<String>(
          id: 'col_done',
          title: 'Done',
          items: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TKanbanBoard<String>(
                columns: columns,
                onCardMoved: (item, fromCol, toCol, index) {
                  movedItem = item;
                  sourceCol = fromCol;
                  targetCol = toCol;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find draggable card and drag it to the second column
      final cardFinder = find.text('Move Me');
      expect(cardFinder, findsOneWidget);

      final firstLocation = tester.getCenter(cardFinder);
      final gesture = await tester.startGesture(firstLocation);
      await tester.pump(const Duration(milliseconds: 100));

      // Drag right by 300px into the 'Done' column
      await gesture.moveBy(const Offset(300, 0));
      await tester.pumpAndSettle();

      await gesture.up();
      await tester.pumpAndSettle();

      expect(movedItem?.id, equals('card_move'));
      expect(sourceCol, equals('col_todo'));
      expect(targetCol, equals('col_done'));
    });
  });

  group('TSparkline & TTrendIndicator Tests', () {
    testWidgets('renders sparklines for all three types', (tester) async {
      final sampleData = [10.0, 15.0, 12.0, 24.0, 18.0, 32.0];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TSparkline(data: sampleData, type: TSparklineType.line),
                TSparkline(data: sampleData, type: TSparklineType.area),
                TSparkline(data: sampleData, type: TSparklineType.bar),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders TTrendIndicator delta formatting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TTrendIndicator(delta: 14.5, comparisonLabel: 'vs last month'),
                TTrendIndicator(delta: -3.2),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+14.5% ↑'), findsOneWidget);
      expect(find.text('vs last month'), findsOneWidget);
      expect(find.text('-3.2% ↓'), findsOneWidget);
    });

    testWidgets('TTrendIndicator gracefully handles constrained width and unbounded width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                // Narrow constrained width that would overflow without Flexible
                const SizedBox(
                  width: 120,
                  child: TTrendIndicator(delta: 24.8, comparisonLabel: 'vs last month'),
                ),
                // Unbounded width inside Wrap
                Wrap(
                  children: const [
                    TTrendIndicator(delta: 12.0, comparisonLabel: 'growth'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('+24.8% ↑'), findsOneWidget);
    });
  });

  group('TSpeedDial Tests', () {
    testWidgets('expands and triggers child action', (tester) async {
      bool exportTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                TSpeedDial(
                  children: [
                    TSpeedDialChild(
                      icon: Icons.file_download,
                      label: 'Export CSV',
                      onTap: () => exportTapped = true,
                    ),
                    TSpeedDialChild(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find toggle button by add icon
      final fabFinder = find.byIcon(Icons.add);
      expect(fabFinder, findsOneWidget);

      // Tap main FAB to expand
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Child actions should now be visible
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Tap Export CSV
      await tester.tap(find.text('Export CSV'));
      await tester.pumpAndSettle();

      expect(exportTapped, isTrue);
    });
  });
}
