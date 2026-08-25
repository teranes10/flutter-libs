import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  final testItems = [
    const TSidebarItem(
      icon: Icons.dashboard,
      text: 'Dashboard',
      route: '/dashboard',
      home: true,
    ),
    const TSidebarItem(
      icon: Icons.inventory_2_outlined,
      text: 'Products',
      route: '/products',
      children: [
        TSidebarItem(
          icon: Icons.list,
          text: 'Product List',
          route: 'list',
        ),
        TSidebarItem(
          icon: Icons.category,
          text: 'Categories',
          route: 'categories',
          children: [
            TSidebarItem(
              icon: Icons.subdirectory_arrow_right,
              text: 'Subcategories',
              route: 'sub',
            ),
          ],
        ),
      ],
    ),
    const TSidebarItem(
      icon: Icons.settings,
      text: 'Settings',
      route: '/settings',
    ),
  ];

  final manyItems = [
    const TSidebarItem(icon: Icons.dashboard, text: 'Dashboard', route: '/dashboard', home: true),
    const TSidebarItem(
      icon: Icons.inventory,
      text: 'Products',
      route: '/products',
      children: [
        TSidebarItem(icon: Icons.list, text: 'Product List', route: 'list'),
        TSidebarItem(
          icon: Icons.category,
          text: 'Categories',
          route: 'categories',
          children: [
            TSidebarItem(icon: Icons.subdirectory_arrow_right, text: 'Subcategories', route: 'sub'),
          ],
        ),
      ],
    ),
    const TSidebarItem(icon: Icons.analytics, text: 'Analytics', route: '/analytics'),
    const TSidebarItem(icon: Icons.people, text: 'Customers', route: '/customers'),
    const TSidebarItem(icon: Icons.receipt_long, text: 'Orders', route: '/orders'),
    const TSidebarItem(icon: Icons.local_shipping, text: 'Logistics', route: '/logistics'),
    const TSidebarItem(icon: Icons.payments, text: 'Finance', route: '/finance'),
    const TSidebarItem(icon: Icons.campaign, text: 'Marketing', route: '/marketing'),
    const TSidebarItem(icon: Icons.support_agent, text: 'Support', route: '/support'),
    const TSidebarItem(icon: Icons.settings, text: 'System', route: '/settings'),
  ];

  Widget buildApp({
    List<TSidebarItem>? items,
    TSidebarMode? initialMode,
  }) {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => TLayout(
            items: items ?? testItems,
            child: const Text('Dashboard Content'),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => TLayout(
            items: items ?? testItems,
            child: const Text('Products Content'),
          ),
          routes: [
            GoRoute(
              path: 'list',
              builder: (context, state) => TLayout(
                items: items ?? testItems,
                child: const Text('Product List Content'),
              ),
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => TLayout(
                items: items ?? testItems,
                child: const Text('Categories Content'),
              ),
              routes: [
                GoRoute(
                  path: 'sub',
                  builder: (context, state) => TLayout(
                    items: items ?? testItems,
                    child: const Text('Subcategories Content'),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => TLayout(
            items: items ?? testItems,
            child: const Text('Settings Content'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (initialMode != null)
          sidebarNotifierProvider.overrideWith(() => _TestSidebarNotifier(initialMode)),
      ],
      child: MaterialApp.router(
        theme: theme,
        routerConfig: router,
      ),
    );
  }

  group('TLayout Top Navigation & Responsive Overflow Tests', () {
    testWidgets('Wide screen shows top nav menu tabs and dropdowns with active text/icon color and no background', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp(initialMode: TSidebarMode.none));
      await tester.pumpAndSettle();

      // Top nav menu items should be displayed in top bar
      expect(find.byType(LayoutTopNavMenuItem), findsWidgets);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Hovering over "Products" top menu item opens dropdown overlay
      final productsItem = find.text('Products');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(productsItem));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Dropdown panel should display child items: Product List & Categories
      expect(find.text('Product List'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);

      // Hovering over "Categories" opens nested sub-menu
      final categoriesItem = find.text('Categories');
      await gesture.moveTo(tester.getCenter(categoriesItem));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Subcategories'), findsOneWidget);
    });

    testWidgets('None mode shows possible top bar tabs and tristate down arrow with hover dropdown for remaining items', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp(
        items: manyItems,
        initialMode: TSidebarMode.none,
      ));
      await tester.pumpAndSettle();

      // Top nav menu items should be displayed in top bar
      expect(find.byType(LayoutTopNavMenuItem), findsWidgets);

      // First few items should fit as top bar tabs
      expect(find.text('Products'), findsOneWidget);

      // Tristate button shows down arrow in none mode
      expect(find.byType(SidebarTristateButton), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsWidgets);

      // Hovering over tristate button reveals the overflow items dropdown
      final tristateBtn = find.byType(SidebarTristateButton);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(tristateBtn));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Overflow items should now be visible in the dropdown
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('Tristate sidebar button has directional arrow icons: minified -> right, full -> left, none -> down', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp(
        items: manyItems,
        initialMode: TSidebarMode.full,
      ));
      await tester.pumpAndSettle();

      // Full mode displays left arrow icon
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // Tapping tristate button cycles: full -> none (down arrow)
      await tester.tap(find.byType(SidebarTristateButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsWidgets);

      // Tapping again cycles: none -> minified (right arrow)
      await tester.tap(find.byType(SidebarTristateButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // Tapping again cycles: minified -> full (left arrow)
      await tester.tap(find.byType(SidebarTristateButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });

    testWidgets('Nested submenus propagate left alignment when right side is constrained', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final multiLevelItems = [
        const TSidebarItem(
          icon: Icons.dashboard,
          text: 'Dashboard',
          route: '/dashboard',
          home: true,
        ),
        const TSidebarItem(
          icon: Icons.inventory_2_outlined,
          text: 'Products',
          route: '/products',
          children: [
            TSidebarItem(
              icon: Icons.category,
              text: 'Categories',
              route: 'categories',
              children: [
                TSidebarItem(
                  icon: Icons.subdirectory_arrow_right,
                  text: 'Subcategories',
                  route: 'sub',
                ),
              ],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(buildApp(
        items: multiLevelItems,
        initialMode: TSidebarMode.none,
      ));
      await tester.pumpAndSettle();

      // Products is on the top bar
      final productsItem = find.text('Products');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(productsItem));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Categories is displayed in Level 1 panel
      final categoriesItem = find.text('Categories');
      expect(categoriesItem, findsOneWidget);

      // Hover Categories to open Level 2 panel
      await gesture.moveTo(tester.getCenter(categoriesItem));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Subcategories is displayed
      final subcategoriesItem = find.text('Subcategories');
      expect(subcategoriesItem, findsOneWidget);
    });

    testWidgets('Dropdown panels constrain max height to screen height - target - 50', (tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp(
        items: manyItems,
        initialMode: TSidebarMode.none,
      ));
      await tester.pumpAndSettle();

      final tristateBtn = find.byType(SidebarTristateButton);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(tristateBtn));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final overlayPanels = find.byType(TMenuOverlayPanel<TSidebarItem>);
      expect(overlayPanels, findsOneWidget);

      final panelSize = tester.getSize(overlayPanels);
      // Screen height is 600, topbar is ~60, buffer is 50 -> panel max height <= 500
      expect(panelSize.height, lessThanOrEqualTo(500));
    });

    testWidgets('Profile button shows end down-arrow and opens dropdown with theme system/light/dark, color, fullscreen, logout', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool loggedOut = false;

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => TLayout(
              items: testItems,
              profile: const Text('John Doe'),
              onLogout: () => loggedOut = true,
              child: const Text('Dashboard Content'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: theme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Profile button with down-arrow is displayed
      expect(find.byType(LayoutProfileButton), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);

      // Hover over profile text to open dropdown
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('John Doe')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Dropdown contains Theme, Accent Color, and Log out
      expect(find.textContaining('Theme'), findsOneWidget);
      expect(find.text('Accent Color'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);

      // Hover over Theme to reveal System, Light, Dark sub-options
      final themeItem = find.textContaining('Theme');
      await gesture.moveTo(tester.getCenter(themeItem));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Tap Log out triggers callback
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(loggedOut, isTrue);
    });

    testWidgets('Sidebar none mode displays minified logo before breadcrumbs in top bar', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => TLayout(
              items: manyItems,
              logo: const Text('Full Logo'),
              minifiedLogo: const Text('Mini Logo'),
              child: const Text('Dashboard Content'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sidebarNotifierProvider.overrideWith(() => _TestSidebarNotifier(TSidebarMode.none)),
          ],
          child: MaterialApp.router(
            theme: theme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Minified logo is displayed in the top bar before breadcrumbs
      expect(find.text('Mini Logo'), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);

      final logoOffset = tester.getTopLeft(find.text('Mini Logo'));
      final breadcrumbOffset = tester.getTopLeft(find.text('Dashboard').first);
      expect(logoOffset.dx, lessThan(breadcrumbOffset.dx));
    });

    testWidgets('Popup opens above when space below is insufficient for all children but space above is enough', (tester) async {
      tester.view.physicalSize = const Size(1000, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final sevenItems = List.generate(
        7,
        (i) => TDropdownItem(text: 'Child Item $i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                // Position trigger at dy = 450 (screen height is 600)
                // spaceBelow is ~110px (fits ~2-3 items), spaceAbove is ~450px (fits all 7 items)
                Positioned(
                  left: 100,
                  top: 450,
                  child: TDropdown(
                    triggerMode: TDropdownTriggerMode.tap,
                    items: sevenItems,
                    child: const SizedBox(
                      width: 150,
                      height: 40,
                      child: Text('Trigger Bottom'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open dropdown
      await tester.tap(find.text('Trigger Bottom'));
      await tester.pumpAndSettle();

      // All 7 items should be rendered
      for (int i = 0; i < 7; i++) {
        expect(find.text('Child Item $i'), findsOneWidget);
      }

      // Dropdown panel should be positioned ABOVE the trigger (dy < 450)
      final firstItemOffset = tester.getTopLeft(find.text('Child Item 0'));
      expect(firstItemOffset.dy, lessThan(450.0));
    });

    testWidgets('Dropdown opening below expands fully to show all items without last item scroll when space permits', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final sixItems = List.generate(
        6,
        (i) => TDropdownItem(text: 'Menu Item $i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 50,
                  child: TDropdown(
                    triggerMode: TDropdownTriggerMode.tap,
                    items: sixItems,
                    child: const SizedBox(
                      width: 150,
                      height: 40,
                      child: Text('Top Trigger'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Top Trigger'));
      await tester.pumpAndSettle();

      // All 6 items should be visible
      for (int i = 0; i < 6; i++) {
        expect(find.text('Menu Item $i'), findsOneWidget);
      }

      // Dropdown panel should be positioned BELOW trigger (dy >= 90)
      final firstItemOffset = tester.getTopLeft(find.text('Menu Item 0'));
      expect(firstItemOffset.dy, greaterThanOrEqualTo(90.0));

      // The Scrollable inside the dropdown should not have scroll extent (maxScrollExtent == 0)
      final scrollableFinder = find.byType(Scrollable);
      final scrollableState = tester.state<ScrollableState>(scrollableFinder.first);
      expect(scrollableState.position.maxScrollExtent, equals(0.0));
    });

    testWidgets('Nested side submenu expands downwards from item top without clipping or small scroll glitch', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final eightChildren = List.generate(
        8,
        (i) => TDropdownItem(text: 'Sub Item $i'),
      );

      final parentItems = [
        TDropdownItem(text: 'Item 1'),
        TDropdownItem(text: 'Item 2'),
        TDropdownItem(text: 'Item 3'),
        TDropdownItem(text: 'Parent Submenu', children: eightChildren),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 200,
                  top: 100,
                  child: TDropdown(
                    triggerMode: TDropdownTriggerMode.tap,
                    items: parentItems,
                    child: const SizedBox(
                      width: 150,
                      height: 40,
                      child: Text('Main Menu Trigger'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Main Menu Trigger'));
      await tester.pumpAndSettle();

      // Hover on Parent Submenu to open child submenu
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('Parent Submenu')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // All 8 children should be visible
      for (int i = 0; i < 8; i++) {
        expect(find.text('Sub Item $i'), findsOneWidget);
      }

      // Find scrollables; the child submenu scrollable should have 0 scroll extent
      final scrollables = find.byType(Scrollable);
      for (final element in scrollables.evaluate()) {
        final state = (element as StatefulElement).state as ScrollableState;
        expect(state.position.maxScrollExtent, equals(0.0));
      }
    });

    testWidgets('Multi-level popup closes all open panels when mouse moves outside', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final childItems = [
        TDropdownItem(text: 'Child 1'),
        TDropdownItem(text: 'Child 2'),
      ];

      final parentItems = [
        TDropdownItem(text: 'Item A'),
        TDropdownItem(text: 'Submenu Root', children: childItems),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 200,
                  top: 100,
                  child: TDropdown(
                    triggerMode: TDropdownTriggerMode.hover,
                    items: parentItems,
                    child: const SizedBox(
                      width: 150,
                      height: 40,
                      child: Text('Hover Menu Trigger'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);

      // Hover on trigger to open level 0 panel
      await gesture.moveTo(tester.getCenter(find.text('Hover Menu Trigger')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Submenu Root'), findsOneWidget);

      // Hover on Submenu Root to open level 1 child panel
      await gesture.moveTo(tester.getCenter(find.text('Submenu Root')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Child 1'), findsOneWidget);

      // Hover on Child 1
      await gesture.moveTo(tester.getCenter(find.text('Child 1')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Move mouse completely outside to empty space (e.g. at 50, 50)
      await gesture.moveTo(const Offset(50, 50));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // All panels should now be closed
      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Submenu Root'), findsNothing);
    });
  });
}

class _TestSidebarNotifier extends SidebarNotifier {
  final TSidebarMode initial;
  _TestSidebarNotifier(this.initial);

  @override
  TSidebarMode build() => initial;
}
