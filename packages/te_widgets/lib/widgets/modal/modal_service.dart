import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/modal/modal.dart';
import 'package:te_widgets/widgets/modal/modal_config.dart';

class TModalService {
  static Future<T?> show<T>(
    BuildContext context,
    Widget Function(TModelContext context) builder, {
    TModalConfig config = const TModalConfig(),
    VoidCallback? onClose,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: !config.persistent,
      barrierColor: AppColors.grey[950]!.withAlpha(10),
      builder: (BuildContext dialogContext) {
        return TModal(
          builder.call(TModelContext(dialogContext)),
          config: config,
          onClose: () {
            Navigator.of(dialogContext).pop();
            onClose?.call();
          },
        );
      },
    );
  }
}
