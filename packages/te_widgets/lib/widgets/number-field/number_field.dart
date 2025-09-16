import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TNumberField<T extends num> extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<T>, TInputValidationMixin<T> {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TNumberFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final T? value;
  @override
  final ValueNotifier<T>? valueNotifier;
  @override
  final ValueChanged<T>? onValueChanged;
  @override
  final List<String? Function(T?)>? rules;
  @override
  final Duration? validationDebounce;

  const TNumberField({
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
  });

  @override
  State<TNumberField<T>> createState() => _TNumberFieldState<T>();
}

class _TNumberFieldState<T extends num> extends State<TNumberField<T>>
    with
        TInputFieldStateMixin<TNumberField<T>>,
        TFocusStateMixin<TNumberField<T>>,
        TTextFieldStateMixin<TNumberField<T>>,
        TInputValueStateMixin<T, TNumberField<T>>,
        TInputValidationStateMixin<T, TNumberField<T>> {
  @override
  TNumberFieldTheme get wTheme => widget.theme ?? context.theme.numberFieldTheme;
  @override
  void onExternalValueChanged(T? value) {
    super.onExternalValueChanged(value);
    controller.text = wTheme.formatValue(value);
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (T != double) return;

    if (hasFocus) {
      controller.text = currentValue?.toString() ?? '';
    } else if (wTheme.decimals != null) {
      controller.text = currentValue?.toStringAsFixed(wTheme.decimals!) ?? '';
    }
  }

  void _onValueChanged(String text) {
    final parsedValue = wTheme.parseValue(text);
    notifyValueChanged(parsedValue);
  }

  void _changeValueBy(num delta) {
    final base = currentValue ?? (T == int ? 0 : 0.0) as T;
    final newValue = T == int ? (base.toInt() + delta.toInt()) as T : (base.toDouble() + delta.toDouble()) as T;

    controller.text = wTheme.formatValue(newValue);
    notifyValueChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final type = getValueType().type;
    final disabled = widget.disabled;

    return buildContainer(
      postWidget: wTheme.buildSteppers(context, colors, !disabled, !disabled, _changeValueBy),
      child: buildTextField(
        keyboardType: wTheme.getKeyboardType(type),
        inputFormatters: wTheme.getInputFormatters(type, wTheme.decimals),
        onValueChanged: _onValueChanged,
      ),
    );
  }
}
