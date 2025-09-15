import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TModalService {
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
