import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

enum _TopBarSlot {
  logo,
  breadcrumbs,
  tristate,
  actions,
}

class _DesktopTopBarLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final bool isNoneMode;
  final ValueNotifier<List<TSidebarItem>> overflowNotifier;
  final List<TSidebarItem> allItems;

  _DesktopTopBarLayoutDelegate({
    required this.itemCount,
    required this.isNoneMode,
    required this.overflowNotifier,
    required this.allItems,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, 48.0);
  }

  @override
  void performLayout(Size size) {
    const spacing = 20.0;
    const itemSpacing = 16.0;

    // 1. Layout actions on the far right
    Size actionsSize = Size.zero;
    if (hasChild(_TopBarSlot.actions)) {
      actionsSize = layoutChild(
        _TopBarSlot.actions,
        BoxConstraints(maxWidth: size.width),
      );
    }

    // 2. Layout tristate button
    Size tristateSize = Size.zero;
    if (hasChild(_TopBarSlot.tristate)) {
      tristateSize = layoutChild(
        _TopBarSlot.tristate,
        BoxConstraints(maxWidth: size.width),
      );
    }

    final rightEdge = size.width - actionsSize.width;
    final tristateX = (hasChild(_TopBarSlot.actions) && actionsSize.width > 0 ? rightEdge - spacing : size.width) - tristateSize.width;

    // 3. Layout logo on the far left (in none mode)
    Size logoSize = Size.zero;
    if (hasChild(_TopBarSlot.logo)) {
      logoSize = layoutChild(
        _TopBarSlot.logo,
        BoxConstraints(maxWidth: size.width),
      );
    }

    final breadcrumbsX = hasChild(_TopBarSlot.logo) && logoSize.width > 0 ? logoSize.width + 12.0 : 0.0;

    // 4. Layout breadcrumbs after logo
    Size breadcrumbsSize = Size.zero;
    if (hasChild(_TopBarSlot.breadcrumbs)) {
      final maxBreadcrumbsWidth = (tristateX - spacing - breadcrumbsX - 20.0).clamp(0.0, size.width);
      breadcrumbsSize = layoutChild(
        _TopBarSlot.breadcrumbs,
        BoxConstraints(maxWidth: maxBreadcrumbsWidth),
      );
    }

    // 5. Measure each top navigation item
    final itemSizes = <Size>[];
    for (int i = 0; i < itemCount; i++) {
      if (hasChild(i)) {
        final s = layoutChild(
          i,
          BoxConstraints(maxWidth: size.width),
        );
        itemSizes.add(s);
      } else {
        itemSizes.add(Size.zero);
      }
    }

    // 6. Determine which items fit
    final breadcrumbsEnd = breadcrumbsX + (hasChild(_TopBarSlot.breadcrumbs) ? breadcrumbsSize.width : 0.0);
    final availableMenuWidth = tristateX - spacing - (breadcrumbsEnd + spacing);

    int fitCount = 0;
    double fitWidth = 0.0;

    if (isNoneMode && availableMenuWidth > 0) {
      for (int i = 0; i < itemCount; i++) {
        final w = itemSizes[i].width + (i > 0 ? itemSpacing : 0.0);
        if (fitWidth + w <= availableMenuWidth) {
          fitWidth += w;
          fitCount = i + 1;
        } else {
          break;
        }
      }
    }

    // 7. Position logo
    if (hasChild(_TopBarSlot.logo)) {
      final y = ((size.height - logoSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.logo, Offset(0, y));
    }

    // 8. Position breadcrumbs
    if (hasChild(_TopBarSlot.breadcrumbs)) {
      final y = ((size.height - breadcrumbsSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.breadcrumbs, Offset(breadcrumbsX, y));
    }

    // 9. Position menu items (centered between breadcrumbs and sidebar state icon, vertically bottom-aligned)
    if (fitCount > 0) {
      double currentX = (breadcrumbsEnd + tristateX - fitWidth) / 2;
      for (int i = 0; i < fitCount; i++) {
        if (hasChild(i)) {
          final y = (size.height - itemSizes[i].height).clamp(0.0, size.height);
          positionChild(i, Offset(currentX, y));
          currentX += itemSizes[i].width + itemSpacing;
        }
      }
    }

    // Hide overflow items offscreen
    for (int i = fitCount; i < itemCount; i++) {
      if (hasChild(i)) {
        positionChild(i, const Offset(-99999, -99999));
      }
    }

    // 10. Position tristate button (vertically bottom-aligned in none mode, center-aligned in full/minified)
    if (hasChild(_TopBarSlot.tristate)) {
      final y = isNoneMode
          ? (size.height - tristateSize.height).clamp(0.0, size.height)
          : ((size.height - tristateSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.tristate, Offset(tristateX, y));
    }

    // 11. Position actions
    if (hasChild(_TopBarSlot.actions)) {
      final y = ((size.height - actionsSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.actions, Offset(rightEdge, y));
    }

    // 12. Update overflow items notifier asynchronously if changed
    final overflow = isNoneMode ? allItems.sublist(fitCount) : <TSidebarItem>[];
    if (!listEquals(overflowNotifier.value, overflow)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!listEquals(overflowNotifier.value, overflow)) {
          overflowNotifier.value = overflow;
        }
      });
    }
  }

  @override
  bool shouldRelayout(_DesktopTopBarLayoutDelegate oldDelegate) {
    return oldDelegate.itemCount != itemCount || oldDelegate.isNoneMode != isNoneMode || !listEquals(oldDelegate.allItems, allItems);
  }
}

