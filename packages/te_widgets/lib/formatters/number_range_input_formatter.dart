import 'package:flutter/services.dart';

/// A [TextInputFormatter] that constrains user input within an optional
/// numeric range [min] and [max].
///
/// Immediately blocks characters that would cause the input to exceed [max],
/// blocks negative signs (`-`) when [min] >= 0, and blocks negative values
/// that exceed negative [min] bounds.
class NumberRangeInputFormatter extends TextInputFormatter {
  /// The minimum allowed value. If >= 0, typing '-' is blocked immediately.
  final num? min;

  /// The maximum allowed value. Any character making the number exceed [max]
  /// is blocked immediately.
  final num? max;

  /// Whether the input represents an integer.
  final bool isInt;

  NumberRangeInputFormatter({
    this.min,
    this.max,
    this.isInt = false,
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (min == null && max == null) return newValue;

    final text = newValue.text.trim();
    if (text.isEmpty) return newValue;

    // Disallow negative sign if min >= 0
    if (min != null && min! >= 0 && text.startsWith('-')) {
      return oldValue;
    }

    // Allow typing leading '-' if min allows negative numbers or is unconstrained
    if (text == '-') {
      return (min == null || min! < 0) ? newValue : oldValue;
    }

    // Allow intermediate decimal dot while typing floating numbers
    if (!isInt && (text.endsWith('.') || text == '-.')) {
      final prefix = text.substring(0, text.length - 1);
      if (prefix.isEmpty || prefix == '-') return newValue;
      final prefixVal = parseNormalized(prefix);
      if (prefixVal != null && max != null && prefixVal > max!) {
        return oldValue;
      }
      return newValue;
    }

    final parsed = parseNormalized(text);
    if (parsed == null) {
      return oldValue;
    }

    // Block values strictly exceeding max
    if (max != null && parsed > max!) {
      return oldValue;
    }

    // If negative value is typed and min is negative, block if below min
    if (min != null && min! < 0 && parsed < min!) {
      return oldValue;
    }

    return newValue;
  }

  /// Parses a string to [num], handling leading decimal dot (e.g. `.5` -> `0.5`).
  static num? parseNormalized(String s) {
    var str = s.trim();
    if (str.isEmpty) return null;
    if (str.startsWith('.')) {
      str = '0$str';
    } else if (str.startsWith('-.')) {
      str = '-0${str.substring(2)}';
    }
    return num.tryParse(str);
  }
}
