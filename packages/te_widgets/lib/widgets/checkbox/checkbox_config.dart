import 'package:flutter/material.dart';

enum TCheckboxSize { small, medium, large }

enum TCheckboxIcon { check, minus, square }

class TCheckboxColors {
  static const Map<String, Color> colors = {
    'primary': Colors.blue,
    'secondary': Colors.grey,
    'success': Colors.green,
    'warning': Colors.orange,
    'danger': Colors.red,
  };
}

class TCheckboxSizes {
  static const Map<TCheckboxSize, double> sizes = {
    TCheckboxSize.small: 16.0,
    TCheckboxSize.medium: 20.0,
    TCheckboxSize.large: 24.0,
  };
}

class TCheckboxGroupItem<T> {
  final T value;
  final String label;
  final String? color;
  final TCheckboxSize? size;
  final TCheckboxIcon? icon;

  const TCheckboxGroupItem({
    required this.value,
    required this.label,
    this.color,
    this.size,
    this.icon,
  });
}
