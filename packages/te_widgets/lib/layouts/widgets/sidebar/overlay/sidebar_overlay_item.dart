import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_config.dart';
import 'package:te_widgets/layouts/widgets/sidebar/overlay/sidebar_overlay.dart';
import 'package:te_widgets/layouts/widgets/sidebar/overlay/sidebar_overlay_controller.dart';

class TSidebarOverlayItem extends StatefulWidget {
  final TSidebarItem item;
  final int level;
  final TSidebarTheme theme;

  const TSidebarOverlayItem({
    super.key,
    required this.item,
    required this.level,
    required this.theme,
  });

  @override
  State<TSidebarOverlayItem> createState() => _TSidebarOverlayItemState();
}

class _TSidebarOverlayItemState extends State<TSidebarOverlayItem> {
  bool _isHovered = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _itemKey = GlobalKey();
  Timer? _hoverTimer;
  Timer? _exitTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.item.route != null) {
      context.go(widget.item.route!);
    }
    widget.item.onTap?.call();
    TSidebarOverlayController.hideAllOverlays();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _exitTimer?.cancel();
    TSidebarOverlayController.setMouseInArea(true);

    if (widget.item.hasChildren) {
      _scheduleSubOverlay();
    } else {
      TSidebarOverlayController.removeOverlaysDeeper(widget.level + 1);
    }
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();

    _exitTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && !_isHovered) {
        TSidebarOverlayController.setMouseInArea(false);
      }
    });
  }

  void _scheduleSubOverlay() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted && _isHovered) {
        _showSubOverlay();
      }
    });
  }

  void _showSubOverlay() {
    if (!widget.item.hasChildren) return;

    Offset? currentPosition;
    try {
      final RenderBox? renderBox = _itemKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        currentPosition = renderBox.localToGlobal(Offset.zero);
      }
    } catch (e) {
      debugPrint('Error getting position: $e');
    }

    currentPosition ??= Offset(
      200 + (widget.level * 275.0),
      100,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) => TSidebarOverlay(
        layerLink: _layerLink,
        items: widget.item.children!,
        level: widget.level + 1,
        theme: widget.theme,
        parentPosition: currentPosition,
      ),
    );

    // Pass the level to the controller
    TSidebarOverlayController.showNestedOverlay(overlayEntry, widget.level + 1);
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute();
    final isCurrentRoute = widget.item.route == currentRoute;
    final containsCurrentRoute = widget.item.containsRoute(currentRoute);

    final color = widget.theme.getItemColor(
      isActive: isCurrentRoute,
      containsActive: containsCurrentRoute,
      isHovered: _isHovered,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _itemKey,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          hitTestBehavior: HitTestBehavior.opaque,
          child: InkWell(
            onTap: widget.item.isClickable ? _handleTap : null,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              padding: TSidebarConstants.overlayItemPadding,
              decoration: BoxDecoration(
                color: isCurrentRoute ? widget.theme.activeBackgroundColor : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: _buildItemContent(color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent(Color color) {
    return Row(
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: TSidebarConstants.overlayIconSize, color: color),
          if (widget.item.text != null) const SizedBox(width: 10),
        ],
        if (widget.item.text != null)
          Expanded(
            child: Text(
              widget.item.text!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        if (widget.item.hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.arrow_forward_ios,
              size: TSidebarConstants.arrowIconSize,
              color: color,
            ),
          ),
      ],
    );
  }

  String _getCurrentRoute() {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (e) {
      return ModalRoute.of(context)?.settings.name ?? '/';
    }
  }
}
