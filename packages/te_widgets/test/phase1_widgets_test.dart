import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TSkeleton Tests', () {
    testWidgets('renders TSkeleton primitives (text, circle, rect)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TSkeleton.text(width: 120, height: 14),
                TSkeleton.circle(size: 40),
                TSkeleton.rect(width: 80, height: 40),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TSkeleton), findsNWidgets(3));
    });

    testWidgets('renders composite skeletons (lines, card, tile, table)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TSkeleton.lines(count: 3),
                  TSkeleton.card(lines: 2),
                  TSkeleton.tile(size: TTileSize.h4),
                  TSkeleton.table(rows: 3, columns: 3),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TSkeleton), findsWidgets);
    });

    testWidgets('renders child widget directly when loading is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TSkeleton(
              loading: false,
              child: Text('Loaded Real Content'),
            ),
          ),
        ),
      );

      expect(find.text('Loaded Real Content'), findsOneWidget);
    });
  });

  group('TEmptyState Tests', () {
    testWidgets('renders standard empty state with title, description, and action', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No Items',
              description: 'Please add items to your cart.',
              action: TButton(
                text: 'Add Item',
                onTap: () => actionTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Please add items to your cart.'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      expect(actionTapped, isTrue);
    });

    testWidgets('renders search empty state with clear action', (tester) async {
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TEmptyState.search(
              query: 'Flutter',
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.text('No results for "Flutter"'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      await tester.tap(find.text('Clear Search'));
      expect(cleared, isTrue);
    });

    testWidgets('renders compact empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TEmptyState.compact(
              message: 'No active filters',
            ),
          ),
        ),
      );

      expect(find.text('No active filters'), findsOneWidget);
    });
  });

  group('TBanner Tests', () {
    testWidgets('renders semantic banners (info, warning, error, success)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TBanner.info(title: 'Notice', message: 'Info message'),
                TBanner.warning(title: 'Alert', message: 'Warning message'),
                TBanner.error(title: 'Danger', message: 'Error message'),
                TBanner.success(title: 'Done', message: 'Success message'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('Info message'), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
      expect(find.text('Error message'), findsOneWidget);
      expect(find.text('Success message'), findsOneWidget);
    });

    testWidgets('message starts straight below title when single line, and below icon when multiple lines', (tester) async {
      // 1. Single-line message: starts straight below title
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TBanner.info(
              title: 'Heading',
              message: 'Short message',
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.info_outline_rounded);
      final titleFinder = find.text('Heading');
      final singleMessageFinder = find.text('Short message');

      final iconTopLeft = tester.getTopLeft(iconFinder);
      final titleTopLeft = tester.getTopLeft(titleFinder);
      final singleMessageTopLeft = tester.getTopLeft(singleMessageFinder);

      // Icon and title are horizontally aligned
      expect(titleTopLeft.dx, greaterThan(iconTopLeft.dx));
      expect((titleTopLeft.dy - iconTopLeft.dy).abs(), lessThanOrEqualTo(4.0));

      // Single line message starts straight below title
      expect(singleMessageTopLeft.dy, greaterThan(titleTopLeft.dy));
      expect(singleMessageTopLeft.dx, titleTopLeft.dx);

      // 2. Multi-line message: starts below icon from the start
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: TBanner.info(
              title: 'Heading',
              message: 'First line of message\nSecond line of message',
            ),
          ),
        ),
      );

      final multiIconFinder = find.byIcon(Icons.info_outline_rounded);
      final multiTitleFinder = find.text('Heading');
      final multiMessageFinder = find.text('First line of message\nSecond line of message');

      final multiIconTopLeft = tester.getTopLeft(multiIconFinder);
      final multiTitleTopLeft = tester.getTopLeft(multiTitleFinder);
      final multiMessageTopLeft = tester.getTopLeft(multiMessageFinder);

      expect(multiTitleTopLeft.dx, greaterThan(multiIconTopLeft.dx));
      expect(multiMessageTopLeft.dy, greaterThan(multiTitleTopLeft.dy));
      // Multi-line message starts below icon (aligned with icon X)
      expect(multiMessageTopLeft.dx, multiIconTopLeft.dx);

      // 3. Long message wrapping onto multiple lines due to width: starts below icon
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SizedBox(
              width: 250,
              child: TBanner.info(
                title: 'Heading',
                message: 'This is a very long message that definitely exceeds two hundred and fifty pixels width and wraps onto multiple lines.',
              ),
            ),
          ),
        ),
      );

      final wrapIconFinder = find.byIcon(Icons.info_outline_rounded);
      final wrapTitleFinder = find.text('Heading');
      final wrapMessageFinder = find.text('This is a very long message that definitely exceeds two hundred and fifty pixels width and wraps onto multiple lines.');

      final wrapIconTopLeft = tester.getTopLeft(wrapIconFinder);
      final wrapTitleTopLeft = tester.getTopLeft(wrapTitleFinder);
      final wrapMessageTopLeft = tester.getTopLeft(wrapMessageFinder);

      expect(wrapTitleTopLeft.dx, greaterThan(wrapIconTopLeft.dx));
      expect(wrapMessageTopLeft.dy, greaterThan(wrapTitleTopLeft.dy));
      expect(wrapMessageTopLeft.dx, wrapIconTopLeft.dx);
    });

    testWidgets('renders banner with action button and dismiss callback', (tester) async {
      bool actionTapped = false;
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TBanner.warning(
              title: 'Storage Full',
              message: 'Upgrade your quota.',
              action: TButton(
                text: 'Upgrade',
                onTap: () => actionTapped = true,
              ),
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Upgrade'), findsOneWidget);
      await tester.tap(find.text('Upgrade'));
      expect(actionTapped, isTrue);

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });
  });

  group('TCopyButton & TCopyable Tests', () {
    testWidgets('TCopyButton copies text and switches to checkmark state', (tester) async {
      String? copiedData;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            final args = methodCall.arguments as Map;
            copiedData = args['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TCopyButton(
                text: 'copy_test_123',
                label: 'Copy Key',
                copiedLabel: 'Copied Key',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Copy Key'), findsOneWidget);

      await tester.tap(find.byType(TCopyButton));
      await tester.pump();

      expect(copiedData, 'copy_test_123');
      expect(find.text('Copied Key'), findsOneWidget);
    });

    testWidgets('TCopyable.text renders text with copy button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TCopyable.text(
                'api_token_xyz',
                monospace: true,
                showButtonAlways: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('api_token_xyz'), findsOneWidget);
      expect(find.byType(TCopyButton), findsOneWidget);
    });
  });
}
