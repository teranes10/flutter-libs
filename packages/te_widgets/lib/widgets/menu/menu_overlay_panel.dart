import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// The "list of menu items" surface shown inside an overlay — used for
/// every nesting level of both `TDropdown` and `TSidebar` submenus.
///
/// Generalized from `TDropdownOverlay`. Two things were ported in from the
/// sidebar side while unifying this:
///  - [staggerItemEntrance]: the sidebar's flat item list staggered each
///    row's entrance (slide + fade); the dropdown's overlay only ever
///    faded/scaled the whole panel at once. Opt-in here since it may be
///    too busy for a hover-triggered popup at deeper levels.
///  - [isActive] / [containsActive] are real predicates over `T`, not the
///    booleans `TDropdownOverlay` used to take — the original wiring had
///    a bug where `containsActive` was actually just `isActive` called
///    twice, so nothing ever got the "contains active descendant" style.
class TMenuOverlayPanel<T extends TMenuItemData<T>> extends StatefulWidget {
  final List<T> items;
  final int level;
  final TMenuTheme theme;
  final bool Function(T item)? isActive;
  final bool Function(T item)? containsActive;
  final ValueChanged<T>? onItemTap;
  final bool staggerItemEntrance;

  const TMenuOverlayPanel({
    super.key,
    required this.items,
    required this.level,
    required this.theme,
    this.isActive,
    this.containsActive,
    this.onItemTap,
    this.staggerItemEntrance = false,
  });

  @override
  State<TMenuOverlayPanel<T>> createState() => _TMenuOverlayPanelState<T>();
}

class _TMenuOverlayPanelState<T extends TMenuItemData<T>> extends State<TMenuOverlayPanel<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.theme.animationDuration, vsync: this);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDarkMode;

    return MouseRegion(
      onEnter: (_) => TMenuOverlayController.setPanelHovered(widget.level, true),
      onExit: (_) => TMenuOverlayController.setPanelHovered(widget.level, false),
      hitTestBehavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _opacity.value, child: child),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: ElevationOverlay.applySurfaceTint(colors.surface, colors.surfaceTint, widget.theme.overlayElevation),
                borderRadius: widget.theme.overlayBorderRadius,
                border: BoxBorder.all(color: colors.surfaceTint, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(isDark ? 25 : 15), blurRadius: 16.0),
                  BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 2.0, spreadRadius: -1.0),
                ],
              ),
              constraints: widget.theme.boxConstraints,
              child: SingleChildScrollView(
                padding: widget.theme.overlayPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildRows(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows() {
    final visible = widget.items.where((i) => !i.isHidden).toList();

    return List.generate(visible.length, (index) {
      final item = visible[index];
      if (item.customContent != null) {
        return item.customContent!;
      }
      final row = TMenuOverlayItem<T>(
        item: item,
        level: widget.level,
        theme: widget.theme,
        isActive: widget.isActive?.call(item) ?? false,
        containsActive: widget.containsActive?.call(item) ?? false,
        isActiveFn: widget.isActive,
        containsActiveFn: widget.containsActive,
        onTap: widget.onItemTap,
      );

      if (!widget.staggerItemEntrance) return row;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 220 + (index * 45)),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Transform.translate(
          offset: Offset((1 - t) * 12, 0),
          child: Opacity(opacity: t, child: child),
        ),
        child: row,
      );
    });
  }
}
