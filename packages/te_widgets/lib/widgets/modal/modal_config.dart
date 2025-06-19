import 'package:flutter/material.dart';

class TModalConfig {
  final bool persistent;
  final double width;
  final String? title;
  final bool? showCloseButton;
  final Widget? headerWidget;
  final Widget? footerWidget;

  const TModalConfig({
    this.persistent = false,
    this.showCloseButton = true,
    this.width = 500,
    this.title,
    this.headerWidget,
    this.footerWidget,
  });
}

class TModelContext<T> {
  final BuildContext context;

  TModelContext(this.context);

  void close([T? value]) {
    Navigator.of(context).pop(value);
  }
}
