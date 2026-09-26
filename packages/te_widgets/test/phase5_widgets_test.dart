import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TJsonViewer Tests', () {
    testWidgets('renders map keys, values, and toggles collapse', (tester) async {
      final sampleJson = {
        'service': 'auth-api',
        'port': 8080,
        'enabled': true,
        'endpoints': ['/login', '/logout'],
      };

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TJsonViewer(
                data: sampleJson,
                initialDepth: 2,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('"service"'), findsOneWidget);
      expect(find.text('"auth-api"'), findsOneWidget);
      expect(find.text('8080'), findsOneWidget);
      expect(find.text('true'), findsOneWidget);

      // Find expand/collapse arrow and tap it
      final arrowFinder = find.byIcon(Icons.keyboard_arrow_down);
      expect(arrowFinder, findsWidgets);

      // Tap collapse
      await tester.tap(arrowFinder.first);
      await tester.pumpAndSettle();
    });

    testWidgets('handles raw JSON string input', (tester) async {
      const rawString = '{"cluster": "us-east-1", "activeNodes": 12}';

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TJsonViewer(data: rawString),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('"cluster"'), findsOneWidget);
      expect(find.text('"us-east-1"'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });

  group('TDiffViewer Tests', () {
    testWidgets('computes line diffs and renders additions/deletions', (tester) async {
      const oldText = 'line 1\nline 2 (old)\nline 3';
      const newText = 'line 1\nline 2 (new)\nline 3\nline 4';

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SizedBox(
              width: 800,
              height: 500,
              child: TDiffViewer(
                oldText: oldText,
                newText: newText,
                oldTitle: 'v1',
                newTitle: 'v2',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('v1 ⟷ v2'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget); // 2 additions: line 2 (new), line 4
      expect(find.text('-1'), findsOneWidget); // 1 deletion: line 2 (old)

      // Switch to unified inline mode
      await tester.tap(find.text('Unified'));
      await tester.pumpAndSettle();

      expect(find.text('Unified Diff (v1 → v2)'), findsOneWidget);
    });
  });

  group('TTour Tests', () {
    testWidgets('walks through steps with TTourController', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      final controller = TTourController();

      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: TTour(
                controller: controller,
                onFinish: () => finished = true,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(key: key1, onPressed: () {}, child: const Text('Button 1')),
                      ElevatedButton(key: key2, onPressed: () {}, child: const Text('Button 2')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Start the tour
      controller.start([
        TTourStep(
          targetKey: key1,
          title: 'First Target',
          description: 'This is the first button to click.',
        ),
        TTourStep(
          targetKey: key2,
          title: 'Second Target',
          description: 'This is the second feature button.',
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('First Target'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Second Target'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);

      // Tap Finish (Got It)
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(controller.isActive, isFalse);
    });
  });
}
