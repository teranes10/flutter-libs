import 'package:flutter/material.dart';

/// Mixin for widgets that manage focus.
mixin TFocusMixin {
  /// Custom focus node.
  FocusNode? get focusNode;
}

/// State mixin for managing focus state.
mixin TFocusStateMixin<T extends StatefulWidget> on State<T> {
  TFocusMixin get _widget => widget as TFocusMixin;

  late final FocusNode _focusNode;
  late final bool _shouldDisposeFocusNode;
  bool _isFocused = false;

  /// The active focus node.
  FocusNode get focusNode => _focusNode;

  /// Whether the widget is currently focused.
  bool get isFocused => _isFocused;

  void _onFocusChanged() {
    _isFocused = _focusNode.hasFocus;
    onFocusChanged.call(_isFocused);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = _widget.focusNode ?? FocusNode();
    _shouldDisposeFocusNode = _widget.focusNode == null;

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_shouldDisposeFocusNode) _focusNode.dispose();
    super.dispose();
  }

  /// Callback called when focus state changes.
  void onFocusChanged(bool hasFocus);
}
