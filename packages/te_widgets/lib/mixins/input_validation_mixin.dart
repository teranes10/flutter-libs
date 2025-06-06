import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

mixin TInputValidationMixin<T> {
  List<String? Function(T?)>? get rules;
  List<String>? get errors;
  bool? get required;
  Duration? get validationDebounce;

  List<String> validateValue(T? value) {
    List<String> errors = [];

    if (required == true && _isValueEmpty(value)) {
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

mixin TInputValidationStateMixin<T, W extends StatefulWidget> on State<W> {
  Timer? _validationTimer;
  final ValueNotifier<List<String>> _errorsNotifier = ValueNotifier([]);

  TInputValidationMixin<T> get _validationWidget => widget as TInputValidationMixin<T>;

  ValueNotifier<List<String>> get errorsNotifier => _errorsNotifier;
  List<String> get errors => _errorsNotifier.value;
  bool get hasErrors => _errorsNotifier.value.isNotEmpty;

  void triggerValidation(T? value) {
    _validationTimer?.cancel();
    final validationErrors = _validationWidget.validateValue(value);
    _errorsNotifier.value = (_validationWidget.errors ?? []) + validationErrors;
  }

  void triggerValidationWithDebounce(T? value) {
    _validationTimer?.cancel();
    _validationTimer = Timer(
      _validationWidget.validationDebounce ?? Duration(milliseconds: 1000),
      () {
        if (mounted) {
          triggerValidation(value);
        }
      },
    );
  }

  void disposeValidation() {
    _validationTimer?.cancel();
    _errorsNotifier.dispose();
  }
}
