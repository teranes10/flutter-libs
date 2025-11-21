import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/list/controller/list_controller.dart';

class TTableScope<T, K> extends InheritedWidget {
  final TListController<T, K> controller;
  final ValueNotifier<String?>? activeCellNotifier;

  const TTableScope({
    super.key,
    required this.controller,
    required this.activeCellNotifier,
    required super.child,
  });

  static TTableScope<T, K>? maybeOf<T, K>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableScope<T, K>>();
  }

  static TTableScope<T, K> of<T, K>(BuildContext context) {
    final result = maybeOf<T, K>(context);
    assert(result != null, 'TTableScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TTableScope oldWidget) =>
      controller != oldWidget.controller || activeCellNotifier != oldWidget.activeCellNotifier;
}
