import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/layouts/widgets/sidebar/overlay/sidebar_overlay_controller.dart';
import 'package:te_widgets/te_widgets.dart';

class TSidebarTooltip extends StatefulWidget {
  final LayerLink layerLink;
  final String text;
  final TSidebarItem item;
  final TSidebarTheme theme;
  final Offset offset;

  const TSidebarTooltip({
    super.key,
    required this.layerLink,
    required this.text,
    required this.item,
    required this.theme,
    this.offset = const Offset(14, 0),
  });

  @override
  State<TSidebarTooltip> createState() => _TSidebarTooltipState();
}

class _TSidebarTooltipState extends State<TSidebarTooltip> with SingleTickerProviderStateMixin {
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

  void _handleTap() {
    if (widget.item.route != null) {
      context.go(widget.item.route!);
    }
    widget.item.onTap?.call();
    TSidebarOverlayController.hideAllOverlays();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: widget.layerLink,
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        offset: widget.offset,
        child: MouseRegion(
          onEnter: (_) => TSidebarOverlayController.setMouseInArea(true),
          onExit: (_) => TSidebarOverlayController.setMouseInArea(false),
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
              color: colors.surface,
              shadowColor: colors.shadow,
              child: InkWell(
                onTap: widget.item.isClickable ? _handleTap : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    minWidth: 120,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
