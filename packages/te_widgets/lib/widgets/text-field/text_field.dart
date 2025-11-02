import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTextField extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<String>, TInputValidationMixin<String> {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final String? value;
  @override
  final ValueNotifier<String?>? valueNotifier;
  @override
  final ValueChanged<String?>? onValueChanged;
  @override
  final List<String? Function(String?)>? rules;
  @override
  final Duration? validationDebounce;

  final int rows;

  const TTextField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.rows = 1,
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField>
    with
        TInputFieldStateMixin<TTextField>,
        TFocusStateMixin<TTextField>,
        TTextFieldStateMixin<TTextField>,
        TInputValueStateMixin<String, TTextField>,
        TInputValidationStateMixin<String, TTextField> {
  @override
  void onExternalValueChanged(String? value) {
    super.onExternalValueChanged(value);
    if (textController.text != value) {
      textController.value = textController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value?.length ?? 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(
      isMultiline: widget.rows > 1,
      child: buildTextField(
        maxLines: widget.rows,
        onValueChanged: notifyValueChanged,
      ),
    );
  }
}
