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
  final Object? rootId;
  final TMenuTheme theme;
  final bool Function(T item)? isActive;
  final bool Function(T item)? containsActive;
  final ValueChanged<T>? onItemTap;
  final bool staggerItemEntrance;

  const TMenuOverlayPanel({
    super.key,
    required this.items,
    required this.level,
    this.rootId,
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
    final effectiveRootId = widget.rootId ?? TMenuScope.maybeOf(context);

    return MouseRegion(
      onEnter: (_) => TMenuOverlayController.setPanelHovered(widget.level, true, rootId: effectiveRootId),
      onExit: (_) => TMenuOverlayController.setPanelHovered(widget.level, false, rootId: effectiveRootId),
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
                border: BoxBorder.all(color: colors.outlineVariant, width: 1),
                boxShadow: [
                  // Light, wide ambient shadow — large blur and positive spread so the panel
                  // reads as lifted off the page, tinted with the theme's own shadow color
                  // rather than flat black so it stays subtle on light/pastel surfaces...
                  BoxShadow(color: colors.shadow.withAlpha(180), blurRadius: 32.0, spreadRadius: 2.0, offset: const Offset(0, 12)),
                  // ...plus a short, tight contact shadow (negative spread) right under the
                  // panel for a crisp edge close to the surface.
                  BoxShadow(color: colors.shadow.withAlpha(200), blurRadius: 8.0, spreadRadius: -2.0, offset: const Offset(0, 2)),
                ],
              ),
              constraints: widget.theme.boxConstraints,
              child: SingleChildScrollView(
                padding: widget.theme.overlayPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildRows(effectiveRootId),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows(Object? effectiveRootId) {
    final visible = widget.items.where((i) => !i.isHiddenIn(context)).toList();

    return List.generate(visible.length, (index) {
      final item = visible[index];
      if (item.customContent != null) {
        return item.customContent!;
      }
      final row = TMenuOverlayItem<T>(
        item: item,
        level: widget.level,
        rootId: effectiveRootId,
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
