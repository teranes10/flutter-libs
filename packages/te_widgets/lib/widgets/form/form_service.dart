import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TFormService {
  static Future<T?> show<T extends TFormBase>(BuildContext context, T input) {
    final theme = context.theme;

    return TModalService.show<T>(
      context,
      persistent: input.isFormPersistent,
      showCloseButton: input.isFormCloseButton,
      width: input.formWidth,
      title: input.formTitle,
      (mContext) {
        return Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TFormBuilder(input: input),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5,
                  children: [
                    TButton(
                        size: TButtonSize.md.copyWith(minW: 125),
                        color: theme.grey,
                        type: TButtonType.tonal,
                        text: 'Cancel',
                        onPressed: (_) => mContext.close()),
                    TButton(
                        size: TButtonSize.md.copyWith(minW: 100),
                        color: theme.primary,
                        text: 'Save',
                        onPressed: (_) {
                          final errors = input.validationErrors;
                          if (errors.isNotEmpty) {
                            for (var message in errors) {
                              TToastService.error(context, message);
                            }

                            return;
                          }

                          mContext.close(input);
                        }),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
