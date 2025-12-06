import 'package:flutter/widgets.dart';

/// Represents a single option in a [TCheckboxGroup].
class TCheckboxGroupItem<T extends Object?> {
  /// The value associated with this item.
  final T value;

  /// The label text to display.
  final String label;

  /// Optional custom color for this item.
  final Color? color;

  /// Creates a checkbox group item.
  const TCheckboxGroupItem({
    required this.value,
    required this.label,
    this.color,
  });

  /// Creates an item where the label is the string representation of the value.
  TCheckboxGroupItem.map(
    this.value, {
    this.color,
  }) : label = value.toString();
}
