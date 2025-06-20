import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TFormService {
  static Future<T?> show<T extends TFormBase>(BuildContext context, T input) {
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
                        width: 125, color: AppColors.grey, type: TButtonType.inverse, text: 'Cancel', onPressed: (_) => mContext.close()),
                    TButton(
                        width: 100,
                        color: AppColors.primary,
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
