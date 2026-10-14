import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A text input field with validation, theming, and advanced features.
///
/// `TTextField` provides a fully-featured text input with support for:
/// - Single-line and multi-line input
/// - Validation rules with debouncing
/// - Required field indicators
/// - Helper text and placeholders
/// - Disabled and read-only states
/// - Custom theming
/// - Value binding with ValueNotifier
///
/// ## Basic Usage
///
/// ```dart
/// TTextField(
///   label: 'Email',
///   placeholder: 'Enter your email',
///   isRequired: true,
///   rules: [
///     Validations.required('Email is required'),
///     Validations.email('Invalid email format'),
///   ],
///   onValueChanged: (value) => print('Email: $value'),
/// )
/// ```
///
/// ## Multi-line Text Area
///
/// ```dart
/// TTextField(
///   label: 'Description',
///   rows: 5,
///   placeholder: 'Enter description...',
/// )
/// ```
///
/// ## With Value Notifier
///
/// ```dart
/// final emailNotifier = ValueNotifier<String?>('');
///
/// TTextField(
///   label: 'Email',
///   valueNotifier: emailNotifier,
/// )
/// ```
///
/// See also:
/// - [TTextFieldTheme] for customizing appearance
/// - [Validations] for built-in validation rules
class TTextField<T extends String?> extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<T>, TInputValidationMixin<T> {
  /// The label text displayed above the field.
  @override
  final String? label;

  /// An optional tag displayed next to the label.
  @override
  final String? tag;

  /// Helper text displayed below the field.
  @override
  final String? helperText;

  /// The info text (optional).
  @override
  final String? info;

  /// Placeholder text shown when the field is empty.
  @override
  final String? placeholder;

  /// Whether this field is required.
  ///
  /// When true, displays a required indicator (*) next to the label.
  /// Defaults to false.
  @override
  final bool isRequired;

  /// Whether the field is disabled.
  ///
  /// When true, the field cannot be edited and appears grayed out.
  /// Defaults to false.
  @override
  final bool disabled;

  /// Whether the field should auto-focus when the widget is built.
  ///
  /// Defaults to false.
  @override
  final bool autoFocus;

  /// Whether the field is read-only.
  ///
  /// When true, the field displays its value but cannot be edited.
  /// Defaults to false.
  @override
  final bool readOnly;

  /// Whether to show a clear button when the field has a value.
  ///
  /// Defaults to false.
  @override
  final bool clearable;

  /// Custom theme for this text field.
  @override
  final TTextFieldTheme? theme;

  /// Custom pre-widget.
  final Widget? preWidget;

  /// Custom post-widget.
  final Widget? postWidget;

  /// The size of the text field.
  final TInputSize? size;

  /// The decoration type of the text field.
  final TInputDecorationType? decorationType;

  /// Callback fired when the field is tapped.
  @override
  final VoidCallback? onTap;

  /// Custom focus node for managing focus state.
  @override
  final FocusNode? focusNode;

  /// Custom text editing controller.
  ///
  /// If not provided, an internal controller will be created.
  @override
  final TextEditingController? textController;

  /// The initial value of the field.
  @override
  final T? value;

  /// A ValueNotifier for two-way binding with the field's value.
  @override
  final ValueNotifier<T?>? valueNotifier;

  /// Callback fired when the field's value changes.
  @override
  final ValueChanged<T?>? onValueChanged;

  /// Validation rules to apply to the field's value.
  ///
  /// Each rule is a function that returns an error message string if validation
  /// fails, or null if validation passes.
  @override
  final List<String? Function(T?)>? rules;

  /// Debounce duration for validation.
  ///
  /// Validation will be delayed by this duration after the user stops typing.
  @override
  final Duration? validationDebounce;

  /// The number of rows for multi-line input.
  ///
  /// When greater than 1, the field becomes a text area.
  /// Defaults to 1 (single-line).
  final int rows;

  /// Whether to obscure the text (e.g. for passwords).
  ///
  /// Defaults to false.
  final bool obscureText;

  final TLabelPosition? labelPosition;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// Optional input formatters to apply.
  final List<TextInputFormatter>? inputFormatters;

  /// The keyboard action button. Defaults to `next` (single line) / `newline`.
  final TextInputAction? textInputAction;

  /// Called when the user submits the field (keyboard action or the Enter key
  /// sent by a hardware / keyboard-wedge barcode scanner).
  final ValueChanged<String>? onSubmitted;

  /// Selects the whole text when the field gains focus, so a new scan or
  /// typed value replaces the old one.
  final bool selectAllOnFocus;

