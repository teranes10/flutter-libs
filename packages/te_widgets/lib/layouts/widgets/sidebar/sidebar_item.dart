import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TSidebarItemWidget extends StatefulWidget {
  final TSidebarItem item;
  final bool isMinimized;
  final int level;
  final TSidebarTheme theme;
  final double? maxWidth;
  final Function(TSidebarItem)? onTap;

  const TSidebarItemWidget({
    super.key,
    required this.item,
    this.isMinimized = false,
    this.level = 0,
    required this.theme,
    this.maxWidth,
    this.onTap,
  });

  @override
  State<TSidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<TSidebarItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

  bool _isExpanded = false;
  bool _isHovered = false;
  Timer? _hoverTimer;

  // Replaces the old raw-OverlayEntry + LayerLink/CompositedTransformFollower
  // plumbing: the popup (submenu panel, or a tooltip for a leaf item) is now
  // an OverlayPortal owned by this widget and positioned by the same
  // PopupPositionDelegate the dropdown uses, so nested-submenu positioning
  // no longer needs the hand-computed RenderBox/offset math the old
  // TSidebarOverlayItem did.
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _isExpanded = widget.item.initiallyExpanded;
    if (_isExpanded) _animationController.value = 1.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateExpansionState();
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(duration: widget.theme.animationDuration, vsync: this);
    _slideAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_slideAnimation);
  }

  void _updateExpansionState() {
    final currentRoute = _getCurrentRoute();
    final shouldExpand = widget.item.initiallyExpanded || widget.item.containsRoute(currentRoute);

    if (shouldExpand != _isExpanded && !widget.isMinimized && widget.item.hasVisibleChildren) {
      if (shouldExpand && _shouldShowOverlayBecauseMaxWidth()) return;
      _setExpanded(shouldExpand);
    }
  }

  String _getCurrentRoute() {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (e) {
      return ModalRoute.of(context)?.settings.name ?? '/';
    }
  }

  void _setExpanded(bool expanded) {
    setState(() {
      _isExpanded = expanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  bool _shouldShowOverlayBecauseMaxWidth() {
    if (widget.maxWidth == null) return false;
    double maxItemWidth = 0.0;
    final textStyle = TextStyle(fontSize: widget.theme.fontSize, fontWeight: FontWeight.w300);
    final baseWidth = 56.0 + ((widget.level + 1) * 36.0);

    for (var child in widget.item.visibleChildren) {
      if (child.isHidden) continue;
      double itemWidth = baseWidth;
      if (child.icon != null) itemWidth += 30.0;
      if (child.text != null) {
        final tp = TextPainter(text: TextSpan(text: child.text, style: textStyle), textDirection: TextDirection.ltr)..layout();
        itemWidth += tp.width;
      }
      if (child.hasVisibleChildren) itemWidth += 24.0;
      if (itemWidth > maxItemWidth) maxItemWidth = itemWidth;
    }

    return maxItemWidth > widget.maxWidth!;
  }

  bool get _isNavigable => (widget.item.page != null || widget.item.builder != null) && widget.item.route != null;

  void _handleTap() {
    if (widget.item.hasVisibleChildren && !widget.isMinimized) {
      if (_isNavigable || widget.item.onTap != null) {
        _navigateAndExecute();
      } else if (_shouldShowOverlayBecauseMaxWidth()) {
        _showPopup();
      } else {
        _toggleExpanded();
      }
    } else {
      if (_isNavigable || widget.item.onTap != null) {
        _navigateAndExecute();
      }
    }
  }

  void _toggleExpanded() {
    if (widget.isMinimized || _shouldShowOverlayBecauseMaxWidth()) return;
    _setExpanded(!_isExpanded);
    widget.item.onTap?.call();
  }

  void _navigateAndExecute() {
    widget.item.tap(context);
    TMenuOverlayController.hideAll();
    widget.onTap?.call(widget.item);
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    if (widget.isMinimized) _scheduleOverlayShow();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
    if (widget.isMinimized) TMenuOverlayController.scheduleHide();
  }

  void _scheduleOverlayShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.theme.showDelay, () {
      if (mounted && _isHovered && (widget.item.hasVisibleChildren || widget.item.text != null)) {
        _showPopup();
      }
    });
  }

  void _showPopup() {
    TMenuOverlayController.hideAll();
    TMenuOverlayController.show(1, _overlayController);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isHidden) return const SizedBox.shrink();

    final currentRoute = _getCurrentRoute();
    final isCurrentRoute = widget.item.route == currentRoute;
    final containsCurrentRoute = widget.item.containsRoute(currentRoute);

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) => _buildPopup(context, layoutInfo, currentRoute),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainItem(isCurrentRoute, containsCurrentRoute),
          if (widget.item.hasVisibleChildren && !widget.isMinimized) _buildChildren(),
        ],
      ),
    );
  }

  Widget _buildPopup(BuildContext context, OverlayChildLayoutInfo layoutInfo, String currentRoute) {
    final constraints = TPopupConstraints.calculate(
      context,
      targetSize: layoutInfo.childSize,
      transform: layoutInfo.childPaintTransform,
      inputConstraints: widget.theme.boxConstraints,
      alignment: FractionalOffset.topLeft,
    );

    // Children -> a submenu panel. Leaf item -> a tooltip, since a bare
    // icon (minimized rail) or a width-overflowed label alone isn't
    // enough context. This mirrors the sidebar's original behavior, now
    // driven by the shared engine instead of a bespoke OverlayEntry.
    final content = widget.item.hasVisibleChildren
        ? TMenuOverlayPanel<TSidebarItem>(
            items: widget.item.visibleChildren,
            level: 1,
            theme: widget.theme,
            isActive: (i) => i.route == currentRoute,
            containsActive: (i) => i.containsRoute(currentRoute),
            onItemTap: widget.onTap,
          )
        : TMenuTooltip(
            text: widget.item.text ?? '',
            onTap: widget.item.isClickable ? _navigateAndExecute : null,
          );

    return Stack(
      children: [
        CustomSingleChildLayout(
          delegate: PopupPositionDelegate(
            constraints: constraints,
            alignment: widget.theme.secondaryAlignment,
            offset: widget.theme.secondaryOffset,
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildMainItem(bool isCurrentRoute, bool containsCurrentRoute) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: InkWell(
        onTap: _handleTap,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: widget.isMinimized
              ? widget.theme.minimizedItemPadding
              : widget.level == 0
                  ? widget.theme.itemPadding
                  : widget.theme.childPadding,
          margin: widget.isMinimized
              ? const EdgeInsets.symmetric(vertical: 3)
              : isCurrentRoute
                  ? const EdgeInsets.fromLTRB(8, 8, 12, 8)
                  : EdgeInsets.only(left: 8, right: 12),
          decoration: widget.isMinimized
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrentRoute ? widget.theme.activeBackgroundColor : colors.surfaceContainerHigh,
                )
              : BoxDecoration(
                  color: isCurrentRoute ? widget.theme.activeBackgroundColor : null,
                  borderRadius: BorderRadius.circular(8),
                ),
          child: _buildItemContent(isCurrentRoute, containsCurrentRoute),
        ),
      ),
    );
  }

  Widget _buildItemContent(bool isCurrentRoute, bool containsCurrentRoute) {
    final color = widget.theme.getItemColor(isActive: isCurrentRoute, containsActive: containsCurrentRoute, isHovered: _isHovered);

    return Row(
      mainAxisAlignment: widget.isMinimized ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (widget.item.icon != null) Icon(widget.item.icon, size: widget.theme.iconSize, color: color.withValues(alpha: 50)),
        if (widget.item.text != null && !widget.isMinimized) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.item.text!,
              style: TextStyle(fontSize: widget.theme.fontSize, fontWeight: FontWeight.w300, color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        if (widget.item.hasVisibleChildren && !widget.isMinimized) ...[
          const SizedBox(width: 8),
          _buildExpandIcon(color),
        ],
      ],
    );
  }

  Widget _buildExpandIcon(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 3.14159,
          child: Icon(Icons.expand_more, size: widget.theme.expandIconSize, color: color),
        );
      },
    );
  }

  Widget _buildChildren() {
    final visibleChildren = widget.item.visibleChildren;
    if (visibleChildren.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (_animationController.isDismissed) return const SizedBox.shrink();
        return child!;
      },
      child: SizeTransition(
        axisAlignment: 1.0,
        sizeFactor: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.level == 0 ? widget.theme.itemPadding.left * 2 : (widget.theme.itemPadding.left + widget.theme.childPadding.left),
          ),
          child: Container(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: widget.theme.borderColor, width: 1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: visibleChildren.map((child) {
                return TSidebarItemWidget(
                  item: child,
                  maxWidth: widget.maxWidth,
                  isMinimized: false,
                  level: widget.level + 1,
                  theme: widget.theme,
                  onTap: (child) => widget.onTap?.call(child),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
