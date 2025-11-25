import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableScope extends InheritedWidget {
  final TListController controller;
  final ValueNotifier<String?>? activeCellNotifier;

  const TTableScope({
    super.key,
    required this.controller,
    required this.activeCellNotifier,
    required super.child,
  });

  static TTableScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TTableScope>();
  }

  static TTableScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'TTableScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TTableScope oldWidget) =>
      controller != oldWidget.controller || activeCellNotifier != oldWidget.activeCellNotifier;
}
