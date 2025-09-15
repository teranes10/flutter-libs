import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  final int? decimals;

  DecimalInputFormatter({this.decimals});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final regex = RegExp(r'^-?\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    if (decimals != null && newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length == 2 && parts[1].length > decimals!) {
        return oldValue;
      }
    }

    return newValue;
  }
}
