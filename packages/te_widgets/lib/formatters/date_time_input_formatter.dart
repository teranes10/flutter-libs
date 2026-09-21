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

  /// Formats an input value (e.g. ISO string, DateTime, or raw digits) into this format.
  String format(Object? input) => TDateTimeInputFormatter.format(input, this);
}

class TDateTimeInputFormatter extends TextInputFormatter {
  final TDateTimeFormatType type;

  TDateTimeInputFormatter({required this.type});

  /// Formats an input value (ISO string, DateTime, formatted string, or raw digits) into the target format.
  static String format(Object? input, TDateTimeFormatType type) {
    if (input == null) return type.placeholder;
    if (input is DateTime) {
      final d = input.day.toString().padLeft(2, '0');
      final m = input.month.toString().padLeft(2, '0');
      final y = input.year.toString().padLeft(4, '0');
      final hh = input.hour.toString().padLeft(2, '0');
      final mm = input.minute.toString().padLeft(2, '0');
      return switch (type) {
        TDateTimeFormatType.date => '$d/$m/$y',
        TDateTimeFormatType.time => '$hh:$mm',
        TDateTimeFormatType.dateTime => '$d/$m/$y $hh:$mm',
      };
    }

    final trimmed = input.toString().trim();
    if (trimmed.isEmpty || trimmed == type.placeholder) return type.placeholder;

    switch (type) {
      case TDateTimeFormatType.date:
        return _formatDate(trimmed, type);
      case TDateTimeFormatType.time:
        return _formatTime(trimmed, type);
      case TDateTimeFormatType.dateTime:
        return _formatDateTime(trimmed, type);
    }
  }

  static String _formatDate(String input, TDateTimeFormatType type) {
    // If input is purely a time without any date component (e.g. "14:30" or "14:30:00"), return placeholder
    if (RegExp(r'^\d{1,2}:\d{1,2}(?::\d{1,2})?(?:\s*[AaPp][Mm])?$').hasMatch(input)) {
      return type.placeholder;
    }

    // 1. Try ISO / standard format (YYYY-MM-DD or YYYY/MM/DD or YYYY.MM.DD)
    final isoMatch = RegExp(r'^(\d{4})[-\/\.](\d{1,2})[-\/\.](\d{1,2})').firstMatch(input);
    if (isoMatch != null) {
      final y = isoMatch.group(1)!.padLeft(4, '0');
      final m = int.parse(isoMatch.group(2)!).clamp(1, 12).toString().padLeft(2, '0');
      final d = int.parse(isoMatch.group(3)!).clamp(1, 31).toString().padLeft(2, '0');
      return '$d/$m/$y';
    }

    // 2. Try DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
    final dmyMatch = RegExp(r'^(\d{1,2})[-\/\.](\d{1,2})[-\/\.](\d{2,4})').firstMatch(input);
    if (dmyMatch != null) {
      final d = int.parse(dmyMatch.group(1)!).clamp(1, 31).toString().padLeft(2, '0');
      final m = int.parse(dmyMatch.group(2)!).clamp(1, 12).toString().padLeft(2, '0');
      var y = dmyMatch.group(3)!;
      if (y.length == 2) {
        final currentCentury = (DateTime.now().year ~/ 100) * 100;
        y = (currentCentury + int.parse(y)).toString();
      } else {
        y = y.padLeft(4, '0');
      }
      return '$d/$m/$y';
    }

    // 3. Raw 8 digits (YYYYMMDD or DDMMYYYY)
    final pureDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (pureDigits.length == 8) {
      final first4 = int.tryParse(pureDigits.substring(0, 4)) ?? 0;
      if (first4 >= 1900 && first4 <= 2100) {
        final y = pureDigits.substring(0, 4);
        final m = int.parse(pureDigits.substring(4, 6)).clamp(1, 12).toString().padLeft(2, '0');
        final d = int.parse(pureDigits.substring(6, 8)).clamp(1, 31).toString().padLeft(2, '0');
        return '$d/$m/$y';
      } else {
        final d = int.parse(pureDigits.substring(0, 2)).clamp(1, 31).toString().padLeft(2, '0');
        final m = int.parse(pureDigits.substring(2, 4)).clamp(1, 12).toString().padLeft(2, '0');
        final y = pureDigits.substring(4, 8);
        return '$d/$m/$y';
      }
    }

    // 4. Try DateTime.tryParse (handles ISO strings like "2024-05-18T14:30:00.000Z") - ONLY if formatted
    if (input.contains('-') || input.contains('T') || input.contains(':')) {
      final dt = DateTime.tryParse(input.replaceAll('/', '-'));
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString().padLeft(4, '0');
        return '$d/$m/$y';
      }
    }

