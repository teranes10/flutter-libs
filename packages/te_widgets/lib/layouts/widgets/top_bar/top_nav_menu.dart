import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class LayoutTopNavMenu extends StatelessWidget {
  final List<TSidebarItem> items;
  final TSidebarTheme? theme;

  const LayoutTopNavMenu({
    super.key,
    required this.items,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) => !item.isHidden).toList();
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    final menuTheme = (theme ?? TSidebarTheme.defaultTheme(context)).copyWith(
      alignment: TPopupAlignment.bottomLeft,
      offset: 6.0,
      secondaryAlignment: TPopupAlignment.rightTop,
      secondaryOffset: 4.0,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < visibleItems.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            LayoutTopNavMenuItem(
              item: visibleItems[i],
              theme: menuTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class LayoutTopNavMenuItem extends StatefulWidget {
  final TSidebarItem item;
  final TSidebarTheme theme;

  const LayoutTopNavMenuItem({
    super.key,
    required this.item,
    required this.theme,
  });

  @override
  State<LayoutTopNavMenuItem> createState() => _LayoutTopNavMenuItemState();
}

class _LayoutTopNavMenuItemState extends State<LayoutTopNavMenuItem> {
  bool _isHovered = false;

  String _getCurrentRoute() {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (e) {
      return ModalRoute.of(context)?.settings.name ?? '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute();
    final isCurrentRoute = widget.item.route == currentRoute;
    final containsCurrentRoute = widget.item.containsRoute(currentRoute);

    final triggerButton = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: _TopNavItemButton(
        item: widget.item,
        isActive: isCurrentRoute,
        containsActive: containsCurrentRoute,
        isHovered: _isHovered,
        hasChildren: widget.item.hasVisibleChildren,
        theme: widget.theme,
        onTap: () {
          if (!widget.item.hasVisibleChildren || widget.item.isClickable) {
            widget.item.tap(context);
            TMenuOverlayController.hideAll();
          }
        },
      ),
    );

    if (widget.item.hasVisibleChildren) {
      return TMenuRootTrigger<TSidebarItem>(
        items: widget.item.visibleChildren,
        theme: widget.theme,
        triggerMode: TMenuTriggerMode.hover,
        isActive: (i) => i.route == currentRoute,
        containsActive: (i) => i.containsRoute(currentRoute),
        onItemTap: (i) {
          i.tap(context);
          TMenuOverlayController.hideAll();
        },
        child: triggerButton,
      );
    }

    return triggerButton;
  }
}

class _TopNavItemButton extends StatelessWidget {
  final TSidebarItem item;
  final bool isActive;
  final bool containsActive;
  final bool isHovered;
  final bool hasChildren;
  final TSidebarTheme theme;
  final VoidCallback onTap;

  const _TopNavItemButton({
    required this.item,
    required this.isActive,
    this.containsActive = false,
    required this.isHovered,
    required this.hasChildren,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = isActive || containsActive;
    final color = theme.getItemColor(
      isActive: isActive,
      containsActive: containsActive,
      isHovered: isHovered,
    );

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: theme.iconSize * 0.9,
                color: color,
              ),
              if (item.text != null) const SizedBox(width: 4),
            ],
            if (item.text != null)
              Text(
                item.text!,
                style: TextStyle(
                  fontSize: theme.fontSize * 0.9,
                  fontWeight: isHighlighted ? FontWeight.w400 : FontWeight.w300,
                  color: color,
                ),
              ),
            if (hasChildren) ...[
              const SizedBox(width: 3),
              Icon(
                theme.dropdownIcon ?? Icons.keyboard_arrow_down_rounded,
                size: theme.arrowIconSize > 0 ? theme.arrowIconSize : 14,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
