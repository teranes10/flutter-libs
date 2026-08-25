import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/helpers/popup_position.dart';
import 'package:te_widgets/widgets/menu/menu_item_data.dart';
import 'package:te_widgets/widgets/menu/menu_theme.dart';
import 'package:te_widgets/widgets/menu/menu_overlay_controller.dart';
import 'package:te_widgets/widgets/menu/menu_overlay_panel.dart';
import 'package:te_widgets/widgets/menu/menu_tooltip.dart';

enum TMenuTriggerMode { hover, tap }

/// Generic "hover/tap this compact widget to reveal a menu" trigger — the
/// shared root behind `TDropdown`.
///
/// It also covers the one thing the dropdown's trigger never needed to:
/// showing a plain-text [TMenuTooltip] instead of a panel when there's
/// nothing to expand into. That's what makes it reusable for the
/// sidebar's minimized, icon-only rows too, which used to hand-roll this
/// exact hover-then-decide-popup-or-tooltip behavior with a raw
/// `OverlayEntry` + `LayerLink`.
class TMenuRootTrigger<T extends TMenuItemData<T>> extends StatefulWidget {
  final Widget child;
  final List<T> items;
  final TMenuTheme theme;
  final TMenuTriggerMode triggerMode;
  final String? tooltipText;
  final bool Function(T item)? isActive;
  final bool Function(T item)? containsActive;
  final ValueChanged<T>? onItemTap;
  final VoidCallback? onTooltipTap;
  final Widget Function(BuildContext context, VoidCallback close)? builder;

  const TMenuRootTrigger({
    super.key,
    required this.child,
    this.items = const [],
    required this.theme,
    this.triggerMode = TMenuTriggerMode.hover,
    this.tooltipText,
    this.isActive,
    this.containsActive,
    this.onItemTap,
    this.onTooltipTap,
    this.builder,
  });

  @override
  State<TMenuRootTrigger<T>> createState() => _TMenuRootTriggerState<T>();
}

class _TMenuRootTriggerState<T extends TMenuItemData<T>> extends State<TMenuRootTrigger<T>> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  bool _isHovered = false;
  Timer? _hoverTimer;

  bool get _useTapOnly => widget.triggerMode == TMenuTriggerMode.tap;

  List<T> get _visibleItems => widget.items.where((i) => !i.isHidden).toList();
  bool get _hasMenu => _visibleItems.isNotEmpty;
  bool get _hasTooltip => !_hasMenu && (widget.tooltipText?.isNotEmpty ?? false);
  bool get _hasAnything => _hasMenu || _hasTooltip || widget.builder != null;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_overlayController.isShowing) {
      TMenuOverlayController.hideAll();
    } else if (_hasAnything) {
      TMenuOverlayController.hideAll();
      TMenuOverlayController.show(0, _overlayController);
    }
  }

  void _onEnter() {
    if (_useTapOnly) return;
    setState(() => _isHovered = true);
    TMenuOverlayController.setTriggerHovered(true);
    _scheduleShow();
  }

  void _onExit() {
    if (_useTapOnly) return;
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
    TMenuOverlayController.setTriggerHovered(false);
  }

  void _scheduleShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.theme.showDelay, () {
      if (mounted && _isHovered && _hasAnything) {
        TMenuOverlayController.hideAll();
        TMenuOverlayController.show(0, _overlayController);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) {
        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: widget.theme.boxConstraints,
          popupAlignment: widget.theme.alignment,
          alignment: FractionalOffset.topLeft,
        );

        Widget content;
        if (widget.builder != null) {
          content = Container(constraints: constraints.contentBox, child: widget.builder!(context, TMenuOverlayController.hideAll));
        } else if (_hasMenu) {
          content = TMenuOverlayPanel<T>(
            items: _visibleItems,
            level: 1,
            theme: widget.theme,
            isActive: widget.isActive,
            containsActive: widget.containsActive,
            onItemTap: widget.onItemTap,
          );
        } else {
          content = TMenuTooltip(text: widget.tooltipText ?? '', onTap: widget.onTooltipTap);
        }

        return Stack(
          children: [
            if (_useTapOnly)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: TMenuOverlayController.hideAll,
                ),
              ),
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: widget.theme.alignment,
                offset: widget.theme.offset,
              ),
              child: content,
            ),
          ],
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _useTapOnly ? _toggle : null,
          child: widget.child,
        ),
      ),
    );
  }
}
