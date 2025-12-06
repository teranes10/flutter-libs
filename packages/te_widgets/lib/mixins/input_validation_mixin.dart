import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Mixin for input validation logic.
mixin TInputValidationMixin<T> on TInputValueMixin<T>, TFocusMixin {
  /// The label used in error messages.
  String? get label;

  /// Whether the input is required.
  bool get isRequired;

  /// List of validation rules.
  List<String? Function(T?)>? get rules;

  /// Debounce duration for validation trigger.
  Duration? get validationDebounce;

  /// Validates the given value against the rules.
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

/// State mixin for managing validation state.
mixin TInputValidationStateMixin<T, W extends StatefulWidget> on State<W>, TInputValueStateMixin<T, W>, TFocusStateMixin<W> {
  Timer? _validationTimer;
  final ValueNotifier<List<String>> _errorsNotifier = ValueNotifier([]);

  TInputValidationMixin<T> get _widget => widget as TInputValidationMixin<T>;

  /// Notifier for the list of validation errors.
  ValueNotifier<List<String>> get errorsNotifier => _errorsNotifier;

  /// Current validation errors.
  List<String> get errors => _errorsNotifier.value;

  /// Whether there are any validation errors.
  bool get hasErrors => _errorsNotifier.value.isNotEmpty;

  /// Whether validation is required for this field.
  bool get isNeedToValidate => _widget.isRequired == true || _widget.rules?.isNotEmpty == true;

  /// Triggers validation immediately.
  void triggerValidation(T? value) {
    if (!isNeedToValidate) return;

    _validationTimer?.cancel();
    final validationErrors = _widget.validateValue(value);
    _errorsNotifier.value = validationErrors;
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
}
