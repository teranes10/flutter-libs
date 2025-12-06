import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Service for showing modal dialogs.
///
/// `TModalService` provides a simplified API for displaying [TModal] dialogs.
class TModalService {
  /// Shows a modal dialog.
  ///
  /// - [builder]: Function to build the content of the modal.
  /// - [header]: Optional custom header builder.
  /// - [footer]: Optional custom footer builder.
  /// - [persistent]: Whether the modal can be dismissed by tapping outside.
  /// - [width]: The width of the modal (default 500).
  /// - [title]: The title text for the default header.
  /// - [showCloseButton]: Whether to show a close button.
  static Future<T?> show<T>(
    BuildContext context,
    TModalWidgetBuilder<T> builder, {
    TModalWidgetBuilder? header,
    TModalWidgetBuilder? footer,
    bool persistent = false,
    double width = 500,
    String? title,
    bool? showCloseButton,
  }) {
    final colors = context.colors;

    return showDialog<T>(
      context: context,
      barrierDismissible: persistent,
      barrierColor: colors.scrim,
      builder: (BuildContext dialogContext) {
        final mContext = TModalContext<T>(dialogContext);

        return TModal(
          builder.call(mContext),
          header: header?.call(mContext),
          footer: footer?.call(mContext),
          persistent: persistent,
          width: width,
          title: title,
          showCloseButton: showCloseButton,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
