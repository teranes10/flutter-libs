/// A collection of common validation functions for form fields.
///
/// These validation functions return error messages when validation fails,
/// or an empty string when validation passes. They are designed to work
/// with the `rules` parameter of input widgets like [TTextField].
///
/// ## Usage Example
///
/// ```dart
/// TTextField(
///   label: 'Email',
///   rules: [
///     Validations.requiredString('Email is required'),
///     Validations.email('Please enter a valid email'),
///   ],
/// )
/// ```
class Validations {
  /// Creates a validation rule that requires a non-empty string.
  ///
  /// Returns [message] if the value is null or empty, otherwise returns an empty string.
  ///
  /// Example:
  /// ```dart
  /// Validations.requiredString('Name is required')
  /// ```
  static String Function(String?) requiredString(String message) {
    return (String? value) => (value?.isEmpty ?? true) ? message : '';
  }

  /// Creates a validation rule that enforces a minimum string length.
  ///
  /// Returns an error message if the string length is less than [min].
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.minLength(8, 'Password must be at least 8 characters')
  /// ```
  static String Function(String?) minLength(int min, [String? message]) {
    return (String? value) => (value?.length ?? 0) < min ? message ?? 'Must be at least $min characters' : '';
  }

  /// Creates a validation rule that enforces a maximum string length.
  ///
  /// Returns an error message if the string length exceeds [max].
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.maxLength(100, 'Description must be at most 100 characters')
  /// ```
  static String Function(String?) maxLength(int max, [String? message]) {
    return (String? value) => (value?.length ?? 0) > max ? message ?? 'Must be at most $max characters' : '';
  }

  /// Creates a validation rule for email addresses.
  ///
  /// Uses a basic regex pattern to validate email format.
  /// Returns an error message if the email format is invalid.
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.email('Please enter a valid email address')
  /// ```
  static String Function(String?) email([String? message]) {
    return (String? value) {
      if (value?.isEmpty ?? true) return '';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      return emailRegex.hasMatch(value!) ? '' : message ?? 'Please enter a valid email address';
    };
  }

  /// Creates a validation rule that enforces a minimum numeric value.
  ///
  /// Returns an error message if the value is less than [min].
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.minValue(0, 'Value must be positive')
  /// ```
  static String Function(double?) minValue(double min, [String? message]) {
    return (double? value) => (value ?? double.negativeInfinity) < min ? message ?? 'Value must be at least $min' : '';
  }

  /// Creates a validation rule that enforces a maximum numeric value.
  ///
  /// Returns an error message if the value exceeds [max].
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.maxValue(100, 'Value cannot exceed 100')
  /// ```
  static String Function(double?) maxValue(double max, [String? message]) {
    return (double? value) => (value ?? double.infinity) > max ? message ?? 'Value must be at most $max' : '';
  }

  /// Creates a validation rule that enforces a numeric range.
  ///
  /// Returns an error message if the value is outside the range [min, max].
  /// If [message] is not provided, uses a default message.
  ///
  /// Example:
  /// ```dart
  /// Validations.range(1, 10, 'Value must be between 1 and 10')
  /// ```
  static String Function(double?) range(double min, double max, [String? message]) {
    return (double? value) {
      if (value == null) return '';
      if (value < min || value > max) {
        return message ?? 'Value must be between $min and $max';
      }
      return '';
    };
  }
}

