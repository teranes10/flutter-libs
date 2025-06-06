import 'package:flutter/material.dart';

mixin TInputValueMixin<T> {
  T? get value;
  ValueNotifier<T>? get valueNotifier;
  ValueChanged<T>? get onValueChanged;

  void notifyValueChanged(T newValue) {
    valueNotifier?.value = newValue;
    onValueChanged?.call(newValue);
  }
}
