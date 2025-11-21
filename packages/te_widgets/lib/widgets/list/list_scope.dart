import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/list/controller/list_controller.dart';

class TListScope<T, K> extends InheritedWidget {
  final TListController<T, K> controller;

  const TListScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static TListScope<T, K>? maybeOf<T, K>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TListScope<T, K>>();
  }

  static TListScope<T, K> of<T, K>(BuildContext context) {
    final result = maybeOf<T, K>(context);
    assert(result != null, 'TListScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TListScope oldWidget) => controller != oldWidget.controller;
}
