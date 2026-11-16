import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class ResolvedLayoutItems {
  const ResolvedLayoutItems({
    required this.allItems,
    required this.sidebarItems,
    required this.bottomBarItems,
    required this.homeItem,
  });

  final List<TSidebarItem> allItems;
  final List<TSidebarItem> sidebarItems;
  final List<TSidebarItem> bottomBarItems;
  final TSidebarItem? homeItem;
}

ResolvedLayoutItems resolveLayoutItems(
  BuildContext context,
  List<TSidebarItem> resolvedItems, {
  required bool isMobile,
  required bool showHamburgerMenu,
}) {
  TSidebarItem? homeItem;
  final bottomBarCandidates = <TSidebarItem>[];

  for (final item in resolvedItems) {
    if (item.home) homeItem = item;
    if (item.bottomBarPosition != null && !item.isHiddenIn(context)) bottomBarCandidates.add(item);
  }

  final bottomBarItems = <TSidebarItem>[];
  if (homeItem != null && !homeItem.isHiddenIn(context) && (homeItem.children?.isEmpty ?? true)) bottomBarItems.add(homeItem);

  if (bottomBarCandidates.isEmpty && resolvedItems.isNotEmpty) {
    final slotCount = showHamburgerMenu ? 5 : 4;
    bottomBarItems.addAll(
      resolvedItems
          .where((item) => item != homeItem && !item.isHiddenIn(context) && (item.children?.isEmpty ?? true))
          .take(slotCount - bottomBarItems.length),
    );
  } else {
    bottomBarCandidates.sort((a, b) => a.bottomBarPosition!.compareTo(b.bottomBarPosition!));
    bottomBarItems.addAll(bottomBarCandidates.take(4 - bottomBarItems.length));
  }

  final sidebarItems = isMobile ? resolvedItems.where((item) => !bottomBarItems.contains(item)).toList() : resolvedItems;

  return ResolvedLayoutItems(
    allItems: resolvedItems,
    sidebarItems: sidebarItems,
    bottomBarItems: bottomBarItems,
    homeItem: homeItem,
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Main content + bottom bar
// ─────────────────────────────────────────────────────────────────────────

class LayoutMainContent extends StatelessWidget {
  const LayoutMainContent({super.key, required this.isMobile, required this.child, this.backgroundColor});

  final bool isMobile;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = context.scaffoldBackgroundColor;
    final fill = backgroundColor ?? background;

    return TBackgroundColorScope(
      backgroundColor: background,
      child: DecoratedBox(
        decoration: isMobile
            ? BoxDecoration(
                color: fill,
                border: Border(
                  top: BorderSide(color: colors.shadow, width: 0.5),
                  bottom: BorderSide(color: colors.shadow, width: 0.5),
                ),
              )
            : BoxDecoration(color: fill),
        child: Column(
          children: [
            SizedBox(height: isMobile ? 4 : 8),
            Expanded(
              child: Padding(
                padding: isMobile ? const EdgeInsets.symmetric(vertical: 6) : const EdgeInsets.only(left: 20, bottom: 6, top: 14),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