  /// Clears the field after [onSubmitted] fires (scan-and-go fields).
  final bool clearOnSubmit;

  /// Re-requests focus after [onSubmitted] so the next scan is captured
  /// without the operator touching the screen.
  final bool keepFocusOnSubmit;

  /// Creates a scan-first input for handheld workflows.
  ///
  /// A hardware (keyboard-wedge) scanner types the barcode and sends Enter;
  /// that fires [onScan] with the scanned text, clears the field and keeps
  /// focus ready for the next scan. [onCameraTap] adds a camera scan button.
  factory TTextField.scan({
    Key? key,
    String? label,
    String? placeholder = 'Scan or type',
    required ValueChanged<String> onScan,
    VoidCallback? onCameraTap,
    TInputSize? size,
    bool autoFocus = true,
    bool disabled = false,
    String? helperText,
    FocusNode? focusNode,
    TextEditingController? textController,
  }) {
    return TTextField<T>(
      key: key,
      label: label,
      placeholder: placeholder,
      helperText: helperText,
      size: size,
      autoFocus: autoFocus,
      disabled: disabled,
      focusNode: focusNode,
      textController: textController,
      textInputAction: TextInputAction.done,
      selectAllOnFocus: true,
      clearOnSubmit: true,
      keepFocusOnSubmit: true,
      postWidget: onCameraTap == null
          ? null
          : IconButton(
              tooltip: 'Scan with camera',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: disabled ? null : onCameraTap,
            ),
      onSubmitted: (text) {
        final trimmed = text.trim();
        if (trimmed.isNotEmpty) onScan(trimmed);
      },
    );
  }

  /// Creates a text input field.
  const TTextField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.info,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.clearable = false,
    this.obscureText = false,
    this.theme,
    this.preWidget,
    this.postWidget,
    this.size,
    this.decorationType,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.rows = 1,
    this.labelPosition,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
    this.selectAllOnFocus = false,
    this.clearOnSubmit = false,
    this.keepFocusOnSubmit = false,
  })  : assert(
          theme == null ||
              (preWidget == null &&
                  postWidget == null &&
                  size == null &&
                  decorationType == null &&
                  obscureText == false &&
                  labelPosition == null),
          'Cannot provide both theme and individual theme properties.',
        ),
        assert(
          !obscureText || rows == 1,
          'Obscured fields cannot be multiline.',
        );

  @override
  State<TTextField<T>> createState() => _TTextFieldState<T>();
}

class _TTextFieldState<T extends String?> extends State<TTextField<T>>
    with
        TInputFieldStateMixin<TTextField<T>>,
        TFocusStateMixin<TTextField<T>>,
        TTextFieldStateMixin<TTextField<T>>,
        TInputValueStateMixin<T, TTextField<T>>,
        TInputValidationStateMixin<T, TTextField<T>> {
  @override
  TTextFieldTheme get wTheme {
    if (widget.theme != null) return widget.theme!;

    return context.theme.textFieldTheme.copyWith(
      preWidget: widget.preWidget,
      postWidget: widget.postWidget,
      size: widget.size,
      decorationType: widget.decorationType,
      obscureText: widget.obscureText,
      labelPosition: widget.labelPosition,
    );
  }

  @override
  TextEditingController buildTextController() {
    return TextEditingController(text: widget.value);
  }

  @override
  void onExternalValueChanged(T? value) {
    super.onExternalValueChanged(value);
    if (textController.text != value) {
      textController.value = textController.value.copyWith(
        text: value ?? '',
        selection: TextSelection.collapsed(offset: value?.length ?? 0),
      );
    }
  }

  void _onValueChanged(String text) {
    final value = (text.isEmpty && null is! T) ? '' as T : (text.isEmpty ? null : text) as T;
    notifyValueChanged(value);
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);
    if (hasFocus && widget.selectAllOnFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !focusNode.hasFocus) return;
        textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
      });
    }
  }

  void _onSubmitted(String text) {
    widget.onSubmitted?.call(text);
    if (widget.clearOnSubmit) {
      textController.clear();
      _onValueChanged('');
    }
    if (widget.keepFocusOnSubmit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildTextField(
      rows: widget.rows,
      onValueChanged: _onValueChanged,
      hasValue: textController.text.isNotEmpty,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onSubmitted: widget.onSubmitted == null && !widget.clearOnSubmit && !widget.keepFocusOnSubmit ? null : _onSubmitted,
      onClear: () {
        textController.clear();
        _onValueChanged('');
      },
    );
  }
}
