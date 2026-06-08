import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDropdownOverlay extends StatefulWidget {
  final List<TDropdownItem> items;
  final int level;
  final TDropdownTheme theme;
  final bool Function()? isActive;
  final bool Function()? containsActive;

  const TDropdownOverlay({super.key, required this.items, required this.level, required this.theme, this.isActive, this.containsActive});

  @override
  State<TDropdownOverlay> createState() => _TDropdownOverlayState();
}

class _TDropdownOverlayState extends State<TDropdownOverlay> with SingleTickerProviderStateMixin {
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
    _animationController = AnimationController(duration: widget.theme.animationDuration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return _buildOverlayContent(screenSize);
  }

  Widget _buildOverlayContent(Size screenSize) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => TDropdownOverlayController.setMouseInArea(true),
      onExit: (_) => TDropdownOverlayController.setMouseInArea(false),
      hitTestBehavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _opacityAnimation.value, child: child),
          );
        },
        child: Material(
          elevation: widget.theme.overlayElevation,
          borderRadius: widget.theme.overlayBorderRadius,
          color: colors.surface,
          child: IntrinsicWidth(
            child: Container(
              constraints: widget.theme.boxConstraints,
              child: SingleChildScrollView(
                padding: widget.theme.overlayPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.map((item) {
                    return TDropdownOverlayItem(
                      item: item,
                      level: widget.level,
                      theme: widget.theme,
                      isActive: widget.isActive?.call() ?? false,
                      containsActive: widget.isActive?.call() ?? false,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
