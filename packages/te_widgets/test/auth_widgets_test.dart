import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  segmentedTests();
  menuDimTest();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  Widget host(TAuthController? c, Widget child) {
    final app = MaterialApp(theme: theme, home: Scaffold(body: child));
    return c == null ? app : TAuthScope(controller: c, child: app);
  }

  testWidgets('TTabs: denied tab hidden by default, disabled when overridden', (t) async {
    final c = TAuthController(permissions: const ['a']);
    await t.pumpWidget(host(
      c,
      TTabs<int>(
        selectedValue: 1,
        tabs: const [
          TTab(value: 1, text: 'One', permission: 'a'),
          TTab(value: 2, text: 'Two', permission: 'b'),
          TTab(value: 3, text: 'Three', permission: 'b', onDenied: TAuthMode.disable),
        ],
      ),
    ));
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsNothing);
    expect(find.text('Three'), findsOneWidget);
  });

  testWidgets('TBottomBar: denied item hidden, tap index keeps original position', (t) async {
    final c = TAuthController(permissions: const ['a', 'c']);
    int? tapped;
    await t.pumpWidget(host(
      c,
      TBottomBar(
        currentIndex: 0,
        onTap: (i) => tapped = i,
        textPosition: TBottomBarTextPosition.bottomAlways,
        items: const [
          TBottomBarItem(icon: HugeIcons.strokeRoundedHome01, label: 'Home', permission: 'a'),
          TBottomBarItem(icon: HugeIcons.strokeRoundedSearch01, label: 'Search', permission: 'b'),
          TBottomBarItem(icon: HugeIcons.strokeRoundedUser, label: 'Profile', permission: 'c'),
        ],
      ),
    ));
    expect(find.text('Search'), findsNothing);
    await t.tap(find.text('Profile'));
    expect(tapped, 2);
  });

  testWidgets('TButtonGroup: denied item hidden', (t) async {
    final c = TAuthController(permissions: const ['a']);
    await t.pumpWidget(host(
      c,
      TButtonGroup(items: [
        TButtonGroupItem(text: 'A', permission: 'a', onTap: () {}),
        TButtonGroupItem(text: 'B', permission: 'b', onDenied: TAuthMode.hide, onTap: () {}),
      ]),
    ));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
  });

  testWidgets('TNavItem and TTile honour permission', (t) async {
    final c = TAuthController(permissions: const []);
    var taps = 0;
    await t.pumpWidget(host(
      c,
      Column(children: [
        TNavItem(icon: HugeIcons.strokeRoundedHome01, label: 'Nav', isActive: true, permission: 'x', onTap: () => taps++),
        TTile(title: 'Tile', permission: 'x', onTap: () => taps++),
      ]),
    ));
    expect(find.text('Nav'), findsNothing); // nav default: hide
    await t.tap(find.text('Tile'));
    expect(taps, 0); // tile default: disable
  });

  testWidgets('Sidebar items: denied hidden, group with all children denied hidden', (t) async {
    t.view.physicalSize = const Size(1920, 1080);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);

    final items = [
      const TSidebarItem(icon: HugeIcons.strokeRoundedDashboardSquare01, text: 'Dashboard', route: '/d', home: true, permission: 'dash'),
      const TSidebarItem(icon: HugeIcons.strokeRoundedPackage, text: 'Reports', route: '/r', permission: 'reports'),
      const TSidebarItem(icon: HugeIcons.strokeRoundedSettings01, text: 'Admin', children: [
        TSidebarItem(icon: HugeIcons.strokeRoundedUserGroup, text: 'Users', route: '/u', permission: 'users'),
      ]),
    ];
    final c = TAuthController(permissions: const ['dash']);
    final router = GoRouter(initialLocation: '/d', routes: [
      GoRoute(path: '/d', builder: (_, __) => TLayout(items: items, child: const Text('content'))),
    ]);
    await t.pumpWidget(ProviderScope(
      child: TAuthScope(controller: c, child: MaterialApp.router(theme: theme, routerConfig: router)),
    ));
    await t.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Reports'), findsNothing);
    expect(find.text('Admin'), findsNothing);

    c.update(['dash', 'reports', 'users']);
    await t.pumpAndSettle();
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Admin'), findsWidgets);
  });
}

void menuDimTest() {
  testWidgets('TDropdown: permission-disabled item is dimmed and not tappable', (t) async {
    final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);
    var taps = 0;
    await t.pumpWidget(TAuthScope(
      controller: TAuthController(permissions: const []),
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: TDropdown(
              triggerMode: TDropdownTriggerMode.tap,
              items: [TDropdownItem(text: 'Delete', permission: 'x', onTap: () => taps++)],
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    final opacity = t.widget<Opacity>(find.ancestor(of: find.text('Delete'), matching: find.byType(Opacity)).first);
    expect(opacity.opacity, 0.45);
    await t.tap(find.text('Delete'));
    await t.pumpAndSettle();
    expect(taps, 0);
  });
}

void segmentedTests() {
  final theme = TAppTheme.defaultTheme().lightTheme;
  testWidgets('segmented TTabs and TButtonGroup render and select', (t) async {
    var tab = 1;
    var idx = 0;
    await t.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, set) => Column(children: [
            TTabs<int>(
              style: TTabStyle.segmented,
              inline: true,
              fill: true,
              selectedValue: tab,
              onTabChanged: (v) => set(() => tab = v),
              tabs: const [TTab(value: 1, text: 'Global settings'), TTab(value: 2, text: 'Node settings')],
            ),
            TButtonGroup(
              type: TButtonGroupType.segmented,
              expanded: true,
              initialIndex: idx,
              onIndexChanged: (i) => set(() => idx = i),
              items: [TButtonGroupItem(text: 'Global settings'), TButtonGroupItem(text: 'Node settings')],
            ),
          ]),
        ),
      ),
    ));
    expect(t.takeException(), isNull);
    await t.tap(find.text('Node settings').first);
    await t.pump();
    expect(tab, 2);
    await t.tap(find.text('Node settings').last);
    await t.pump(const Duration(milliseconds: 500));
    expect(idx, 1);
  });
}
