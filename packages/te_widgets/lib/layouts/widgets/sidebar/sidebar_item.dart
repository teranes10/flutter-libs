import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TSidebarItemWidget extends StatefulWidget {
  final TSidebarItem item;
  final bool isMinimized;
  final int level;
  final TSidebarTheme theme;
  final VoidCallback? onTap;

  const TSidebarItemWidget({super.key, required this.item, this.isMinimized = false, this.level = 0, required this.theme, this.onTap});

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

  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _isExpanded = widget.item.initiallyExpanded;

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
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
    _animationController = AnimationController(
      duration: TSidebarConstants.animationDuration,
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_slideAnimation);
  }

  void _updateExpansionState() {
    final currentRoute = _getCurrentRoute();
    final shouldExpand = widget.item.initiallyExpanded || widget.item.containsRoute(currentRoute);

    if (shouldExpand != _isExpanded && !widget.isMinimized) {
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

  void _handleTap() {
    if (widget.item.hasChildren && !widget.isMinimized) {
      _toggleExpanded();
    } else if (widget.item.isClickable) {
      _navigateAndExecute();
    }
  }

  void _toggleExpanded() {
    if (widget.isMinimized) return;

    _setExpanded(!_isExpanded);
    widget.item.onTap?.call();
  }

  void _navigateAndExecute() {
    if (widget.item.route != null) {
      context.go(widget.item.route!);
    }
    widget.item.onTap?.call();
    TSidebarOverlayController.hideAllOverlays();
    widget.onTap?.call();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);

    if (widget.isMinimized) {
      _scheduleOverlayShow();
    }
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();

    if (widget.isMinimized) {
      TSidebarOverlayController.scheduleHide();
    }
  }

  void _scheduleOverlayShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(TSidebarConstants.hoverDelay, () {
      if (mounted && _isHovered) {
        if (widget.item.hasChildren) {
          _showOverlay();
        } else if (widget.item.text != null) {
          _showTooltip();
        }
      }
    });
  }

  void _showOverlay() {
    final overlayEntry = OverlayEntry(
      builder: (context) => TSidebarOverlay(
        layerLink: _layerLink,
        items: widget.item.children!,
        level: widget.level + 1,
        theme: widget.theme,
        offset: Offset(14, -8),
      ),
    );

    TSidebarOverlayController.showOverlay(overlayEntry);
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }

  void _showTooltip() {
    final overlayEntry = OverlayEntry(
      builder: (context) => TSidebarTooltip(
        layerLink: _layerLink,
        text: widget.item.text!,
        item: widget.item,
        theme: widget.theme,
        offset: Offset(14, 0),
      ),
    );

    TSidebarOverlayController.showOverlay(overlayEntry);
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute();
    final isCurrentRoute = widget.item.route == currentRoute;
    final containsCurrentRoute = widget.item.containsRoute(currentRoute);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainItem(isCurrentRoute, containsCurrentRoute),
          if (widget.item.hasChildren && !widget.isMinimized) _buildChildren(),
        ],
      ),
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
          width: double.infinity,
          padding: widget.isMinimized ? TSidebarConstants.minimizedItemPadding : TSidebarConstants.itemPadding,
          margin: widget.isMinimized
              ? EdgeInsets.symmetric(vertical: 3)
              : isCurrentRoute
                  ? EdgeInsets.symmetric(vertical: 12, horizontal: 10)
                  : EdgeInsets.symmetric(horizontal: 10),
          decoration: widget.isMinimized
              ? BoxDecoration(
                  shape: BoxShape.circle, color: isCurrentRoute ? widget.theme.activeBackgroundColor : colors.surfaceContainerHigh)
              : BoxDecoration(color: isCurrentRoute ? widget.theme.activeBackgroundColor : null, borderRadius: BorderRadius.circular(8)),
          child: _buildItemContent(isCurrentRoute, containsCurrentRoute),
        ),
      ),
    );
  }

  Widget _buildItemContent(bool isCurrentRoute, bool containsCurrentRoute) {
    final color = widget.theme.getItemColor(
      isActive: isCurrentRoute,
      containsActive: containsCurrentRoute,
      isHovered: _isHovered,
    );

    return Row(
      mainAxisAlignment: widget.isMinimized ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (widget.item.icon != null) Icon(widget.item.icon, size: TSidebarConstants.iconSize, color: color.withValues(alpha: 50)),
        if (widget.item.text != null && !widget.isMinimized) ...[
          const SizedBox(width: 10),
          Text(
            widget.item.text!,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: color),
          ),
        ],
        if (widget.item.hasChildren && !widget.isMinimized) ...[
          const Spacer(),
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
          child: Icon(
            Icons.expand_more,
            size: TSidebarConstants.expandIconSize,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildChildren() {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.only(left: TSidebarConstants.itemPadding.left * 2),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: widget.theme.borderColor, width: 1, style: BorderStyle.solid))),
          child: Column(
            children: widget.item.children!.map((child) {
              return TSidebarItemWidget(
                item: child,
                isMinimized: false,
                level: widget.level + 1,
                theme: widget.theme,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
