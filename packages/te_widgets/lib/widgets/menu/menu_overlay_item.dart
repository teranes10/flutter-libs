import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/helpers/popup_position.dart';
import 'package:te_widgets/widgets/icon/icon.dart';
import 'package:te_widgets/widgets/menu/menu_item_data.dart';
import 'package:te_widgets/widgets/menu/menu_theme.dart';
import 'package:te_widgets/widgets/menu/menu_overlay_controller.dart';
import 'package:te_widgets/widgets/menu/menu_overlay_panel.dart';

/// A single row inside an open [TMenuOverlayPanel]. If the item has
/// visible children, hovering/tapping it opens another panel to the side
/// via its own [OverlayPortalController], positioned with the same
/// generic [PopupPositionDelegate] used everywhere else in this engine.
///
/// This is what used to be duplicated almost verbatim as
/// `TDropdownOverlayItem` and `TSidebarOverlayItem` — the sidebar version
/// additionally hand-computed nested-submenu positions from a
/// `RenderBox.localToGlobal` lookup with manual screen-edge collision
/// math; that's gone now, `OverlayPortal` + `PopupPositionDelegate`
/// handles it for every level uniformly.
class TMenuOverlayItem<T extends TMenuItemData<T>> extends StatefulWidget {
  final T item;
  final int level;
  final TMenuTheme theme;
  final bool isActive;
  final bool containsActive;

  /// Predicates threaded down so a nested panel opened from this item can
  /// keep resolving active state for its own descendants. (The original
  /// `TDropdownOverlayItem` didn't do this at all — nested dropdown levels
  /// past the first never highlighted the active item. Fixed here.)
  final bool Function(T item)? isActiveFn;
  final bool Function(T item)? containsActiveFn;

  final ValueChanged<T>? onTap;

  const TMenuOverlayItem({
    super.key,
    required this.item,
    required this.level,
    required this.theme,
    this.isActive = false,
    this.containsActive = false,
    this.isActiveFn,
    this.containsActiveFn,
    this.onTap,
  });

  @override
  State<TMenuOverlayItem<T>> createState() => _TMenuOverlayItemState<T>();
}

class _TMenuOverlayItemState<T extends TMenuItemData<T>> extends State<TMenuOverlayItem<T>> {
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

  bool get _useTapOnly {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  void _handleTap() {
    if (widget.item.hasVisibleChildren) {
      if (_overlayController.isShowing) {
        _overlayController.hide();
      } else {
        TMenuOverlayController.show(widget.level + 1, _overlayController);
      }
      return;
    }
    if (!widget.item.isClickable) return;
    widget.item.tap(context);
    TMenuOverlayController.hideAll();
    widget.onTap?.call(widget.item);
  }

  void _onEnter() {
    if (_useTapOnly) return;
    setState(() => _isHovered = true);
    _exitTimer?.cancel();

    if (widget.item.hasVisibleChildren) {
      _scheduleSubOverlay();
    } else {
      _hoverTimer?.cancel();
      _hoverTimer = Timer(widget.theme.showDelay, () {
        if (mounted && _isHovered) TMenuOverlayController.hideDeeperThan(widget.level);
      });
    }
  }

  void _onExit() {
    if (_useTapOnly) return;
    setState(() => _isHovered = false);
    _hoverTimer?.cancel();
  }

  void _scheduleSubOverlay() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.theme.showDelay, () {
      if (mounted && _isHovered) {
        TMenuOverlayController.show(widget.level + 1, _overlayController);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.color ??
        widget.theme.getItemColor(isActive: widget.isActive, containsActive: widget.containsActive, isHovered: _isHovered);

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, layoutInfo) {
        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: widget.theme.boxConstraints,
          popupAlignment: widget.theme.secondaryAlignment,
          alignment: FractionalOffset.topLeft,
        );

        final targetOffset = constraints.targetOffset;
        final targetSize = constraints.targetSize;
        final screenSize = constraints.screenSize;
        final spaceRight = screenSize.width - (targetOffset.dx + targetSize.width);
        final spaceLeft = targetOffset.dx;
        final requiredWidthSpace = (constraints.contentBox.minWidth > 0 ? constraints.contentBox.minWidth : 180.0) + widget.theme.secondaryOffset;

        final canShowRight = spaceRight >= requiredWidthSpace;
        final canShowLeft = spaceLeft >= requiredWidthSpace;

        TPopupAlignment actualAlignment = widget.theme.secondaryAlignment;

        // If parent preferred right, but cannot fit on right and can fit on left: open to left
        if (actualAlignment == TPopupAlignment.rightTop || actualAlignment == TPopupAlignment.rightBottom || actualAlignment == TPopupAlignment.rightCenter) {
          if (!canShowRight && canShowLeft) {
            actualAlignment = actualAlignment == TPopupAlignment.rightBottom ? TPopupAlignment.leftBottom : TPopupAlignment.leftTop;
          }
        }
        // If parent preferred left (or opened to left), continue opening to left as long as spaceLeft is sufficient
        else if (actualAlignment == TPopupAlignment.leftTop || actualAlignment == TPopupAlignment.leftBottom || actualAlignment == TPopupAlignment.leftCenter) {
          if (!canShowLeft && canShowRight) {
            actualAlignment = actualAlignment == TPopupAlignment.leftBottom ? TPopupAlignment.rightBottom : TPopupAlignment.rightTop;
          }
        }

        final childTheme = widget.theme.copyWith(
          secondaryAlignment: actualAlignment,
        );

        return Stack(
          children: [
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: actualAlignment,
                offset: widget.theme.secondaryOffset,
              ),
              child: TMenuOverlayPanel<T>(
                items: widget.item.visibleChildren,
                level: widget.level + 1,
                theme: childTheme,
                isActive: widget.isActiveFn,
                containsActive: widget.containsActiveFn,
                onItemTap: widget.onTap,
              ),
            ),
          ],
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
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
            child: _buildContent(color),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    return Row(
      children: [
        if (widget.item.icon != null) ...[
          TIcon(icon: widget.item.icon, size: widget.theme.iconSize, color: color),
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
        if (widget.item.hasVisibleChildren)
          Padding(
            padding: EdgeInsets.only(left: widget.theme.gap),
            child: Icon(
              widget.theme.arrowIcon ??
                  (widget.theme.secondaryAlignment == TPopupAlignment.leftTop ||
                   widget.theme.secondaryAlignment == TPopupAlignment.leftBottom ||
                   widget.theme.secondaryAlignment == TPopupAlignment.leftCenter
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded),
              size: widget.theme.arrowIconSize > 0 ? widget.theme.arrowIconSize : 16,
              color: color,
            ),
          ),
      ],
    );
  }
}
