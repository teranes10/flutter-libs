import 'package:flutter/services.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  final String format;

  PhoneNumberInputFormatter({required this.format});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Remove leading zero if present (common when switching from local to international)
    if (text.startsWith('0') && text.length > 1) {
      text = text.substring(1);
    }

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final newText = _formatPhoneNumber(text);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatPhoneNumber(String text) {
    final buffer = StringBuffer();
    int textIndex = 0;

    for (int i = 0; i < format.length && textIndex < text.length; i++) {
      if (format[i] == '0') {
        buffer.write(text[textIndex]);
        textIndex++;
      } else {
        buffer.write(format[i]);
      }
    }

    return buffer.toString();
  }
}
