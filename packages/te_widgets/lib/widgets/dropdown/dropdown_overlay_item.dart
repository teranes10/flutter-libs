import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDropdownOverlayItem extends StatefulWidget {
  final TDropdownItem item;
  final int level;
  final TDropdownTheme theme;
  final bool isActive;
  final bool containsActive;

  const TDropdownOverlayItem({
    super.key,
    required this.item,
    required this.level,
    required this.theme,
    this.isActive = false,
    this.containsActive = false,
  });

  @override
  State<TDropdownOverlayItem> createState() => _TDropdownOverlayItemState();
}

class _TDropdownOverlayItemState extends State<TDropdownOverlayItem> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  bool _isHovered = false;
  Timer? _hoverTimer;
  Timer? _exitTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.item.hasChildren) {
      _toggleSubOverlay();
    } else {
      widget.item.onTap?.call();
      TDropdownOverlayController.hideAllOverlays();
    }
  }

  void _toggleSubOverlay() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    } else {
      TDropdownOverlayController.registerOverlay(_overlayController);
      _overlayController.show();
    }
  }

  bool get _useTapOnly {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  void _onHoverEnter() {
    if (_useTapOnly) return;
    setState(() => _isHovered = true);
    _exitTimer?.cancel();
    TDropdownOverlayController.setMouseInArea(true);

    if (widget.item.hasChildren) {
      _scheduleSubOverlay();
    }
  }

  void _onHoverExit() {
    if (_useTapOnly) return;
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();

    _exitTimer = Timer(widget.theme.hideDelay, () {
      if (mounted && !_isHovered) {
        TDropdownOverlayController.setMouseInArea(false);
      }
    });
  }

  void _scheduleSubOverlay() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.theme.showDelay, () {
      if (mounted && _isHovered) {
        TDropdownOverlayController.registerOverlay(_overlayController);
        _overlayController.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.theme.getItemColor(
      isActive: widget.isActive,
      containsActive: widget.containsActive,
      isHovered: _isHovered,
    );

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) {
        final mediaQuery = MediaQuery.of(context);
        final translation = layoutInfo.childPaintTransform.getTranslation();

        TPopupConstraints constraints = (
          screenSize: mediaQuery.size,
          targetSize: layoutInfo.childSize,
          targetOffset: Offset(translation.x, translation.y),
          contentBox: widget.theme.boxConstraints,
          contentAlignment: FractionalOffset.topLeft,
        );

        return Stack(
          children: [
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: widget.theme.secondaryAlignment,
                offset: widget.theme.secondaryOffset,
              ),
              child: TDropdownOverlay(
                items: widget.item.children!,
                level: widget.level + 1,
                theme: widget.theme,
              ),
            ),
          ],
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        hitTestBehavior: HitTestBehavior.opaque,
        child: InkWell(
          onTap: _handleTap,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: widget.theme.itemBorderRadius,
          child: Container(
            width: double.infinity,
            padding: widget.theme.itemPadding,
            decoration: BoxDecoration(
              color: widget.isActive ? widget.theme.activeBackgroundColor : null,
              borderRadius: widget.theme.itemBorderRadius,
            ),
            child: _buildItemContent(color),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent(Color color) {
    return Row(
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: widget.theme.iconSize, color: color),
          if (widget.item.text != null) SizedBox(width: widget.theme.gap),
        ],
        if (widget.item.text != null)
          Expanded(
            child: Text(
              widget.item.text!,
              style: TextStyle(fontSize: widget.theme.fontSize, fontWeight: widget.theme.fontWeight, color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        if (widget.item.hasChildren)
          Padding(
            padding: EdgeInsets.only(left: widget.theme.gap),
            child: Icon(
              Icons.arrow_forward_ios,
              size: widget.theme.arrowIconSize,
              color: color,
            ),
          ),
      ],
    );
  }
}
