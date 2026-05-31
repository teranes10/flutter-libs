import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDropdown extends StatefulWidget {
  final TDropdownTheme? theme;
  final List<TDropdownItem> items;
  final Widget child;

  const TDropdown({
    super.key,
    this.theme,
    required this.items,
    required this.child,
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

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) {
        final mediaQuery = MediaQuery.of(context);
        final translation = layoutInfo.childPaintTransform.getTranslation();

        TPopupConstraints constraints = (
          screenSize: mediaQuery.size,
          targetSize: layoutInfo.childSize,
          targetOffset: Offset(translation.x, translation.y),
          contentBox: theme.boxConstraints,
          contentAlignment: FractionalOffset.topLeft,
        );

        return Stack(
          children: [
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: theme.alignment,
                offset: theme.offset,
              ),
              child: TDropdownOverlay(
                items: widget.items,
                level: 1,
                theme: theme,
              ),
            ),
          ],
        );
      },
      child: MouseRegion(
        key: _targetKey,
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: widget.child,
      ),
    );
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _scheduleOverlayShow();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
    TDropdownOverlayController.scheduleHide(delay: theme.hideDelay);
  }

  void _scheduleOverlayShow() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(TSidebarConstants.hoverDelay, () {
      if (mounted && _isHovered) {
        TDropdownOverlayController.hideAllOverlays();
        TDropdownOverlayController.registerOverlay(_overlayController);
        _overlayController.show();
      }
    });
  }
}
