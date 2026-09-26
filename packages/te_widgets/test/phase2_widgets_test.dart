import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  group('TPopover Tests', () {
    testWidgets('renders trigger and shows popover content on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPopover(
                title: 'User Profile',
                showCloseButton: true,
                content: const Text('Popover Content Body'),
                child: const Text('Open Popover'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Open Popover'), findsOneWidget);
      expect(find.text('Popover Content Body'), findsNothing);

      // Tap trigger to open
      await tester.tap(find.text('Open Popover'));
      await tester.pumpAndSettle();

      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Popover Content Body'), findsOneWidget);

      // Tap close button to dismiss
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Popover Content Body'), findsNothing);
    });

    testWidgets('programmatically controls popover via TPopoverController', (tester) async {
      final controller = TPopoverController();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPopover(
                controller: controller,
                content: const Text('Programmatic Content'),
                child: const Text('Trigger Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Programmatic Content'), findsNothing);

      // Show via controller
      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Programmatic Content'), findsOneWidget);
      expect(controller.isShowing, isTrue);

      // Hide via controller
      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('Programmatic Content'), findsNothing);
      expect(controller.isShowing, isFalse);

      controller.dispose();
    });
  });

  group('TPopconfirm Tests', () {
    testWidgets('renders popconfirm and confirms action', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPopconfirm.danger(
                title: 'Delete Customer?',
                description: 'This operation is permanent.',
                confirmText: 'Delete Now',
                onConfirm: () {
                  confirmed = true;
                },
                child: const Text('Delete Action'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delete Action'), findsOneWidget);
      expect(find.text('Delete Customer?'), findsNothing);

      // Tap action to open popconfirm
      await tester.tap(find.text('Delete Action'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Customer?'), findsOneWidget);
      expect(find.text('This operation is permanent.'), findsOneWidget);
      expect(find.text('Delete Now'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Delete Now'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text('Delete Customer?'), findsNothing);
    });

    testWidgets('cancels action without confirming', (tester) async {
      bool confirmed = false;
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TPopconfirm(
                title: 'Apply changes?',
                onConfirm: () => confirmed = true,
                onCancel: () => cancelled = true,
                child: const Text('Save Action'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save Action'));
      await tester.pumpAndSettle();

      expect(find.text('Apply changes?'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(cancelled, isTrue);
      expect(find.text('Apply changes?'), findsNothing);
    });
  });

  group('TCommandPalette Tests', () {
    test('TCommandItem matches search queries and keywords', () {
      final item = TCommandItem(
        id: 'settings',
        title: 'User Settings',
        subtitle: 'Manage profile and security',
        keywords: ['password', 'account'],
        onSelect: () {},
      );

      expect(item.matches(''), isTrue);
      expect(item.matches('user'), isTrue);
      expect(item.matches('profile'), isTrue);
      expect(item.matches('pass'), isTrue);
      expect(item.matches('nonexistent'), isFalse);
    });

    testWidgets('opens TCommandPalette dialog, searches, and selects an item', (tester) async {
      bool itemSelected = false;

      final groups = [
        TCommandGroup(
          heading: 'General',
          items: [
            TCommandItem(
              id: 'dashboard',
              title: 'Go to Dashboard',
              subtitle: 'System metrics and KPIs',
              shortcut: '⌘D',
              onSelect: () => itemSelected = true,
            ),
            TCommandItem(
              id: 'billing',
              title: 'Billing & Invoices',
              subtitle: 'View payments',
              onSelect: () {},
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      TCommandPalette.show(context, groups: groups);
                    },
                    child: const Text('Open Palette'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open palette
      await tester.tap(find.text('Open Palette'));
      await tester.pumpAndSettle();

      expect(find.text('Go to Dashboard'), findsOneWidget);
      expect(find.text('Billing & Invoices'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);

      // Filter via search
      await tester.enterText(find.byType(TextField), 'dash');
      await tester.pumpAndSettle();

      expect(find.text('Go to Dashboard'), findsOneWidget);
      expect(find.text('Billing & Invoices'), findsNothing);

      // Select matching command
      await tester.tap(find.text('Go to Dashboard'));
      await tester.pumpAndSettle();

      expect(itemSelected, isTrue);
      expect(find.text('Go to Dashboard'), findsNothing); // Dialog closed
    });

    testWidgets('TCommandPaletteTrigger renders and opens on click', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TCommandPaletteTrigger(
                placeholder: 'Quick Search...',
                shortcut: '⌘K',
                groups: [
                  TCommandGroup(
                    heading: 'Actions',
                    items: [
                      TCommandItem(id: '1', title: 'Action 1', onSelect: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Quick Search...'), findsOneWidget);
      expect(find.text('⌘K'), findsOneWidget);

      await tester.tap(find.byType(TCommandPaletteTrigger));
      await tester.pumpAndSettle();

      expect(find.text('Action 1'), findsOneWidget);
    });
  });

  group('TContextMenu Tests', () {
    testWidgets('renders context menu on secondary click and triggers item', (tester) async {
      bool editTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: TContextMenu(
                items: [
                  TContextMenuItem(
                    text: 'Edit Record',
                    icon: Icons.edit,
                    onTap: () => editTapped = true,
                  ),
                  const TContextMenuDivider(),
                  TContextMenuItem(
                    text: 'Delete Permanently',
                    icon: Icons.delete_outline,
                    isDestructive: true,
                    onTap: () => deleteTapped = true,
                  ),
                ],
                child: Container(
                  width: 150,
                  height: 100,
                  color: Colors.blueGrey,
                  child: const Center(child: Text('Right Click Me')),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Right Click Me'), findsOneWidget);
      expect(find.text('Edit Record'), findsNothing);

      // Secondary click (right click)
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Right Click Me')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Edit Record'), findsOneWidget);
      expect(find.text('Delete Permanently'), findsOneWidget);

      // Tap Edit Record
      await tester.tap(find.text('Edit Record'));
      await tester.pumpAndSettle();

      expect(editTapped, isTrue);
      expect(deleteTapped, isFalse);
      expect(find.text('Edit Record'), findsNothing); // Menu closed
    });

    testWidgets('positions menu at the exact tap coordinates when inside an offset container', (tester) async {
      const clickTarget = Offset(320, 240);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(left: 200, top: 100),
              child: TContextMenu(
                items: [
                  TContextMenuItem(text: 'Item 1', onTap: () {}),
                ],
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey,
                  child: const Text('Target Area'),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        clickTarget,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      final itemTopLeft = tester.getTopLeft(find.text('Item 1'));
      // The menu must be located directly at clickTarget, not doubly shifted!
      expect((itemTopLeft.dx - clickTarget.dx).abs(), lessThan(30));
      expect((itemTopLeft.dy - clickTarget.dy).abs(), lessThan(30));
    });
  });
}
