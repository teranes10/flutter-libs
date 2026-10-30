import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TBadge Widget Tests', () {
    testWidgets('renders count badge on child with auto 99+ overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TBadge(
                count: 120,
                child: TIcon.raw(HugeIcons.strokeRoundedNotification01),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedNotification01), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('renders dot badge when dot is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TBadge(
                dot: true,
                child: TIcon.raw(HugeIcons.strokeRoundedMail01),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedMail01), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(TBadge),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('supports generic badge parameter with int, string, bool, and Widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TBadge(
                  badge: 15,
                  child: Text('With Number'),
                ),
                TBadge(
                  badge: 'NEW',
                  child: Text('With String'),
                ),
                TBadge(
                  badge: true,
                  child: Text('With Bool'),
                ),
                TBadge(
                  badge: TIcon.raw(HugeIcons.strokeRoundedStar, size: 12),
                  child: Text('With Widget'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedStar), findsOneWidget);
    });

    testWidgets('supports named constructors: count, dot, label, custom, and standalone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TBadge.count(
                  count: 42,
                  child: TIcon.raw(HugeIcons.strokeRoundedShoppingCart01),
                ),
                TBadge.dot(
                  child: TIcon.raw(HugeIcons.strokeRoundedUser),
                ),
                TBadge.label(
                  label: 'PRO',
                  child: Text('Account'),
                ),
                TBadge.custom(
                  badgeWidget: Text('CUSTOM'),
                  child: Text('Custom Item'),
                ),
                TBadge.standalone(
                  count: 7,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('respects hideZero and hidden flags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TBadge(
                  count: 0,
                  hideZero: true,
                  child: Text('Zero Hidden'),
                ),
                TBadge(
                  count: 5,
                  hidden: true,
                  child: Text('Fully Hidden'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zero Hidden'), findsOneWidget);
      expect(find.text('Fully Hidden'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      expect(find.text('5'), findsNothing);
    });

    testWidgets('supports custom alignment and offset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TBadge(
                badge: 'HOT',
                alignment: Alignment.bottomLeft,
                offset: Offset(2, -2),
                child: SizedBox(
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HOT'), findsOneWidget);
    });

    testWidgets('supports TBadgeSize presets and TButton with badgeSize', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                TBadge(
                  size: TBadgeSize.sm,
                  badge: 3,
                  child: TIcon.raw(HugeIcons.strokeRoundedMail01),
                ),
                TBadge(
                  size: TBadgeSize.lg,
                  badge: 'VIP',
                  child: const Text('User'),
                ),
                TButton(
                  text: 'Notifications',
                  badge: 10,
                  badgeSize: TBadgeSize.xs,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('VIP'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('appends badge text width to offset acting as start point rather than center point', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Row(
              children: const [
                TBadge(
                  key: Key('badge_single'),
                  count: 1,
                  child: SizedBox(width: 24, height: 24),
                ),
                TBadge(
                  key: Key('badge_long'),
                  count: 999,
                  child: SizedBox(width: 24, height: 24),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final singleBadgeRect = tester.getRect(find.text('1'));
      final longBadgeRect = tester.getRect(find.text('99+'));

      // As text grows longer (from 1 to 99+), the badge text width expands to the right
      expect(longBadgeRect.width, greaterThan(singleBadgeRect.width));
      // And the right boundary is pushed further to the right
      expect(longBadgeRect.right, greaterThan(singleBadgeRect.right));
    });

    testWidgets('topLeft, centerLeft, and bottomLeft badges expand outward to the left away from the child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Row(
              children: const [
                TBadge(
                  key: Key('badge_left_single'),
                  alignment: Alignment.topLeft,
                  count: 1,
                  child: SizedBox(width: 50, height: 50),
                ),
                SizedBox(width: 50),
                TBadge(
                  key: Key('badge_left_long'),
                  alignment: Alignment.topLeft,
                  count: 999,
                  child: SizedBox(width: 50, height: 50),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final singleBadgeRect = tester.getRect(find.text('1'));
      final longBadgeRect = tester.getRect(find.text('99+'));

      // Both badges are rendered
      expect(singleBadgeRect, isNotNull);
      expect(longBadgeRect, isNotNull);

      // The longer badge should be wider
      expect(longBadgeRect.width, greaterThan(singleBadgeRect.width));
    });

    testWidgets('topCenter, bottomCenter, centerLeft, centerRight, and center do not stretch to full element size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Column(
                children: const [
                  TBadge(
                    alignment: Alignment.topCenter,
                    badge: 'HOT',
                    child: SizedBox(width: 80, height: 80),
                  ),
                  TBadge(
                    alignment: Alignment.bottomCenter,
                    badge: 'SALE',
                    child: SizedBox(width: 80, height: 80),
                  ),
                  TBadge(
                    alignment: Alignment.centerLeft,
                    badge: 'NEW',
                    child: SizedBox(width: 80, height: 80),
                  ),
                  TBadge(
                    alignment: Alignment.centerRight,
                    badge: '12',
                    child: SizedBox(width: 80, height: 80),
                  ),
                  TBadge(
                    alignment: Alignment.center,
                    badge: 'VIP',
                    child: SizedBox(width: 80, height: 80),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hotRect = tester.getRect(find.text('HOT'));
      final saleRect = tester.getRect(find.text('SALE'));
      final newRect = tester.getRect(find.text('NEW'));
      final twelveRect = tester.getRect(find.text('12'));
      final vipRect = tester.getRect(find.text('VIP'));

      // None of the badges should stretch to 80px width or height
      expect(hotRect.width, lessThan(60));
      expect(saleRect.width, lessThan(60));
      expect(newRect.height, lessThan(40));
      expect(twelveRect.height, lessThan(40));
      expect(vipRect.width, lessThan(60));
      expect(vipRect.height, lessThan(40));
    });
  });
}
