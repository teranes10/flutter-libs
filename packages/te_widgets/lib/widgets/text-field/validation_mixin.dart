import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

mixin TValidationMixin<T> {
  List<String Function(T?)>? get rules;
  bool? get required;

  List<String> validate(T? value) {
    List<String> errors = [];

    // Check required validation
    if (required == true && _isValueEmpty(value)) {
      errors.add('This field is required');
      return errors;
    }

    // Skip other validations if value is empty and not required
    if (_isValueEmpty(value)) return errors;

    // Apply custom rules
    if (rules != null) {
      errors.addAll(rules!.map((rule) => rule(value)).where((error) => error.isNotEmpty));
    }

    return errors;
  }

  bool _isValueEmpty(T? value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    return false;
  }

  Widget buildErrors(List<String> errors) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors
            .map((e) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('• $e', style: TextStyle(fontSize: 12.0, color: AppColors.danger)),
                ))
            .toList(),
      ),
    );
  }
}
