import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

class TTextField extends StatefulWidget with TInputFieldMixin, TInputValidationMixin<String>, TInputValueMixin<String> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? required, disabled;
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
  final String? value;
  @override
  final ValueNotifier<String>? valueNotifier;
  @override
  final ValueChanged<String>? onValueChanged;
  @override
  final Duration? validationDebounce;

  // TextField specific properties
  final int? rows;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const TTextField({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.value,
    this.required,
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
    this.valueNotifier,
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
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField> with TInputValidationStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _shouldDisposeController;
  late final bool _shouldDisposeFocusNode;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _controller = widget.controller ?? TextEditingController(text: widget.value ?? '');
    _shouldDisposeController = widget.controller == null;

    _focusNode = widget.focusNode ?? FocusNode();
    _shouldDisposeFocusNode = widget.focusNode == null;
  }

  void _setupListeners() {
    _focusNode.addListener(_onFocusChanged);
    widget.valueNotifier?.addListener(_onValueNotifierChanged);
  }

  void _onFocusChanged() {
    final wasFocused = _isFocused;
    _isFocused = _focusNode.hasFocus;

    if (wasFocused && !_isFocused) {
      triggerValidation(_controller.text);
    }

    setState(() {});
  }

  void _onValueNotifierChanged() {
    final newValue = widget.valueNotifier?.value ?? '';
    if (_controller.text != newValue) {
      _controller.text = newValue;
    }
  }

  @override
  void didUpdateWidget(covariant TTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.valueNotifier?.removeListener(_onValueNotifierChanged);

    if (_shouldDisposeController) _controller.dispose();
    if (_shouldDisposeFocusNode) _focusNode.dispose();

    disposeValidation();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.notifyValueChanged(value);
    triggerValidationWithDebounce(value);
  }

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.rows != null && widget.rows! > 1;

    return widget.buildContainer(
      isMultiline: isMultiline,
      isFocused: _isFocused,
      hasErrors: hasErrors,
      errorsNotifier: errorsNotifier,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
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
        onChanged: _onTextChanged,
      ),
    );
  }
}
