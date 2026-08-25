import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class LayoutMobileTopBar extends StatelessWidget {
  const LayoutMobileTopBar({
    super.key,
    required this.resolvedItems,
    required this.showHamburgerMenu,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  final List<TSidebarItem> resolvedItems;
  final bool showHamburgerMenu;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  TButton(
                    type: TButtonType.icon,
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                Expanded(
                  child: TBreadcrumbs(
                    items: resolvedItems,
                    includeHome: false,
                    homeLabel: 'Home',
                    homeRoute: '/',
                  ),
                ),
              ],
            ),
          ),
          if (showHamburgerMenu) ...[
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: TButton(
                key: ValueKey(isSidebarOpen),
                type: TButtonType.icon,
                icon: isSidebarOpen ? Icons.close_rounded : Icons.menu_rounded,
                size: TButtonSize.md.copyWith(icon: 20),
                color: colors.onSurface,
                onTap: onToggleSidebar,
                tooltip: isSidebarOpen ? 'Close menu' : 'Open menu',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
