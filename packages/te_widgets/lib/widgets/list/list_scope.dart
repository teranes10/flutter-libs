import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListScope extends InheritedWidget {
  final TListController controller;

  const TListScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static TListScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TListScope>();
  }

  static TListScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'TListScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TListScope oldWidget) => controller != oldWidget.controller;
}
