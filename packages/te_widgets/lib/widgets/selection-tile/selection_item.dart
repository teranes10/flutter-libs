import 'package:flutter/material.dart';

/// Represents a single option in a [TSelectionGroup].
class TSelectionItem<T> {
  /// The value associated with this item.
  final T value;

  /// The label text displayed below the icon/image.
  final String label;

  /// Optional Material icon shown in the tile.
  final IconData? icon;

  /// Optional image widget (asset, network, illustration).
  ///
  /// Takes precedence over [icon] when both are provided.
  final Widget? image;

  /// Whether this item is disabled.
  final bool disabled;

  /// Creates a selection item.
  const TSelectionItem({
    required this.value,
    required this.label,
    this.icon,
    this.image,
    this.disabled = false,
  });
}
