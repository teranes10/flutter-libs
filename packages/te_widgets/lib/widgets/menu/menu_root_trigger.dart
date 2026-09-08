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
  final Object _rootId = Object();
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
    TMenuOverlayController.disposeRoot(_rootId);
    super.dispose();
  }

  void _toggle(Object? parentRootId) {
    if (_overlayController.isShowing) {
      TMenuOverlayController.hideRoot(_rootId);
    } else if (_hasAnything) {
      TMenuOverlayController.show(0, _overlayController, rootId: _rootId, parentRootId: parentRootId);
    }
  }

  void _onEnter() {
    if (_useTapOnly) return;
    setState(() => _isHovered = true);
    TMenuOverlayController.setTriggerHovered(true, rootId: _rootId);
    _scheduleShow();
  }

  void _onExit() {
    if (_useTapOnly) return;
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
    TMenuOverlayController.setTriggerHovered(false, rootId: _rootId);
  }

  void _scheduleShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.theme.showDelay, () {
      if (mounted && _isHovered && _hasAnything) {
        final parentRootId = TMenuScope.maybeOf(context);
        TMenuOverlayController.show(0, _overlayController, rootId: _rootId, parentRootId: parentRootId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final parentRootId = TMenuScope.maybeOf(context);

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

        return TMenuScope(
          rootId: _rootId,
          child: Stack(
            children: [
              if (_useTapOnly)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => TMenuOverlayController.hideRoot(_rootId),
                  ),
                ),
              CustomSingleChildLayout(
                delegate: PopupPositionDelegate(
                  constraints: constraints,
                  alignment: widget.theme.alignment,
                  offset: widget.theme.offset,
                ),
                child: Builder(
                  builder: (scopeCtx) {
                    if (widget.builder != null) {
                      return Container(
                        constraints: constraints.contentBox,
                        child: widget.builder!(scopeCtx, () => TMenuOverlayController.hideRoot(_rootId)),
                      );
                    } else if (_hasMenu) {
                      return TMenuOverlayPanel<T>(
                        items: _visibleItems,
                        level: 1,
                        rootId: _rootId,
                        theme: widget.theme,
                        isActive: widget.isActive,
                        containsActive: widget.containsActive,
                        onItemTap: widget.onItemTap,
                      );
                    } else {
                      return TMenuTooltip(text: widget.tooltipText ?? '', onTap: widget.onTooltipTap);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _toggle(parentRootId),
          child: widget.child,
        ),
      ),
    );
  }
}
