/// String null-safety helpers
extension StringX on String? {
  /// Returns true if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if string is null or blank (empty or only whitespace)
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns string if not null or empty, otherwise defaultValue
  String orDefault(String defaultValue) {
    return (this != null && this!.isNotEmpty) ? this! : defaultValue;
  }

  /// Returns string if not null or blank, otherwise defaultValue
  String orDefaultIfBlank(String defaultValue) {
    return (this != null && this!.trim().isNotEmpty) ? this! : defaultValue;
  }
}

extension StringNonNullX on String {
  /// Returns true if string is empty
  bool get isEmpty => this.isEmpty;

  /// Returns true if string is blank (empty or only whitespace)
  bool get isBlank => trim().isEmpty;

  /// Returns true if string is not empty
  bool get isNotEmpty => !isEmpty;

  /// Returns true if string is not blank
  bool get isNotBlank => !isBlank;
}
