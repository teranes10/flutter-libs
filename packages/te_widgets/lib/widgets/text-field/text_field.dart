import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

class TTextField extends StatefulWidget with TInputFieldMixin, TInputValueMixin<String>, TFocusMixin, TInputValidationMixin<String> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final TInputColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(String?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final String? value;
  @override
  final ValueNotifier<String>? valueNotifier;
  @override
  final ValueChanged<String>? onValueChanged;
  @override
  final FocusNode? focusNode;

  // TextField specific properties
  final int? rows;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final void Function()? onTap;
  final bool? readOnly;

  const TTextField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.value,
    this.isRequired,
    this.disabled,
    this.rows,
    this.size = TInputSize.md,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.inputFormatters,
    this.rules,
    this.controller,
    this.focusNode,
    this.errors,
    this.onValueChanged,
    this.validationDebounce,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.maxLengthEnforcement,
    this.obscureText = false,
    this.textInputAction,
    this.valueNotifier,
    this.skipValidation,
    this.onTap,
    this.readOnly,
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField>
    with TInputValueStateMixin<String, TTextField>, TFocusStateMixin<TTextField>, TInputValidationStateMixin<String, TTextField> {
  late final TextEditingController _controller;
  late final bool _shouldDisposeController;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController(text: widget.value ?? '');
    _shouldDisposeController = widget.controller == null;
    super.initState();
  }

  @override
  void dispose() {
    if (_shouldDisposeController) _controller.dispose();
    super.dispose();
  }

  @override
  void onExternalValueChanged(String value) {
    super.onExternalValueChanged(value);
    if (_controller.text != value) {
      _controller.value = _controller.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.rows != null && widget.rows! > 1;

    return widget.buildContainer(
      isMultiline: isMultiline,
      isFocused: isFocused,
      hasErrors: hasErrors,
      errorsNotifier: errorsNotifier,
      child: TextField(
        controller: _controller,
        focusNode: focusNode,
        enabled: widget.disabled != true,
        maxLines: isMultiline ? widget.rows : 1,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText,
        textInputAction: widget.textInputAction ?? (isMultiline ? TextInputAction.newline : TextInputAction.next),
        cursorHeight: widget.fontSize + 2,
        textAlignVertical: isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
        style: widget.getTextStyle(),
        decoration: widget.getInputDecoration(),
        onChanged: notifyValueChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly == true,
      ),
    );
  }
}
