import 'package:flutter/material.dart';

class TModalContext<T> {
  final BuildContext context;

  TModalContext(this.context);

  void close([T? value]) {
    Navigator.of(context).pop(value);
  }
}

typedef TModalWidgetBuilder<T> = Widget Function(TModalContext<T> context);