class LayoutDesktopTopBar extends ConsumerStatefulWidget {
  const LayoutDesktopTopBar({
    super.key,
    this.logo,
    this.minifiedLogo,
    required this.homeItem,
    required this.resolvedItems,
    this.sidebarItems = const [],
    required this.profile,
    required this.showThemeToggle,
    required this.showColorToggle,
    required this.actions,
    required this.showFullscreenToggle,
    required this.showLogout,
    required this.onLogout,
    this.sidebarTheme,
    this.canShowTopMenu,
  });

  final Widget? logo;
  final Widget? minifiedLogo;
  final TSidebarItem? homeItem;
  final List<TSidebarItem> resolvedItems;
  final List<TSidebarItem> sidebarItems;
  final Widget? profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final List<Widget>? actions;
  final bool showFullscreenToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final TSidebarTheme? sidebarTheme;
  final bool? canShowTopMenu;

  @override
  ConsumerState<LayoutDesktopTopBar> createState() => _LayoutDesktopTopBarState();
}

class _LayoutDesktopTopBarState extends ConsumerState<LayoutDesktopTopBar> {
  late final ValueNotifier<List<TSidebarItem>> _overflowNotifier;

  @override
  void initState() {
    super.initState();
    _overflowNotifier = ValueNotifier<List<TSidebarItem>>([]);
  }

  @override
  void dispose() {
    _overflowNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sidebarMode = ref.watch(sidebarNotifierProvider);
    final isNoneMode = sidebarMode == TSidebarMode.none || (widget.canShowTopMenu ?? false);
    final visibleItems = widget.sidebarItems.where((i) => !i.isHidden).toList();
    final effectiveLogo = widget.minifiedLogo ?? widget.logo;
    final menuTheme = (widget.sidebarTheme ?? TSidebarTheme.defaultTheme(context)).copyWith(
      alignment: TPopupAlignment.bottomLeft,
      offset: 8.0,
      secondaryAlignment: TPopupAlignment.rightTop,
      secondaryOffset: 4.0,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 7),
      child: SizedBox(
        height: 48.0,
        child: CustomMultiChildLayout(
          delegate: _DesktopTopBarLayoutDelegate(
            itemCount: visibleItems.length,
            isNoneMode: isNoneMode,
            overflowNotifier: _overflowNotifier,
            allItems: visibleItems,
          ),
          children: [
            if (isNoneMode && effectiveLogo != null)
              LayoutId(
                id: _TopBarSlot.logo,
                child: effectiveLogo,
              ),
            LayoutId(
              id: _TopBarSlot.breadcrumbs,
              child: TBreadcrumbs(
                items: widget.resolvedItems,
                includeHome: widget.homeItem != null,
                homeLabel: widget.homeItem?.text ?? 'Home',
                homeRoute: widget.homeItem?.route ?? '/',
              ),
            ),
            if (isNoneMode)
              for (int i = 0; i < visibleItems.length; i++)
                LayoutId(
                  id: i,
                  child: LayoutTopNavMenuItem(
                    item: visibleItems[i],
                    theme: menuTheme,
                  ),
                ),
            LayoutId(
              id: _TopBarSlot.tristate,
              child: SidebarTristateButton(
                overflowNotifier: isNoneMode ? _overflowNotifier : null,
                items: isNoneMode ? _overflowNotifier.value : const [],
                theme: widget.sidebarTheme,
              ),
            ),
            LayoutId(
              id: _TopBarSlot.actions,
              child: LayoutActionsRow(
                profile: widget.profile,
                showThemeToggle: widget.showThemeToggle,
                showColorToggle: widget.showColorToggle,
                actions: widget.actions,
                showFullscreenToggle: widget.showFullscreenToggle,
                showLogout: widget.showLogout,
                onLogout: widget.onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
