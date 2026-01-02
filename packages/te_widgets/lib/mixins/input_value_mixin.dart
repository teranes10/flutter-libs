import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:te_widgets/enum/value_type.dart';

/// Mixin for widgets that hold a typed value.
mixin TInputValueMixin<T> {
  /// The initial value.
  T? get value;

  /// A ValueNotifier for two-way binding.
  ValueNotifier<T?>? get valueNotifier;

  /// Callback fired when the value changes.
  ValueChanged<T?>? get onValueChanged;
}

/// State mixin for managing widget value state.
///
/// Handles initialization from ValueNotifier or initial value,
/// and synchronizes state between internal value and external Notifier.
mixin TInputValueStateMixin<T, W extends StatefulWidget> on State<W> {
  TInputValueMixin<T> get _widget {
    assert(widget is TInputValueMixin<T>, 'Widget must mix in TInputValueMixin<$T>, but got ${widget.runtimeType}');
    return widget as TInputValueMixin<T>;
  }

  T? _currentValue;

  /// The current value of the input.
  T? get currentValue => _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = _widget.valueNotifier?.value ?? _widget.value;
    _widget.valueNotifier?.addListener(_onValueNotifierChanged);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final initial = _widget.valueNotifier?.value ?? _widget.value;
      if (initial != null) {
        _updateValue(initial, fromExternal: true, initial: true, force: true);
      }
    });
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
      _updateValue(newValue, fromExternal: true);
    } else if (newNotifier == null) {
      final newValue = _widget.value;
      _updateValue(newValue, fromExternal: true);
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

  void _updateValue(T? newValue, {bool fromExternal = false, bool initial = false, bool force = false}) {
    if (force || newValue != currentValue) {
      final oldValue = _currentValue;
      _currentValue = newValue;
      onValueChanged(newValue, initial: initial, oldValue: oldValue);
      if (fromExternal) onExternalValueChanged(newValue);
    }
  }

  /// Updates the value and notifies listeners.
  void notifyValueChanged(T? newValue) {
    if (newValue != currentValue) {
      final oldValue = _currentValue;
      _currentValue = newValue;
      onValueChanged(newValue, oldValue: oldValue);
      _widget.onValueChanged?.call(newValue);
      _widget.valueNotifier?.value = newValue;
    }
  }

  /// Returns the type of the value being managed.
  ValueType getValueType() {
    return ValueType.from(T.toString());
  }

  @protected
  void onValueChanged(T? value, {bool initial = false, T? oldValue}) {}

  @protected
  void onExternalValueChanged(T? value) {}
}
