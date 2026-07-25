import 'package:flutter/material.dart';

class TBackgroundColorScope extends InheritedWidget {
  final Color backgroundColor;

  const TBackgroundColorScope({
    super.key,
    required this.backgroundColor,
    required super.child,
  });

  static Color? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TBackgroundColorScope>()?.backgroundColor;
  }

  @override
  bool updateShouldNotify(TBackgroundColorScope oldWidget) => backgroundColor != oldWidget.backgroundColor;
}
