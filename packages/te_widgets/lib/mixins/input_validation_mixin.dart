import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';

mixin TInputValidationMixin<T> on TInputValueMixin<T>, TFocusMixin {
  List<String? Function(T?)>? get rules;
  List<String>? get errors;
  bool? get isRequired;
  Duration? get validationDebounce;
  bool? get skipValidation;

  List<String> validateValue(T? value) {
    List<String> errors = [];

    if (isRequired == true && _isValueEmpty(value)) {
      errors.add('This field is required');
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
  void onValueChanged(value) {
    _triggerValidationWithDebounce(value);
    super.onValueChanged(value);
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _errorsNotifier.dispose();
    super.dispose();
  }
}
