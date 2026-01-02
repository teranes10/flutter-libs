import 'package:flutter/foundation.dart';

/// A controller for managing tab selection state.
///
/// Extends [ValueNotifier] to provide reactive state management for tabs.
/// Can be shared between [TTabs] and [TTabContent] widgets to synchronize
/// tab selection and content display.
///
/// Example:
/// ```dart
/// final controller = TTabController<int>(initialValue: 0);
///
/// TTabs(
///   controller: controller,
///   tabs: [...],
/// )
///
/// TTabContent(
///   controller: controller,
///   tabs: [...],
/// )
/// ```
class TTabController<T> extends ValueNotifier<T?> {
  /// Creates a tab controller with an optional initial value.
  TTabController({T? initialValue}) : super(initialValue);

  /// Selects a tab by its value.
  ///
  /// This will notify all listeners and update any widgets using this controller.
  void selectTab(T value) {
    this.value = value;
  }

  /// Gets the currently selected tab value.
  T? get selectedValue => value;
}
