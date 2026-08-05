import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Display mode options for a popup.
enum TPopupMode {
  anchored,
  centered,
  page,
}

/// Mixin for widgets that display a popup or dropdown.
mixin TPopupMixin {
  /// Whether the popup is disabled.
  bool get disabled;

  /// Preferred alignment of the popup.
  TPopupAlignment get alignment => TPopupAlignment.bottomLeft;

  /// Offset from the target widget.
  double get offset => 8;

  /// Whether to show a close button in the popup.
  bool get showCloseButton => true;

  /// Callback when popup shows.
  VoidCallback? get onShow;

  /// Callback when popup hides.
  VoidCallback? get onHide;

  /// Preferred display mode of the popup.
  TPopupMode? get popupMode => null;
}

/// State mixin for managing popup overlay logic.
///
/// Handles overlay creation, positioning, and dismissal.
mixin TPopupStateMixin<T extends StatefulWidget> on State<T> {
  late final TPopupMixin _widget = widget as TPopupMixin;

  final OverlayPortalController _overlayController = OverlayPortalController();

  final GlobalKey _dropdownTargetKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  bool _isOverlayVisible = false;

  /// Whether the popup persists when tapping outside (defaults to false).
  bool get persistent => false;

  /// Whether the popup is currently visible.
  bool get isPopupShowing => _isOverlayVisible;

  /// The effective display mode of the popup.
  TPopupMode get effectivePopupMode {
    final mode = _widget.popupMode;
    if (mode != null) return mode;
    final isMobile = MediaQuery.of(context).isMobile;
    if (isMobile && (widget is TSelect || widget is TMultiSelect)) {
      return TPopupMode.page;
    }
    return isMobile ? TPopupMode.centered : TPopupMode.anchored;
  }

  /// Whether to use centered overlay mode.
  bool get shouldCenteredOverlay => effectivePopupMode == TPopupMode.centered;

  static const _defaultSize = 100.0;

  /// Minimum width of the popup content.
  double get contentMinWidth => _defaultSize;

  /// Minimum height of the popup content.
  double get contentMinHeight => _defaultSize;

  /// Maximum width of the popup content.
  double? get contentMaxWidth => null;

  /// Maximum height of the popup content.
  double? get contentMaxHeight => null;

  /// Returns the content widget to display in the popup.
  Widget getContentWidget(BuildContext context);

  /// Optional sticky bottom footer widget displayed in page mode.
  Widget? getPopupFooter(BuildContext context) => null;

  /// Dynamic page title for page mode.
  String get popupTitle {
    if (widget is TInputFieldMixin) {
      return (widget as TInputFieldMixin).label ?? '';
    }
    return '';
  }

  /// Shows the popup.
  void showPopup(BuildContext context) {
    if (_widget.disabled || isPopupShowing) return;
    if (effectivePopupMode == TPopupMode.page) {
      _isOverlayVisible = true;
      _widget.onShow?.call();
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (ctx) => TPageWrapper(
            title: popupTitle,
            onBackPressed: () {
              hidePopup();
            },
            footer: getPopupFooter(ctx),
            child: getContentWidget(ctx),
          ),
        ),
      )
          .then((_) {
        if (mounted && _isOverlayVisible) {
          setState(() {
            _isOverlayVisible = false;
          });
          _widget.onHide?.call();
        }
      });
    } else {
      _overlayController.show();
      _isOverlayVisible = true;
      _widget.onShow?.call();
    }
  }

  /// Hides the popup.
  void hidePopup() {
    if (!isPopupShowing) return;
    if (effectivePopupMode == TPopupMode.page) {
      _isOverlayVisible = false;
      Navigator.of(context).pop();
    } else {
      _overlayController.hide();
      _isOverlayVisible = false;
      _widget.onHide?.call();
    }
  }

  /// Toggles popup visibility.
  void togglePopup(BuildContext context) {
    isPopupShowing ? hidePopup() : showPopup(context);
  }

  /// Forces a rebuild of the popup if it is open.
  void rebuildPopup() {
    if (!mounted || !isPopupShowing) return;
    setState(() {});
  }

  /// Wraps the child widget with an [OverlayPortal] anchored to the trigger.
  ///
  /// Call this instead of the old [buildWithDropdownTarget].  The returned
  /// widget is the trigger itself; the overlay child is built lazily via
  /// [overlayChildLayoutBuilder] and positioned without any
  /// [CompositedTransformTarget] / [CompositedTransformFollower].
  Widget buildWithDropdownTarget({required Widget child}) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (ctx, layoutInfo) {
        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: BoxConstraints(
            minWidth: contentMinWidth,
            minHeight: contentMinHeight,
            maxWidth: contentMaxWidth ?? layoutInfo.childSize.width,
            maxHeight: contentMaxHeight ?? double.infinity,
          ),
          defaultSize: _defaultSize,
        );

        return shouldCenteredOverlay ? buildCenteredOverlayChild(context, constraints) : buildAnchoredOverlayChild(context, constraints);
      },
      child: KeyedSubtree(key: _dropdownTargetKey, child: child),
    );
  }

  Widget buildCenteredOverlayChild(BuildContext context, TPopupConstraints constraints) {
    return Stack(
      children: [
        if (!persistent)
          Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: Theme.of(context).dialogTheme.barrierColor))),
        Align(
          alignment: constraints.contentAlignment,
          child: ConstrainedBox(
            constraints: constraints.contentBox,
            child: buildContentWidget(context),
          ),
        ),
      ],
    );
  }

  Widget buildAnchoredOverlayChild(BuildContext context, TPopupConstraints constraints) {
    return Stack(
      children: [
        if (!persistent) Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: Colors.transparent))),
        CustomSingleChildLayout(
          delegate: PopupPositionDelegate(
            constraints: constraints,
            alignment: _widget.alignment,
            offset: _widget.offset,
          ),
          child: ConstrainedBox(
            constraints: constraints.contentBox,
            child: buildContentWidget(context),
          ),
        ),
      ],
    );
  }

  Widget buildContentWidget(BuildContext context) {
    return TCard(
      elevation: 0,
      shadow: [
        BoxShadow(
          color: context.colors.shadow,
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 16),
        ),
      ],
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: _contentKey,
        child: Stack(
          children: [
            getContentWidget(context),
            if (_widget.showCloseButton)
              Positioned(top: 0, right: 0, child: TIcon.close(size: 20, padding: EdgeInsets.all(5), onTap: hidePopup)),
          ],
        ),
      ),
    );
  }
}
