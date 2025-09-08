import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TInputValidationMixin<T> on TInputValueMixin<T>, TFocusMixin {
  String? get label;
  bool get isRequired;
  List<String? Function(T?)>? get rules;
  List<String>? get errors;
  Duration? get validationDebounce;
  bool? get skipValidation;

  List<String> validateValue(T? value) {
    List<String> errors = [];

    if (isRequired == true && _isValueEmpty(value)) {
      errors.add('$label is required');
      return errors;
    }

    if (_isValueEmpty(value)) return errors;

    if (rules != null) {
      final newErrors = rules!.map((rule) => rule(value)).where((error) => error != null && error.isNotEmpty).cast<String>().toList();
      errors.addAll(newErrors);
    }

    return errors;
  }

  bool _isValueEmpty(T? value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}

mixin TInputValidationStateMixin<T, W extends StatefulWidget> on State<W>, TInputValueStateMixin<T, W>, TFocusStateMixin<W> {
  Timer? _validationTimer;
  final ValueNotifier<List<String>> _errorsNotifier = ValueNotifier([]);

  TInputValidationMixin<T> get _widget => widget as TInputValidationMixin<T>;

  ValueNotifier<List<String>> get errorsNotifier => _errorsNotifier;
  List<String> get errors => _errorsNotifier.value;
  bool get hasErrors => _errorsNotifier.value.isNotEmpty;
  bool get isNeedToValidate => _widget.skipValidation != true && (_widget.isRequired == true || _widget.rules?.isNotEmpty == true);

  void triggerValidation(T? value) {
    if (!isNeedToValidate) return;

    _validationTimer?.cancel();
    final validationErrors = _widget.validateValue(value);
    _errorsNotifier.value = (_widget.errors ?? []) + validationErrors;
    setState(() {});
  }

  void _triggerValidationWithDebounce(T? value) {
    if (!isNeedToValidate) return;

    _validationTimer?.cancel();
    _validationTimer = Timer(
      _widget.validationDebounce ?? Duration(milliseconds: 1500),
      () {
        if (mounted) {
          triggerValidation(value);
        }
      },
    );
  }

  @override
  void onFocusChanged(bool hasFocus) {
    if (!hasFocus) {
      triggerValidation(currentValue);
    }
    setState(() {});
  }

  @override
  void onValueChanged(value, {bool initial = false}) {
    super.onValueChanged(value);

    if (!initial) {
      _triggerValidationWithDebounce(value);
    }
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _errorsNotifier.dispose();
    super.dispose();
  }

  Widget buildValidationErrors(ColorScheme theme, ValueNotifier<List<String>> errorsNotifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: errorsNotifier,
      builder: (context, validationErrors, child) {
        if (validationErrors.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: validationErrors.map((error) => Text('• $error', style: TextStyle(fontSize: 12.0, color: theme.error))).toList(),
          ),
        );
      },
    );
  }
}
