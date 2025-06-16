import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:te_widgets/te_widgets.dart';

mixin TPopupMixin {
  bool get disabled;
  double? get dropdownMaxHeight;
  VoidCallback? get onExpanded;
  VoidCallback? get onCollapsed;
}

mixin TPopupStateMixin<T extends StatefulWidget> on State<T> {
  TPopupMixin get _widget => widget as TPopupMixin;

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownTargetKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  BuildContext? _dialogContext;
  StateSetter? _dialogSetState;
  bool _isModalVisible = false;
  bool _openUpward = false;

  bool get persistent => false;
  bool get isOverlayShowing => _overlayEntry != null && _isOverlayVisible;
  bool get isModalShowing => _isModalVisible;
  bool get isPopupShowing => isOverlayShowing || isModalShowing;

  double get dropdownMaxHeight => _widget.dropdownMaxHeight ?? 400;
  bool get shouldShowModal => MediaQuery.of(context).size.width <= 600;
  bool get useRootNavigator => true;

  EdgeInsets get dropdownPadding => const EdgeInsets.all(20.0);
  BoxDecoration get dropdownDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      );

  Size get modalSize => const Size(400, 400);
  EdgeInsets get modalPadding => const EdgeInsets.all(20);
  BoxDecoration get modalDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      );

  double getContentWidth() {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    final containerWidth = renderBox?.size.width ?? 200;
    return math.max(containerWidth, 50);
  }

  double getContentHeight() => 400;

  Widget getContentWidget();

  Widget buildWithDropdownTarget({required Widget child}) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _dropdownTargetKey,
        child: child,
      ),
    );
  }

  void showPopup() {
    if (_widget.disabled || isPopupShowing) return;

    shouldShowModal ? _showModal() : _showDropdown();
  }

  void hidePopup() {
    if (isModalShowing) {
      _hideModal();
    } else if (isOverlayShowing) {
      _hideDropdown();
    }
  }

  void togglePopup() {
    isPopupShowing ? hidePopup() : showPopup();
  }

  void rebuildPopup() {
    if (!mounted || !isPopupShowing) return;

    if (isOverlayShowing) {
      _rebuildOverlay();
    } else if (isModalShowing) {
      _rebuildModal();
    }
  }

  Widget _buildContentWrapper() {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: getContentWidget(),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: CloseIconButton(onClose: hidePopup),
        ),
      ],
    );
  }

  Future<void> _showModal() async {
    _isModalVisible = true;
    _widget.onExpanded?.call();

    await showDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: !persistent,
      builder: (context) {
        _dialogContext = context;

        return StatefulBuilder(
          builder: (ctx, setState) {
            _dialogSetState = setState;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: modalDecoration.borderRadius ?? BorderRadius.circular(16),
              ),
              child: Container(
                width: modalSize.width,
                height: modalSize.height,
                decoration: modalDecoration,
                padding: modalPadding,
                child: _buildContentWrapper(),
              ),
            );
          },
        );
      },
    );

    _isModalVisible = false;
    _widget.onCollapsed?.call();
  }

  void _hideModal() {
    if (isModalShowing && _dialogContext != null && Navigator.of(_dialogContext!).canPop()) {
      Navigator.of(_dialogContext!).pop();
    }
  }

  void _rebuildModal() {
    if (_dialogSetState != null) {
      _dialogSetState!(() {});
    } else if (_dialogContext != null) {
      Navigator.of(_dialogContext!, rootNavigator: useRootNavigator).pop();
      Future.microtask(_showModal);
    }
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
    _widget.onCollapsed?.call();
  }

  void _showDropdown() {
    _calculateDropdownPosition();
    final dropdownHeight = math.min(dropdownMaxHeight, getContentHeight());

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (!persistent)
            GestureDetector(
              onTap: hidePopup,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          Positioned(
            width: getContentWidth(),
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: _openUpward ? Offset(0, -dropdownHeight - 8) : Offset(0, _getContainerHeight() + 8),
              child: Material(
                elevation: 8,
                borderRadius: dropdownDecoration.borderRadius ?? BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: dropdownHeight,
                    maxWidth: getContentWidth(),
                  ),
                  decoration: dropdownDecoration,
                  child: _buildContentWrapper(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: useRootNavigator).insert(_overlayEntry!);
    _isOverlayVisible = true;
    _widget.onExpanded?.call();
  }

  void _rebuildOverlay() => _overlayEntry?.markNeedsBuild();

  void _calculateDropdownPosition() {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (position.dy + renderBox.size.height);
    final spaceAbove = position.dy;
    final dropdownHeight = math.min(dropdownMaxHeight, getContentHeight());

    _openUpward = spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
  }

  double _getContainerHeight() {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 38;
  }

  @override
  void dispose() {
    hidePopup();
    super.dispose();
  }
}
