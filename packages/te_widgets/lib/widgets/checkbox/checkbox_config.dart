import 'package:flutter/widgets.dart';

class TCheckboxGroupItem<T extends Object?> {
  final T value;
  final String label;
  final Color? color;

  const TCheckboxGroupItem({
    required this.value,
    required this.label,
    this.color,
  });

  TCheckboxGroupItem.map(
    this.value, {
    this.color,
  }) : label = value.toString();
}
