import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A text field specifically for Date, Time, or DateTime input with automatic formatting.
///
/// `TDateTimeTextField` provides:
/// - Masked input (e.g., DD/MM/YYYY)
/// - Automatic insertion of separators (slashes, colons, spaces)
/// - Digit-only filtering
/// - Dynamic placeholder based on format
/// - Integrated icons based on type
///
/// ## Basic Usage
///
/// ```dart
/// TDateTimeTextField(
///   label: 'Birth Date',
///   formatType: TDateTimeFormatType.date,
///   onValueChanged: (value) => print('Date: $value'),
/// )
/// ```
///
/// ## Time Input
///
/// ```dart
/// TDateTimeTextField(
///   label: 'Start Time',
///   formatType: TDateTimeFormatType.time,
/// )
/// ```
class TDateTimeTextField<T extends String?> extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<T>, TInputValidationMixin<T> {
  @override
  final String? label, tag, helperText, placeholder, info;
  @override
  final bool isRequired, disabled, autoFocus, readOnly, clearable;
  @override
  final TTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final T? value;
  @override
  final ValueNotifier<T?>? valueNotifier;
  @override
  final ValueChanged<T?>? onValueChanged;
  @override
  final List<String? Function(T?)>? rules;
  @override
  final Duration? validationDebounce;

  /// The format type (date, time, or dateTime).
  final TDateTimeFormatType formatType;

  /// Creates a formatted date/time text field.
  const TDateTimeTextField({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.info,
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
    this.formatType = TDateTimeFormatType.date,
  });

  @override
  State<TDateTimeTextField<T>> createState() => _TDateTimeTextFieldState<T>();
}

class _TDateTimeTextFieldState<T extends String?> extends State<TDateTimeTextField<T>>
    with
        TInputFieldStateMixin<TDateTimeTextField<T>>,
        TFocusStateMixin<TDateTimeTextField<T>>,
        TTextFieldStateMixin<TDateTimeTextField<T>>,
        TInputValueStateMixin<T, TDateTimeTextField<T>>,
        TInputValidationStateMixin<T, TDateTimeTextField<T>> {
  @override
  void onExternalValueChanged(T? value) {
    super.onExternalValueChanged(value);
    final effectiveValue = (value == null || value.isEmpty) ? widget.formatType.placeholder : value;
    if (textController.text != effectiveValue) {
      textController.text = effectiveValue;
    }
  }

  @override
  TextEditingController buildTextController() {
    return _TDateTimeEditingController(
      formatType: widget.formatType,
      text: widget.value ?? widget.formatType.placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildTextField(
      keyboardType: TextInputType.number,
      inputFormatters: [TDateTimeInputFormatter(type: widget.formatType)],
      onValueChanged: (v) {
        // If the value is just the placeholder, treat it as empty
        if (v == widget.formatType.placeholder) {
          notifyValueChanged((null is T ? null : '') as T);
        } else {
          notifyValueChanged(v as T);
        }
      },
      hasValue: textController.text.isNotEmpty && textController.text != widget.formatType.placeholder,
      placeholder: placeholder,
      onTap: () {
        if (textController.text == widget.formatType.placeholder) {
          textController.selection = const TextSelection.collapsed(offset: 0);
        }
      },
      onClear: () {
        textController.text = widget.formatType.placeholder;
        notifyValueChanged((null is T ? null : '') as T);
      },
      beforePreWidget: Icon(
        widget.formatType == TDateTimeFormatType.time ? Icons.access_time : Icons.calendar_today,
        size: 16,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  String? get placeholder => widget.placeholder ?? widget.formatType.placeholder;
}

class _TDateTimeEditingController extends TextEditingController {
  final TDateTimeFormatType formatType;

  _TDateTimeEditingController({
    required this.formatType,
    super.text,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final String text = this.text;
    final String mask = formatType.mask;
    final String placeholder = formatType.placeholder;

    for (int i = 0; i < text.length; i++) {
      if (i >= placeholder.length) {
        children.add(TextSpan(text: text[i], style: style));
        continue;
      }

      final char = text[i];
      final isPlaceholder = char == placeholder[i];
      final isDelimiter = i < mask.length && mask[i] != '#';

      if (isPlaceholder && !isDelimiter) {
        children.add(TextSpan(
          text: char,
          style: style?.copyWith(
            color: style.color?.o(0.35),
            fontWeight: FontWeight.w300,
          ),
        ));
      } else {
        children.add(TextSpan(text: char, style: style));
      }
    }

    return TextSpan(style: style, children: children);
  }
}
