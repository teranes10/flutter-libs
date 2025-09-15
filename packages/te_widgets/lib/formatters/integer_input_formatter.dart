import 'package:flutter/services.dart';

class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final regex = RegExp(r'^-?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}
