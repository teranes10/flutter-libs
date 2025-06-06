class Validations {
  static String Function(String?) requiredString(String message) {
    return (String? value) => (value?.isEmpty ?? true) ? message : '';
  }

  static String Function(String?) minLength(int min, [String? message]) {
    return (String? value) => (value?.length ?? 0) < min ? message ?? 'Must be at least $min characters' : '';
  }

  static String Function(String?) maxLength(int max, [String? message]) {
    return (String? value) => (value?.length ?? 0) > max ? message ?? 'Must be at most $max characters' : '';
  }

  static String Function(String?) email([String? message]) {
    return (String? value) {
      if (value?.isEmpty ?? true) return '';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      return emailRegex.hasMatch(value!) ? '' : message ?? 'Please enter a valid email address';
    };
  }

  static String Function(double?) minValue(double min, [String? message]) {
    return (double? value) => (value ?? double.negativeInfinity) < min ? message ?? 'Value must be at least $min' : '';
  }

  static String Function(double?) maxValue(double max, [String? message]) {
    return (double? value) => (value ?? double.infinity) > max ? message ?? 'Value must be at most $max' : '';
  }

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
