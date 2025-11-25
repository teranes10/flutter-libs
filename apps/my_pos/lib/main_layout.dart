import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/shared/widgets/app_bar/app_bar.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_bar.dart';
import 'package:te_widgets/te_widgets.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

final List<TNavItem> navItems = [
  TNavItem(icon: Icons.home_rounded, label: 'Home', isActive: true, onTap: () {}),
  TNavItem(icon: Icons.receipt_rounded, label: 'Bills', isActive: false, onTap: () {}),
  TNavItem(icon: Icons.settings, label: 'Settings', isActive: false, onTap: () {}),
];

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isWideScreen = context.isDesktop;

    return Scaffold(
      key: _scaffoldKey,
      appBar: TAppBar(
        navItems: navItems,
        isWideScreen: isWideScreen,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onCartPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: isWideScreen ? null : TBillBar(),
      bottomNavigationBar: isWideScreen ? null : TNavbar(items: navItems),
      body: Container(color: colors.surface, child: child),
    );
  }
}
