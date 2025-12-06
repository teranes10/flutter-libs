import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A service for displaying form modals with validation.
///
/// `TFormService` provides modal dialogs for forms with:
/// - Automatic form layout
/// - Built-in validation
/// - Save/Cancel actions
/// - Mobile-friendly with zoom support
/// - Integration with TFormBase
///
/// ## Usage Example
///
/// ```dart
/// class UserForm extends TFormBase {
///   final name = TFieldProp<String>('');
///   final email = TFieldProp<String>('');
///
///   @override
///   List<TFormField> get fields => [
///     TFormField.text(name, 'Name', isRequired: true),
///     TFormField.text(email, 'Email', isRequired: true),
///   ];
///
///   @override
///   String get formTitle => 'Edit User';
/// }
///
/// final result = await TFormService.show(context, UserForm());
/// if (result != null) {
///   // Form was saved
///   print('Name: ${result.name.value}');
/// }
/// ```
///
/// See also:
/// - [TFormBase] for form models
/// - [TModalService] for generic modals
class TFormService {
  /// Shows a form in a modal dialog.
  ///
  /// Returns the form instance if saved, null if cancelled.
  static Future<T?> show<T extends TFormBase>(BuildContext context, T input) {
    final theme = context.theme;

    return TModalService.show<T>(
      context,
      persistent: input.isFormPersistent,
      showCloseButton: input.isFormCloseButton,
      width: input.formWidth,
      title: input.formTitle,
      (mContext) {
        final isMobile = context.isMobile;
        return Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isMobile
                  ? InteractiveViewer(
                      scaleEnabled: true,
                      panEnabled: true,
                      minScale: 1.0,
                      maxScale: 1.3,
                      child: TFormBuilder(input: input),
                    )
                  : TFormBuilder(input: input),
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 20 : 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5,
                  children: [
                    TButton(
                        baseTheme: TWidgetTheme.surfaceTheme(context.colors),
                        size: TButtonSize.md.copyWith(minW: 125),
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
