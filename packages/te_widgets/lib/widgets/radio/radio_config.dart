import 'package:flutter/widgets.dart';

/// Represents a single option in a [TRadioGroup].
class TRadioGroupItem<T extends Object?> {
  /// The value associated with this item.
  final T value;

  /// The label text to display.
  final String label;

  /// Optional custom color for this item.
  final Color? color;

  /// Creates a radio group item.
  const TRadioGroupItem({
    required this.value,
    required this.label,
    this.color,
  });

  /// Creates an item where the label is the string representation of the value.
  TRadioGroupItem.map(
    this.value, {
    this.color,
  }) : label = value.toString();
}
