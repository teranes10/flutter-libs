import 'package:flutter/material.dart';

/// Context provided to modal builders.
class TModalContext<T> {
  /// The build context.
  final BuildContext context;

  /// Creates a modal context.
  TModalContext(this.context);

  /// Closes the modal with an optional return value.
  void close([T? value]) {
    Navigator.of(context).pop(value);
  }
}

/// Builder function for modal content.
typedef TModalWidgetBuilder<T> = Widget Function(TModalContext<T> context);
