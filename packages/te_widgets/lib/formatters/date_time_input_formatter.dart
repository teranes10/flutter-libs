import 'package:flutter/services.dart';

enum TDateTimeFormatType {
  date,
  time,
  dateTime;

  String get mask {
    return switch (this) {
      TDateTimeFormatType.date => '##/##/####',
      TDateTimeFormatType.time => '##:##',
      TDateTimeFormatType.dateTime => '##/##/#### ##:##',
    };
  }

  String get placeholder {
    return switch (this) {
      TDateTimeFormatType.date => 'DD/MM/YYYY',
      TDateTimeFormatType.time => 'HH:MM',
      TDateTimeFormatType.dateTime => 'DD/MM/YYYY HH:MM',
    };
  }
}

class TDateTimeInputFormatter extends TextInputFormatter {
  final TDateTimeFormatType type;

  TDateTimeInputFormatter({required this.type});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final mask = type.mask;
    final placeholder = type.placeholder;
    String newText = newValue.text;

    // Detect if we are deleting
    bool isDeletion = oldValue.text.length > newValue.text.length;
    bool deletedDelimiter = false;

    if (isDeletion) {
      final int oldSelectionIndex = oldValue.selection.baseOffset;
      if (oldSelectionIndex > 0 && oldSelectionIndex <= oldValue.text.length) {
        final String charToRemove = oldValue.text[oldSelectionIndex - 1];
        if (charToRemove == '/' || charToRemove == ':' || charToRemove == ' ') {
          deletedDelimiter = true;
        }
      }
    }

    // Only consider digits for the actual value
    String digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > mask.replaceAll(RegExp(r'[^#]'), '').length) {
      return oldValue;
    }

    // Validate segments
    final int digitsBeforeValidation = digitsOnly.length;
    digitsOnly = _validateSegments(digitsOnly);
    final int digitsAfterValidation = digitsOnly.length;

    // Calculate how many '#' positions are before the cursor in the NEW value
    // This allows clicking anywhere and having the cursor stay in a relative position
    int hashesBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.baseOffset && i < mask.length; i++) {
      if (mask[i] == '#') {
        hashesBeforeCursor++;
      }
    }

    // Adjust for auto-prefixing
    if (digitsAfterValidation > digitsBeforeValidation) {
      hashesBeforeCursor += (digitsAfterValidation - digitsBeforeValidation);
    }

    final StringBuffer formatted = StringBuffer();
    int digitIndex = 0;
    int selectionOffset = -1;

    for (int i = 0; i < mask.length; i++) {
      // Check for selection position
      if (selectionOffset == -1 && digitIndex == hashesBeforeCursor) {
        // If we are at a delimiter and we didn't just delete it, jump over it
        if (mask[i] != '#') {
          if (isDeletion || deletedDelimiter) {
            selectionOffset = i;
          } else {
            // Forward movement: jump over delimiters
          }
        } else {
          selectionOffset = i;
        }
      }

      if (mask[i] == '#') {
        if (digitIndex < digitsOnly.length) {
          formatted.write(digitsOnly[digitIndex]);
          digitIndex++;
        } else {
          formatted.write(placeholder[i]);
          digitIndex++;
        }
      } else {
        formatted.write(mask[i]);
      }
    }

    // If selection still not found, it's at the end
    if (selectionOffset == -1) {
      selectionOffset = mask.length;
    }

    // Final check for forward delimiter jump
    // If the cursor is exactly on a delimiter and we are moving forward, jump to next #
    if (!isDeletion && selectionOffset < mask.length && mask[selectionOffset] != '#') {
      while (selectionOffset < mask.length && mask[selectionOffset] != '#') {
        selectionOffset++;
      }
    }

    final result = formatted.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: selectionOffset.clamp(0, result.length)),
    );
  }

  String _validateSegments(String digits) {
    if (digits.isEmpty) return digits;

    String result = digits;

    // Date components: DD/MM/YYYY
    if (type == TDateTimeFormatType.date || type == TDateTimeFormatType.dateTime) {
      // Day (DD)
      if (result.length >= 2) {
        int dd = int.parse(result.substring(0, 2));
        if (dd > 31) result = '31${result.substring(2)}';
        if (dd == 0 && result.length >= 2) result = '01${result.substring(2)}';
      } else if (result.length == 1) {
        int d = int.parse(result);
        if (d > 3) result = '0$d';
      }

      // Month (MM)
      if (result.length >= 4) {
        int mm = int.parse(result.substring(2, 4));
        if (mm > 12) result = '${result.substring(0, 2)}12${result.substring(4)}';
        if (mm == 0 && result.length >= 4) result = '${result.substring(0, 2)}01${result.substring(4)}';
      } else if (result.length == 3) {
        int m = int.parse(result.substring(2, 3));
        if (m > 1) result = '${result.substring(0, 2)}0$m';
      }
    }

    // Time components: HH:MM
    int timeStartIndex = (type == TDateTimeFormatType.dateTime) ? 8 : 0;
    if (type == TDateTimeFormatType.time || type == TDateTimeFormatType.dateTime) {
      if (result.length >= timeStartIndex + 1) {
        // Hour (HH)
        if (result.length >= timeStartIndex + 2) {
          int hh = int.parse(result.substring(timeStartIndex, timeStartIndex + 2));
          if (hh > 23) result = '${result.substring(0, timeStartIndex)}23${result.substring(timeStartIndex + 2)}';
        } else {
          int h = int.parse(result.substring(timeStartIndex, timeStartIndex + 1));
          if (h > 2) result = '${result.substring(0, timeStartIndex)}0$h';
        }

        // Minute (MM)
        if (result.length >= timeStartIndex + 4) {
          int min = int.parse(result.substring(timeStartIndex + 2, timeStartIndex + 4));
          if (min > 59) result = '${result.substring(0, timeStartIndex + 2)}59${result.substring(timeStartIndex + 4)}';
        } else if (result.length == timeStartIndex + 3) {
          int m = int.parse(result.substring(timeStartIndex + 2, timeStartIndex + 3));
          if (m > 5) result = '${result.substring(0, timeStartIndex + 2)}0$m';
        }
      }
    }

    return result;
  }
}
