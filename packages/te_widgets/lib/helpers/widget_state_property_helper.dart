import 'package:flutter/material.dart';

class WidgetStatePropertyHelper {
  const WidgetStatePropertyHelper._();

  static WidgetStateProperty<T> resolveState<T>(T normal, {T? active, T? disabled}) {
    return WidgetStateProperty.resolveWith((states) {
      if (disabled != null && states.contains(WidgetState.disabled)) return disabled;
      if (active != null &&
          (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed) || states.contains(WidgetState.selected))) {
        return active;
      }
      return normal;
    });
  }
}