    // 5. Fallback with mask application for partial input (e.g. "18/05/YYYY", "1805", "18")
    return _applyMaskAndValidation(input, type);
  }

  static String _formatTime(String input, TDateTimeFormatType type) {
    // If input is purely a date without any time component (e.g. "2024-05-18" or "18/05/2024"), return placeholder
    if (RegExp(r'^\d{4}[-\/\.]\d{1,2}[-\/\.]\d{1,2}$').hasMatch(input) || RegExp(r'^\d{1,2}[-\/\.]\d{1,2}[-\/\.]\d{4}$').hasMatch(input)) {
      return type.placeholder;
    }

    // 1. Check for 12-hour AM/PM format (e.g. "2:30 PM", "10:15 am")
    final match12 = RegExp(r'^(\d{1,2}):(\d{1,2})(?::\d{1,2})?\s*([AaPp][Mm])$').firstMatch(input);
    if (match12 != null) {
      var h = int.parse(match12.group(1)!);
      final m = int.parse(match12.group(2)!).clamp(0, 59).toString().padLeft(2, '0');
      final ampm = match12.group(3)!.toUpperCase();
      if (ampm == 'PM' && h < 12) h += 12;
      if (ampm == 'AM' && h == 12) h = 0;
      return '${h.clamp(0, 23).toString().padLeft(2, '0')}:$m';
    }

    // 2. Check for HH:MM or HH:MM:SS (e.g. "14:30", "9:05", "14:30:00")
    final match24 = RegExp(r'(?:^|[\sT])(\d{1,2}):(\d{1,2})(?::\d{1,2})?').firstMatch(input);
    if (match24 != null) {
      final h = int.parse(match24.group(1)!).clamp(0, 23).toString().padLeft(2, '0');
      final m = int.parse(match24.group(2)!).clamp(0, 59).toString().padLeft(2, '0');
      return '$h:$m';
    }

    // 3. Full ISO string containing time (e.g. "2024-05-18T14:30:00" or "2024-05-18 14:30")
    if (input.contains(':') || input.contains('T')) {
      final dt = DateTime.tryParse(input.replaceAll('/', '-'));
      if (dt != null) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }
    }

    // 4. Raw digits: 3 or 4 digits (e.g. "930" -> "09:30", "1430" -> "14:30")
    final pureDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (pureDigits.length == 3) {
      final h = int.parse(pureDigits.substring(0, 1)).clamp(0, 23).toString().padLeft(2, '0');
      final m = int.parse(pureDigits.substring(1, 3)).clamp(0, 59).toString().padLeft(2, '0');
      return '$h:$m';
    } else if (pureDigits.length == 4) {
      final h = int.parse(pureDigits.substring(0, 2)).clamp(0, 23).toString().padLeft(2, '0');
      final m = int.parse(pureDigits.substring(2, 4)).clamp(0, 59).toString().padLeft(2, '0');
      return '$h:$m';
    }

    // 5. Fallback with mask application
    return _applyMaskAndValidation(input, type);
  }

  static String _formatDateTime(String input, TDateTimeFormatType type) {
    // 1. Try ISO or combined date and time (YYYY-MM-DD HH:MM or YYYY-MM-DDTHH:MM)
    final isoMatch = RegExp(r'^(\d{4})[-\/\.](\d{1,2})[-\/\.](\d{1,2})(?:[\sT]+(\d{1,2}):(\d{1,2})(?::\d{1,2})?)?').firstMatch(input);
    if (isoMatch != null) {
      final y = isoMatch.group(1)!.padLeft(4, '0');
      final m = int.parse(isoMatch.group(2)!).clamp(1, 12).toString().padLeft(2, '0');
      final d = int.parse(isoMatch.group(3)!).clamp(1, 31).toString().padLeft(2, '0');
      final hasTime = isoMatch.group(4) != null;
      final hh = hasTime ? int.parse(isoMatch.group(4)!).clamp(0, 23).toString().padLeft(2, '0') : 'HH';
      final mm = hasTime ? int.parse(isoMatch.group(5)!).clamp(0, 59).toString().padLeft(2, '0') : 'MM';
      return '$d/$m/$y $hh:$mm';
    }

    // 2. Regex for DD/MM/YYYY HH:MM or DD-MM-YYYY HH:MM
    final dmyMatch = RegExp(r'^(\d{1,2})[-\/\.](\d{1,2})[-\/\.](\d{2,4})(?:[\sT]+(\d{1,2}):(\d{1,2})(?::\d{1,2})?)?').firstMatch(input);
    if (dmyMatch != null) {
      final d = int.parse(dmyMatch.group(1)!).clamp(1, 31).toString().padLeft(2, '0');
      final m = int.parse(dmyMatch.group(2)!).clamp(1, 12).toString().padLeft(2, '0');
      var y = dmyMatch.group(3)!;
      if (y.length == 2) {
        final currentCentury = (DateTime.now().year ~/ 100) * 100;
        y = (currentCentury + int.parse(y)).toString();
      } else {
        y = y.padLeft(4, '0');
      }
      final hasTime = dmyMatch.group(4) != null;
      final hh = hasTime ? int.parse(dmyMatch.group(4)!).clamp(0, 23).toString().padLeft(2, '0') : 'HH';
      final mm = hasTime ? int.parse(dmyMatch.group(5)!).clamp(0, 59).toString().padLeft(2, '0') : 'MM';
      return '$d/$m/$y $hh:$mm';
    }

    // 3. Time only (e.g. "14:30")
    final timeOnlyMatch = RegExp(r'^(\d{1,2}):(\d{1,2})(?::\d{1,2})?$').firstMatch(input);
    if (timeOnlyMatch != null) {
      final hh = int.parse(timeOnlyMatch.group(1)!).clamp(0, 23).toString().padLeft(2, '0');
      final mm = int.parse(timeOnlyMatch.group(2)!).clamp(0, 59).toString().padLeft(2, '0');
      return 'DD/MM/YYYY $hh:$mm';
    }

    // 4. Raw digits: 12 digits (DDMMYYYYHHMM), 8 digits (DDMMYYYY/YYYYMMDD)
    final pureDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (pureDigits.length == 12) {
      final d = int.parse(pureDigits.substring(0, 2)).clamp(1, 31).toString().padLeft(2, '0');
      final m = int.parse(pureDigits.substring(2, 4)).clamp(1, 12).toString().padLeft(2, '0');
      final y = pureDigits.substring(4, 8);
      final hh = int.parse(pureDigits.substring(8, 10)).clamp(0, 23).toString().padLeft(2, '0');
      final mm = int.parse(pureDigits.substring(10, 12)).clamp(0, 59).toString().padLeft(2, '0');
      return '$d/$m/$y $hh:$mm';
    } else if (pureDigits.length == 8) {
      final first4 = int.tryParse(pureDigits.substring(0, 4)) ?? 0;
      if (first4 >= 1900 && first4 <= 2100) {
        final y = pureDigits.substring(0, 4);
        final m = int.parse(pureDigits.substring(4, 6)).clamp(1, 12).toString().padLeft(2, '0');
        final d = int.parse(pureDigits.substring(6, 8)).clamp(1, 31).toString().padLeft(2, '0');
        return '$d/$m/$y HH:MM';
      } else {
        final d = int.parse(pureDigits.substring(0, 2)).clamp(1, 31).toString().padLeft(2, '0');
        final m = int.parse(pureDigits.substring(2, 4)).clamp(1, 12).toString().padLeft(2, '0');
        final y = pureDigits.substring(4, 8);
        return '$d/$m/$y HH:MM';
      }
    }

    // 5. Try DateTime.tryParse (handles ISO strings) - only if formatted
    if (input.contains('-') || input.contains('T') || input.contains(':')) {
      final dt = DateTime.tryParse(input.replaceAll('/', '-'));
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString().padLeft(4, '0');
        final hasTime = input.contains(':') || input.contains('T');
        final hh = hasTime ? dt.hour.toString().padLeft(2, '0') : 'HH';
        final mm = hasTime ? dt.minute.toString().padLeft(2, '0') : 'MM';
        return '$d/$m/$y $hh:$mm';
      }
    }

    // 6. Fallback with mask application
    return _applyMaskAndValidation(input, type);
  }

  static String _applyMaskAndValidation(String input, TDateTimeFormatType type) {
    final mask = type.mask;
    final placeholder = type.placeholder;

    String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    int maxDigits = mask.replaceAll(RegExp(r'[^#]'), '').length;

    if (digitsOnly.length > maxDigits) {
      digitsOnly = digitsOnly.substring(0, maxDigits);
    }

    digitsOnly = _validateDigits(digitsOnly, type);

    final StringBuffer formatted = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < mask.length; i++) {
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

    return formatted.toString();
  }

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
    int maxDigits = mask.replaceAll(RegExp(r'[^#]'), '').length;

    if (digitsOnly.length > maxDigits) {
      digitsOnly = digitsOnly.substring(0, maxDigits);
    }

    // Validate segments
    final int digitsBeforeValidation = digitsOnly.length;
    digitsOnly = _validateDigits(digitsOnly, type);
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

  static String _validateDigits(String digits, TDateTimeFormatType type) {
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
        if (mm > 12) {
          result = '${result.substring(0, 2)}12${result.substring(4)}';
        }
        if (mm == 0 && result.length >= 4) {
          result = '${result.substring(0, 2)}01${result.substring(4)}';
        }
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
          if (hh > 23) {
            result = '${result.substring(0, timeStartIndex)}23${result.substring(timeStartIndex + 2)}';
          }
        } else {
          int h = int.parse(result.substring(timeStartIndex, timeStartIndex + 1));
          if (h > 2) result = '${result.substring(0, timeStartIndex)}0$h';
        }

        // Minute (MM)
        if (result.length >= timeStartIndex + 4) {
          int min = int.parse(result.substring(timeStartIndex + 2, timeStartIndex + 4));
          if (min > 59) {
            result = '${result.substring(0, timeStartIndex + 2)}59${result.substring(timeStartIndex + 4)}';
          }
        } else if (result.length == timeStartIndex + 3) {
          int m = int.parse(result.substring(timeStartIndex + 2, timeStartIndex + 3));
          if (m > 5) result = '${result.substring(0, timeStartIndex + 2)}0$m';
        }
      }
    }

    return result;
  }
}
