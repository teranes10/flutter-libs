import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

enum TCheckboxSize { small, medium, large }

enum TCheckboxIcon { check, minus, square }

class TCheckboxColors {
  static const Map<String, Color> colors = {
    'primary': AppColors.primary,
    'secondary': AppColors.secondary,
    'success': AppColors.success,
    'warning': AppColors.warning,
    'danger': AppColors.danger,
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
