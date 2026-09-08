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
          home: const Scaffold(
            body: Center(
              child: TBadge(
                count: 120,
                child: Icon(Icons.notifications),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('renders dot badge when dot is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: TBadge(
                dot: true,
                child: Icon(Icons.mail),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mail), findsOneWidget);
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
          home: const Scaffold(
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
                  badge: Icon(Icons.star, size: 12),
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
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('supports named constructors: count, dot, label, custom, and standalone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                TBadge.count(
                  count: 42,
                  child: Icon(Icons.shopping_cart),
                ),
                TBadge.dot(
                  child: Icon(Icons.person),
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
          home: const Scaffold(
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
          home: const Scaffold(
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
                  child: const Icon(Icons.mail),
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
  });
}
