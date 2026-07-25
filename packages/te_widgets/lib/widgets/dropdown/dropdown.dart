import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TDropdownTriggerMode { hover, tap }

class TDropdown extends StatefulWidget {
  final TDropdownTheme? theme;
  final List<TDropdownItem> items;
  final Widget child;
  final TDropdownTriggerMode triggerMode;
  final bool enabled;
  final Widget Function(BuildContext context, VoidCallback close)? builder;

  const TDropdown({
    super.key,
    this.theme,
    this.items = const [],
    required this.child,
    this.triggerMode = TDropdownTriggerMode.hover,
    this.enabled = true,
    this.builder,
  });

  @override
  State<TDropdown> createState() => _DropdownState();
}

class _DropdownState extends State<TDropdown> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey _targetKey = GlobalKey();
  bool _isHovered = false;
  Timer? _hoverTimer;

  TDropdownTheme get theme => widget.theme ?? TDropdownTheme.defaultTheme(context.colors);

  bool get _useTapOnly {
    return widget.triggerMode == TDropdownTriggerMode.tap || context.isMobilePlatform || context.isMobile;
  }

  void _closeDropdown() {
    TDropdownOverlayController.hideAllOverlays();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Opacity(opacity: 0.7, child: widget.child);
    }

    Widget triggerChild = widget.child;
    bool useClickWrapper = true;

    if (triggerChild is TButton) {
      if (triggerChild.onTap == null && triggerChild.onPressed == null) {
        triggerChild = triggerChild.copyWith(onTap: _toggleDropdown);
        useClickWrapper = false;
      }
    }

    Widget triggerWidget = useClickWrapper
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleDropdown,
            child: triggerChild,
          )
        : triggerChild;

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) {
        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: theme.boxConstraints,
          alignment: FractionalOffset.topLeft,
        );

        final overlayContent = widget.builder != null
            ? Container(
                constraints: constraints.contentBox,
                child: widget.builder!(context, _closeDropdown),
              )
            : TDropdownOverlay(
                items: widget.items,
                level: 1,
                theme: theme,
              );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (!_useTapOnly) return;
                  TDropdownOverlayController.hideAllOverlays();
                },
              ),
            ),
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: theme.alignment,
                offset: theme.offset,
              ),
              child: overlayContent,
            ),
          ],
        );
      },
      child: MouseRegion(
        key: _targetKey,
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onExitHover(),
        child: triggerWidget,
      ),
    );
  }

  void _toggleDropdown() {
    if (!_useTapOnly) return;
    if (_overlayController.isShowing) {
      TDropdownOverlayController.hideAllOverlays();
    } else {
      TDropdownOverlayController.hideAllOverlays();
      TDropdownOverlayController.showOverlay(0, _overlayController);
    }
  }

  void _onHoverEnter() {
    if (_useTapOnly) return;
    setState(() => _isHovered = true);
    _scheduleOverlayShow();
  }

  void _onExitHover() {
    if (_useTapOnly) return;
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
    TDropdownOverlayController.scheduleHide(delay: theme.hideDelay);
  }

  void _scheduleOverlayShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(TSidebarConstants.hoverDelay, () {
      if (mounted && _isHovered) {
        TDropdownOverlayController.hideAllOverlays();
        TDropdownOverlayController.showOverlay(0, _overlayController);
      }
    });
  }
}
