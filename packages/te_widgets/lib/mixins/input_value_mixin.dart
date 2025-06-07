import 'package:flutter/material.dart';

mixin TInputValueMixin<T> {
  T? get value;
  ValueNotifier<T>? get valueNotifier;
  ValueChanged<T>? get onValueChanged;
}

mixin TInputValueStateMixin<T, W extends StatefulWidget> on State<W> {
  TInputValueMixin<T> get _widget {
    assert(widget is TInputValueMixin<T>, 'Widget must mix in TInputValueMixin<$T>');
    return widget as TInputValueMixin<T>;
  }

  T? currentValue;

  @override
  void initState() {
    super.initState();
    final initial = _widget.valueNotifier?.value ?? _widget.value;
    if (initial != null) {
      _updateValue(initial, fromExternal: true);
    }
    _widget.valueNotifier?.addListener(_onValueNotifierChanged);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldMixin = oldWidget as TInputValueMixin<T>;
    final oldNotifier = oldMixin.valueNotifier;
    final newNotifier = _widget.valueNotifier;

    if (oldNotifier != newNotifier) {
      oldNotifier?.removeListener(_onValueNotifierChanged);
      newNotifier?.addListener(_onValueNotifierChanged);

      final newValue = newNotifier?.value;
      if (newValue != null) {
        _updateValue(newValue, fromExternal: true);
      }
    } else if (newNotifier == null) {
      final newValue = _widget.value;
      if (newValue != null) {
        _updateValue(newValue, fromExternal: true);
      }
    }
  }

  @override
  void dispose() {
    _widget.valueNotifier?.removeListener(_onValueNotifierChanged);
    super.dispose();
  }

  void _onValueNotifierChanged() {
    final newValue = _widget.valueNotifier!.value;
    _updateValue(newValue, fromExternal: true);
  }

  void _updateValue(T newValue, {bool fromExternal = false}) {
    if (newValue != currentValue) {
      currentValue = newValue;
      onValueChanged(newValue);
      if (fromExternal) onExternalValueChanged(newValue);
    }
  }

  void notifyValueChanged(T newValue) {
    if (newValue != currentValue) {
      currentValue = newValue;
      onValueChanged(newValue);
      _widget.onValueChanged?.call(newValue);
      _widget.valueNotifier?.value = newValue;
    }
  }

  @protected
  void onValueChanged(T value) {}

  @protected
  void onExternalValueChanged(T value) {}
}
