import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TButton with TIcon', () {
    testWidgets('renders IconData using TIcon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: HugeIcons.strokeRoundedAdd01,
              text: 'Add Item',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedAdd01), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('renders custom Widget icon using TIcon', (tester) async {
      const customKey = Key('custom-icon-widget');
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: const SizedBox(key: customKey, width: 16, height: 16),
              text: 'Custom Icon',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byKey(customKey), findsOneWidget);
      expect(find.text('Custom Icon'), findsOneWidget);
    });

    testWidgets('renders HugeIcons list using TIcon', (tester) async {
      final hugeIcon = HugeIcons.strokeRoundedPlay;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: hugeIcon,
              text: 'Play',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byType(HugeIcon), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('swaps icon with activeIcon when toggled active', (tester) async {
      bool active = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: theme,
              home: Scaffold(
                body: TButton(
                  icon: HugeIcons.strokeRoundedFavouriteCircle,
                  activeIcon: HugeIcons.strokeRoundedFavourite,
                  active: active,
                  onChanged: (val) {
                    setState(() => active = val);
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedFavouriteCircle), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedFavourite), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedFavourite), findsOneWidget);
    });

    testWidgets('supports rotation turns when toggled active', (tester) async {
      bool active = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: theme,
              home: Scaffold(
                body: TButton(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  turns: (0.0, 0.5),
                  active: active,
                  onChanged: (val) {
                    setState(() => active = val);
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byType(AnimatedRotation), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedRotation), findsOneWidget);
    });

    testWidgets('TButtonGroup passes dynamic icon, activeIcon, and turns to TButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButtonGroup(
              cycle: true,
              items: [
                TButtonGroupItem(
                  icon: HugeIcons.strokeRoundedPlay,
                  text: 'Play',
                ),
                TButtonGroupItem(
                  icon: HugeIcons.strokeRoundedPause,
                  text: 'Pause',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedPlay), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedPause), findsOneWidget);
    });

    testWidgets('TPagination renders HugeIcons via TIcon for navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TPagination(
              currentPage: 2,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(TPagination), findsOneWidget);
      expect(find.byType(TIcon), findsNWidgets(4));
      expect(find.byType(HugeIcon), findsNWidgets(4));
    });

    testWidgets('TIcon.raw renders directly without InkWell/Container when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TIcon.raw(HugeIcons.strokeRoundedStar, size: 24, color: Colors.amber),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedStar), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('TIcon.raw renders HugeIcons directly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TIcon.raw(HugeIcons.strokeRoundedPlay, size: 22),
          ),
        ),
      );

      expect(find.byType(TIcon), findsOneWidget);
      expect(find.byType(HugeIcon), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('TButton renders count badge with default top-right alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: HugeIcons.strokeRoundedNotification01,
              text: 'Alerts',
              badge: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      final positioned = tester.widget<Positioned>(
        find.descendant(of: find.byType(TButton), matching: find.byType(Positioned)),
      );
      expect(positioned.top, -4.0);
      expect(positioned.right, -4.0);
      expect(positioned.left, isNull);
      expect(positioned.bottom, isNull);
    });

    testWidgets('TButton renders dot badge when badge is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: HugeIcons.strokeRoundedMail01,
              badge: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(of: find.byType(TButton), matching: find.byType(Positioned)),
        findsOneWidget,
      );
    });

    testWidgets('TButton renders string badge with custom alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: HugeIcons.strokeRoundedStar,
              text: 'Featured',
              badge: 'NEW',
              badgeAlignment: Alignment.topLeft,
              badgeColor: Colors.blue,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);

      final positioned = tester.widget<Positioned>(
        find.descendant(of: find.byType(TButton), matching: find.byType(Positioned)),
      );
      expect(positioned.top, -4.0);
      expect(positioned.left, -4.0);
      expect(positioned.right, isNull);
      expect(positioned.bottom, isNull);
    });

    testWidgets('TButton renders custom Widget badge', (tester) async {
      const customKey = Key('custom-badge');
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TButton(
              icon: HugeIcons.strokeRoundedBubbleChat,
              badge: const SizedBox(key: customKey, width: 10, height: 10),
              badgeAlignment: Alignment.bottomRight,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(customKey), findsOneWidget);

      final positioned = tester.widget<Positioned>(
        find.descendant(of: find.byType(TButton), matching: find.byType(Positioned)),
      );
      expect(positioned.bottom, -4.0);
      expect(positioned.right, -4.0);
      expect(positioned.top, isNull);
      expect(positioned.left, isNull);
    });

    testWidgets('TButton does not render badge when badge is 0, false, empty, or null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TButton(text: 'Zero', badge: 0, onTap: () {}),
                TButton(text: 'False', badge: false, onTap: () {}),
                TButton(text: 'Empty', badge: '', onTap: () {}),
                TButton(text: 'Null', badge: null, onTap: () {}),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(of: find.byType(TButton), matching: find.byType(Positioned)),
        findsNothing,
      );
    });
  });
}
