import 'package:flutter/material.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_config.dart';
import 'package:te_widgets/layouts/widgets/sidebar/overlay/sidebar_overlay_controller.dart';
import 'package:te_widgets/layouts/widgets/sidebar/overlay/sidebar_overlay_item.dart';

class TSidebarOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final List<TSidebarItem> items;
  final int level;
  final TSidebarTheme theme;
  final Offset? parentPosition;
  final Offset offset;

  const TSidebarOverlay({
    super.key,
    required this.layerLink,
    required this.items,
    required this.level,
    required this.theme,
    this.parentPosition,
    this.offset = const Offset(14, -8),
  });

  @override
  State<TSidebarOverlay> createState() => _TSidebarOverlayState();
}

class _TSidebarOverlayState extends State<TSidebarOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: TSidebarConstants.overlayAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // For first level overlays, use CompositedTransformFollower
    if (widget.level == 1) {
      return Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.topLeft,
          offset: widget.offset,
          child: _buildOverlayContent(screenSize),
        ),
      );
    }

    // For nested overlays (level > 1), calculate position directly
    return _buildDirectPositionedOverlay(screenSize);
  }

  Widget _buildDirectPositionedOverlay(Size screenSize) {
    // Calculate position based on parent position and level
    final basePosition = widget.parentPosition ?? const Offset(200, 100);
    final overlayWidth = 275.0;
    final itemHeight = 44.0;
    final overlayHeight = (widget.items.length * itemHeight) + 16;

    // Calculate horizontal position (to the right of parent)
    double left = basePosition.dx + overlayWidth + 4;

    // Calculate vertical position (aligned with parent item)
    double top = basePosition.dy - 8;

    // Screen edge detection and adjustment
    if (left + overlayWidth > screenSize.width - 20) {
      // If it goes off right edge, place it to the left of parent
      left = basePosition.dx - overlayWidth - 4;
    }

    // Ensure it doesn't go off the left edge
    if (left < 20) {
      left = 20;
    }

    // Vertical adjustments
    if (top + overlayHeight > screenSize.height - 20) {
      top = screenSize.height - overlayHeight - 20;
    }
    if (top < 20) {
      top = 20;
    }

    return Positioned(
      left: left,
      top: top,
      child: _buildOverlayContent(screenSize),
    );
  }

  Widget _buildOverlayContent(Size screenSize) {
    return MouseRegion(
      onEnter: (_) => TSidebarOverlayController.setMouseInArea(true),
      onExit: (_) => TSidebarOverlayController.setMouseInArea(false),
      hitTestBehavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.15),
          child: Container(
            constraints: BoxConstraints(
              minWidth: 180,
              maxWidth: 275,
              maxHeight: screenSize.height * 0.6,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  return TSidebarOverlayItem(
                    item: item,
                    level: widget.level,
                    theme: widget.theme,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
