import 'package:flutter/widgets.dart';

/// Represents a single option in a [TRadioGroup].
class TRadioGroupItem<T extends Object?> {
  /// The value associated with this item.
  final T value;

  /// The label text to display.
  final String label;

  /// Optional custom color for this item.
  final Color? color;

  /// Icon shown in tile mode (leading in a row tile, above the label in a vertical tile).
  final dynamic icon;

  /// More detail. Tile mode only: under the label in a row tile, the hover tooltip of a vertical tile.
  final String? description;

  /// Creates a radio group item.
  const TRadioGroupItem({
    required this.value,
    required this.label,
    this.color,
    this.icon,
    this.description,
  });

  /// Creates an item where the label is the string representation of the value.
  TRadioGroupItem.map(
    this.value, {
    this.color,
    this.icon,
    this.description,
  }) : label = value.toString();
}
