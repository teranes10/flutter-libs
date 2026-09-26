import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TTreeView Tests', () {
    testWidgets('renders tree nodes and expands/collapses branches', (tester) async {
      final tree = [
        const TTreeNode(
          key: 'src',
          label: 'src',
          children: [
            TTreeNode(key: 'index.ts', label: 'index.ts'),
            TTreeNode(key: 'app.ts', label: 'app.ts'),
          ],
        ),
        const TTreeNode(key: 'package.json', label: 'package.json'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TTreeView(nodes: tree),
            ),
          ),
        ),
      );

      expect(find.text('src'), findsOneWidget);
      expect(find.text('package.json'), findsOneWidget);
      expect(find.text('index.ts'), findsNothing); // Collapsed by default

      // Expand 'src'
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('index.ts'), findsOneWidget);
      expect(find.text('app.ts'), findsOneWidget);

      // Collapse 'src'
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('index.ts'), findsNothing);
    });

    testWidgets('multi-select checks parent and all descendants', (tester) async {
      Set<String> selected = {};

      final tree = [
        const TTreeNode(
          key: 'documents',
          label: 'Documents',
          children: [
            TTreeNode(key: 'doc1', label: 'Resume.pdf'),
            TTreeNode(key: 'doc2', label: 'CoverLetter.pdf'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TTreeView(
                nodes: tree,
                selectionMode: TTreeSelectionMode.multi,
                expandedKeys: const {'documents'},
                onSelectionChanged: (keys) => selected = keys,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Resume.pdf'), findsOneWidget);

      // Tap 'Documents' checkbox (selects parent and all children)
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(selected.contains('documents'), isTrue);
      expect(selected.contains('doc1'), isTrue);
      expect(selected.contains('doc2'), isTrue);
    });

    testWidgets('search query filters tree nodes and auto-expands path', (tester) async {
      final tree = [
        const TTreeNode(
          key: 'folder_a',
          label: 'Folder A',
          children: [
            TTreeNode(key: 'file_target', label: 'SecretTarget.pdf'),
          ],
        ),
        const TTreeNode(
          key: 'folder_b',
          label: 'Folder B',
          children: [
            TTreeNode(key: 'file_other', label: 'Other.txt'),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TTreeView(
                nodes: tree,
                searchQuery: 'SecretTarget',
              ),
            ),
          ),
        ),
      );

      // Folder A should be auto-expanded because child matches
      expect(find.text('Folder A'), findsOneWidget);
      expect(find.text('SecretTarget.pdf'), findsOneWidget);
      // Folder B does not match so it should be omitted
      expect(find.text('Folder B'), findsNothing);
    });
  });

  group('TResult Tests', () {
    testWidgets('renders success result with actions and extra card', (tester) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TResult.success(
              title: 'Order Completed',
              subtitle: 'Order #9821 has been placed successfully.',
              extra: const Text('Receipt Details #9821'),
              primaryAction: TButton(
                text: 'View Order',
                onTap: () => primaryTapped = true,
              ),
              secondaryAction: TButton(
                text: 'Continue Shopping',
                onTap: () => secondaryTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Order Completed'), findsOneWidget);
      expect(find.text('Order #9821 has been placed successfully.'), findsOneWidget);
      expect(find.text('Receipt Details #9821'), findsOneWidget);

      await tester.tap(find.text('View Order'));
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('Continue Shopping'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('renders 403 forbidden and 500 server error presets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TResult.forbidden(),
                TResult.serverError(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('403 Forbidden'), findsOneWidget);
      expect(find.text('500 Server Error'), findsOneWidget);
    });
  });

  group('TPinField Tests', () {
    testWidgets('enters digits and triggers onCompleted callback', (tester) async {
      String currentVal = '';
      String completedVal = '';

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPinField(
                length: 4,
                onChanged: (val) => currentVal = val,
                onCompleted: (val) => completedVal = val,
              ),
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      // Enter 1 in first box
      await tester.enterText(textFields.at(0), '1');
      await tester.pumpAndSettle();
      expect(currentVal, '1');

      // Enter 2 in second box
      await tester.enterText(textFields.at(1), '2');
      await tester.pumpAndSettle();
      expect(currentVal, '12');

      // Enter 3 in third box
      await tester.enterText(textFields.at(2), '3');
      await tester.pumpAndSettle();
      expect(currentVal, '123');

      // Enter 4 in fourth box
      await tester.enterText(textFields.at(3), '4');
      await tester.pumpAndSettle();
      expect(currentVal, '1234');
      expect(completedVal, '1234');
    });

    testWidgets('pasting full code populates all segments', (tester) async {
      String completedPin = '';

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPinField(
                length: 4,
                onCompleted: (val) => completedPin = val,
              ),
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '9876');
      await tester.pumpAndSettle();

      expect(completedPin, '9876');
    });
  });
}
