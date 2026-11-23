import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

enum _TopBarSlot {
  logo,
  switcher,
  breadcrumbs,
  center,
  trailing,
  actions,
}

/// Top bar sizing shared with the sidebar header so both rows line up.
abstract final class TTopBarMetrics {
  /// Content height with a profile button.
  static const double profileContentHeight = 48;

  /// Content height without a profile (compact, menu-bar style: 22 + 3 + 3 padding).
  static const double compactContentHeight = 22;

  static const double paddingTop = 0;
  static const double paddingBottom = 6;

  static double contentHeight({required bool hasProfile}) => hasProfile ? profileContentHeight : compactContentHeight;

  /// Total top bar height (content + vertical padding) when no extra content makes it taller.
  static double totalHeight({required bool hasProfile}) => contentHeight(hasProfile: hasProfile) + paddingTop + paddingBottom;
}

class _DesktopTopBarLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final bool isNoneMode;
  final List<TSidebarItem> allItems;

  _DesktopTopBarLayoutDelegate({
    required this.itemCount,
    required this.isNoneMode,
    required this.allItems,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight.isFinite ? constraints.maxHeight : constraints.minHeight);
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

    final rightEdge = size.width - actionsSize.width;
    var menuRightEdge = hasChild(_TopBarSlot.actions) && actionsSize.width > 0 ? rightEdge - spacing : size.width;

    // 2. Trailing details sit just left of the actions.
    Size trailingSize = Size.zero;
    if (hasChild(_TopBarSlot.trailing)) {
      trailingSize = layoutChild(_TopBarSlot.trailing, BoxConstraints(maxWidth: (size.width * 0.4).clamp(0.0, size.width)));
      positionChild(
        _TopBarSlot.trailing,
        Offset(menuRightEdge - trailingSize.width, ((size.height - trailingSize.height) / 2).clamp(0.0, size.height)),
      );
      menuRightEdge -= trailingSize.width + spacing;
    }

    // 3. Layout logo on the far left (in none mode)
    Size logoSize = Size.zero;
    if (hasChild(_TopBarSlot.logo)) {
      logoSize = layoutChild(
        _TopBarSlot.logo,
        BoxConstraints(maxWidth: size.width),
      );
    }

    // Context switcher sits right after the logo.
    Size switcherSize = Size.zero;
    var switcherX = hasChild(_TopBarSlot.logo) && logoSize.width > 0 ? logoSize.width + 12.0 : 0.0;
    if (hasChild(_TopBarSlot.switcher)) {
      switcherSize = layoutChild(_TopBarSlot.switcher, BoxConstraints(maxWidth: (size.width * 0.25).clamp(0.0, size.width)));
    }
    final breadcrumbsX = switcherSize.width > 0 ? switcherX + switcherSize.width + 12.0 : switcherX;

    // 4. Layout breadcrumbs after logo
    Size breadcrumbsSize = Size.zero;
    if (hasChild(_TopBarSlot.breadcrumbs)) {
      final maxBreadcrumbsWidth = (menuRightEdge - spacing - breadcrumbsX - 20.0).clamp(0.0, size.width);
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

    // Centre details take the middle of the free area; the menu then packs to the left of them.
    Size centerSize = Size.zero;
    if (hasChild(_TopBarSlot.center)) {
      final region = (menuRightEdge - breadcrumbsEnd - 2 * spacing).clamp(0.0, size.width);
      centerSize = layoutChild(_TopBarSlot.center, BoxConstraints(maxWidth: region * 0.5));
    }
    final centerReserve = centerSize.width > 0 ? centerSize.width + spacing : 0.0;
    final availableMenuWidth = menuRightEdge - spacing - (breadcrumbsEnd + spacing) - centerReserve;

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

    if (hasChild(_TopBarSlot.switcher)) {
      positionChild(_TopBarSlot.switcher, Offset(switcherX, ((size.height - switcherSize.height) / 2).clamp(0.0, size.height)));
    }

    // 8. Position breadcrumbs
    if (hasChild(_TopBarSlot.breadcrumbs)) {
      final y = ((size.height - breadcrumbsSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.breadcrumbs, Offset(breadcrumbsX, y));
    }

    // 9. Position menu items (centered between breadcrumbs and sidebar state icon, vertically bottom-aligned)
    if (hasChild(_TopBarSlot.center)) {
      final start = breadcrumbsEnd + spacing + (fitCount > 0 ? fitWidth + spacing : 0.0);
      // Prefer the true middle of the bar; slide only as far as needed to stay clear of its neighbours.
      final maxX = (menuRightEdge - centerSize.width).clamp(start, size.width);
      final x = ((size.width - centerSize.width) / 2).clamp(start, maxX);
      positionChild(_TopBarSlot.center, Offset(x, ((size.height - centerSize.height) / 2).clamp(0.0, size.height)));
    }

    if (fitCount > 0) {
      double currentX = hasChild(_TopBarSlot.center) ? breadcrumbsEnd + spacing : (breadcrumbsEnd + menuRightEdge - fitWidth) / 2;
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

    // 11. Position actions
    if (hasChild(_TopBarSlot.actions)) {
      final y = ((size.height - actionsSize.height) / 2).clamp(0.0, size.height);
      positionChild(_TopBarSlot.actions, Offset(rightEdge, y));
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
    this.switcher,
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
    this.centerContent,
    this.trailingContent,
  });

  /// Extra details shown in the middle of the top bar. The bar grows if this is taller than the bar.
  final Widget? centerContent;

  /// Extra details shown at the right, before the actions. The bar grows if this is taller than the bar.
  final Widget? trailingContent;

  final Widget? logo;
  final Widget? minifiedLogo;

  /// Context switcher shown after the logo (top-nav mode only).
  final TSwitcherBuilder? switcher;
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
  @override
  Widget build(BuildContext context) {
    final sidebarMode = ref.watch(sidebarNotifierProvider);
    final isNoneMode = sidebarMode == TSidebarMode.none || (widget.canShowTopMenu ?? false);
    final visibleItems = widget.sidebarItems.where((i) => !i.isHiddenIn(context)).toList();
    final effectiveLogo = widget.minifiedLogo ?? widget.logo;
    final menuTheme = (widget.sidebarTheme ?? TSidebarTheme.defaultTheme(context)).copyWith(
      alignment: TPopupAlignment.bottomLeft,
      offset: 8.0,
      secondaryAlignment: TPopupAlignment.rightTop,
      secondaryOffset: 4.0,
    );

    final compact = widget.profile == null && !isNoneMode;
    final minHeight = TTopBarMetrics.contentHeight(hasProfile: !compact);

    // The slot layout can't size itself from its children, so a hidden copy of the extras sets the bar height.
    final extras = [if (widget.centerContent != null) widget.centerContent!, if (widget.trailingContent != null) widget.trailingContent!];

    return Padding(
      padding: compact
          ? const EdgeInsets.only(bottom: 3)
          : const EdgeInsets.only(top: TTopBarMetrics.paddingTop, bottom: TTopBarMetrics.paddingBottom),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: extras.isEmpty
                  ? null
                  : Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: ExcludeSemantics(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: extras),
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: CustomMultiChildLayout(
                delegate: _DesktopTopBarLayoutDelegate(
                  itemCount: visibleItems.length,
                  isNoneMode: isNoneMode,
                  allItems: visibleItems,
                ),
                children: [
                  if (isNoneMode && effectiveLogo != null)
                    LayoutId(
                      id: _TopBarSlot.logo,
                      child: effectiveLogo,
                    ),
                  if (isNoneMode && widget.switcher != null)
                    LayoutId(id: _TopBarSlot.switcher, child: widget.switcher!(TSwitcherVariant.compact)),
                  LayoutId(
                    id: _TopBarSlot.breadcrumbs,
                    child: TBreadcrumbs(
                      style: compact ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w400) : null,
                      separator: Padding(
                        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
                        child: Text('/', style: TextStyle(color: Colors.grey, fontSize: compact ? 11 : null)),
                      ),
                      homeLabel: widget.homeItem?.text,
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
                  if (widget.centerContent != null) LayoutId(id: _TopBarSlot.center, child: widget.centerContent!),
                  if (widget.trailingContent != null) LayoutId(id: _TopBarSlot.trailing, child: widget.trailingContent!),
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
          ],
        ),
      ),
    );
  }
}
