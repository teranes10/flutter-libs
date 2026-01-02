import 'package:flutter/material.dart';
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
class TTextField extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<String>, TInputValidationMixin<String> {
  /// The label text displayed above the field.
  @override
  final String? label;

  /// An optional tag displayed next to the label.
  @override
  final String? tag;

  /// Helper text displayed below the field.
  @override
  final String? helperText;

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
  final String? value;

  /// A ValueNotifier for two-way binding with the field's value.
  @override
  final ValueNotifier<String?>? valueNotifier;

  /// Callback fired when the field's value changes.
  @override
  final ValueChanged<String?>? onValueChanged;

  /// Validation rules to apply to the field's value.
  ///
  /// Each rule is a function that returns an error message string if validation
  /// fails, or null if validation passes.
  @override
  final List<String? Function(String?)>? rules;

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

  /// Creates a text input field.
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
    this.clearable = false,
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
  void onValueChanged(String? value, {bool initial = false, String? oldValue}) {
    super.onValueChanged(value, initial: initial, oldValue: oldValue);

    final wasEmpty = (oldValue?.isEmpty ?? true);
    final isEmpty = (value?.isEmpty ?? true);

    if (wasEmpty != isEmpty) {
      setState(() {});
    }
  }

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
      showClearButton: textController.text.isNotEmpty,
      onClear: () {
        textController.clear();
        notifyValueChanged('');
      },
      child: buildTextField(
        maxLines: widget.rows,
        onValueChanged: notifyValueChanged,
      ),
    );
  }
}
