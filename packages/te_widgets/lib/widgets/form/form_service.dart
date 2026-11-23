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
  static Future<T?> show<T extends TFormBase>(
    BuildContext context,
    T input, {
    bool? persistent,
    bool? showCloseButton,
    double? width,
    bool showFormTypeToggle = true,
  }) {
    final hasSubForms = input.hasSubForms;
    ValueNotifier<TFormType>? formTypeNotifier;
    List<Widget>? modalActions;

    if (hasSubForms && showFormTypeToggle) {
      final initialType = TFormTypePersistence.getInitialType(context, input);
      formTypeNotifier = ValueNotifier<TFormType>(initialType);
      TFormTypePersistence.loadPersistedType(context, input, formTypeNotifier);

      modalActions = [
        TFormTypeToggleSwitch(
          notifier: formTypeNotifier,
          types: input.availableFormTypes,
          onChanged: (newType) {
            TFormTypePersistence.saveType(context, input, newType);
          },
        ),
      ];
    }

    return TModalService.showAdaptive<T>(
      context,
      title: input.formTitle,
      persistent: persistent ?? input.isFormPersistent,
      showCloseButton: showCloseButton ?? input.isFormCloseButton,
      width: width ?? input.formWidth,
      actions: context.isMobile ? [] : modalActions,
      (mContext) {
        final content = _TFormContent<T>(
          input: input,
          padding: EdgeInsets.all(0),
          topSpacing: 12,
          onClose: (result) => mContext.close(result),
        );

        if (formTypeNotifier != null) {
          return TFormTypeScope(
            formTypeNotifier: formTypeNotifier,
            child: content,
          );
        }

        return content;
      },
    );
  }
}

class _TFormContent<T extends TFormBase> extends StatefulWidget {
  final T input;
  final void Function(T? result) onClose;
  final EdgeInsets padding;
  final double topSpacing;

  const _TFormContent({
    required this.input,
    required this.onClose,
    required this.padding,
    required this.topSpacing,
  });

  @override
  State<_TFormContent<T>> createState() => _TFormContentState<T>();
}

class _TFormContentState<T extends TFormBase> extends State<_TFormContent<T>> {
  final _formController = TFormController();
  bool _isLoading = false;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final shouldSave = await widget.input.onSave(context);
      if (shouldSave && mounted) {
        widget.onClose(widget.input);
      }
    } catch (e) {
      if (mounted) {
        TToastService.error(context, null, null, TError.from(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = TFormBuilder(input: widget.input, controller: _formController);
    final formWidget = context.isMobilePlatform
        ? InteractiveViewer(
            scaleEnabled: true,
            panEnabled: true,
            minScale: 1.0,
            maxScale: 1.3,
            child: form,
          )
        : form;

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          formWidget,
          Padding(
            padding: EdgeInsets.only(top: widget.topSpacing),
            child: TFormActions(
              controller: _formController,
              form: widget.input,
              loading: _isLoading,
              onCancel: () => widget.onClose(null),
              onSave: _handleSave,
            ),
          )
        ],
      ),
    );
  }
}

/// Footer actions for a [TFormBuilder] driven by [controller].
///
/// - Single-section and accordion forms: **Cancel** · **Save**.
/// - Tabs and steppers: **Cancel** · **Back** · **Next** until the last
///   section, where **Next** becomes **Save**. On a stepper, Next refuses to
///   leave a step with errors.
///
/// Save validates [form] first; when invalid it shows one toast, flags the
/// sections with errors, opens the first one and scrolls to the first
/// invalid field. [onSave] only runs for a valid form.
class TFormActions extends StatelessWidget {
  /// Controller attached to the form's [TFormBuilder].
  final TFormController controller;

  /// Form validated before [onSave] runs.
  final TFormBase form;

  /// Called when Cancel is pressed.
  final VoidCallback onCancel;

  /// Called when Save is pressed and [form] is valid.
  final Future<void> Function() onSave;

  /// Shows a spinner on the Save button.
  final bool loading;

  final String cancelText;
  final String backText;
  final String nextText;
  final String saveText;

  const TFormActions({
    super.key,
    required this.controller,
    required this.form,
    required this.onCancel,
    required this.onSave,
    this.loading = false,
    this.cancelText = 'Cancel',
    this.backText = 'Back',
    this.nextText = 'Next',
    this.saveText = 'Save',
  });

  Future<void> _save(BuildContext context) async {
    final errors = form.validationErrors;
    if (errors.isNotEmpty) {
      TToastService.error(context, errors.first, errors.length > 1 ? 'Please fix ${errors.length} errors' : null);
      await controller.revealErrors();
      return;
    }
    await onSave();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glass = TGlassStyle.resolve(context);
    // Glass: a frosted button with a visible edge instead of an opaque surface block.
    final surfaceTheme = glass == null
        ? TWidgetTheme.surfaceTheme(colors)
        : TWidgetTheme.surfaceTheme(colors).copyWith(
            container: Colors.white.withAlpha(colors.isDarkMode ? 24 : 150),
            containerVariant: Colors.white.withAlpha(colors.isDarkMode ? 45 : 200),
            outline: glass.fieldEdge(context),
            outlineVariant: glass.fieldEdge(context),
          );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          TButton(
            baseTheme: surfaceTheme,
            size: TButtonSize.md.copyWith(minW: controller.canGoBack ? null : 125),
            text: cancelText,
            onPressed: (_) => onCancel(),
          ),
          if (controller.canGoBack)
            TButton(
              baseTheme: surfaceTheme,
              size: TButtonSize.md,
              icon: HugeIcons.strokeRoundedArrowLeft01,
              text: backText,
              onPressed: (_) => controller.back(),
            ),
          if (controller.isLast)
            TButton(
              size: TButtonSize.md.copyWith(minW: 100),
              color: context.theme.primary,
              text: saveText,
              loading: loading,
              onPressed: (_) => _save(context),
            )
          else
            TButton(
              size: TButtonSize.md.copyWith(minW: 100),
              color: context.theme.primary,
              text: nextText,
              onPressed: (_) => controller.next(),
            ),
        ],
      ),
    );
  }
}
