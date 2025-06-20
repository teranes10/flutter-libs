import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/modal/modal.dart';
import 'package:te_widgets/widgets/modal/modal_config.dart';

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
    return showDialog<T>(
      context: context,
      barrierDismissible: persistent,
      barrierColor: AppColors.grey[950]!.withAlpha(10),
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
