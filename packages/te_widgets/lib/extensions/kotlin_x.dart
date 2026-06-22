/// Scope functions for null-safe operations
extension LetExtension<T> on T? {
  /// Executes block if value is not null and returns the result
  /// Usage: user?.let((it) => it.name) ?? 'Guest'
  R? let<R>(R Function(T it) block) {
    final self = this;
    if (self != null) return block(self);
    return null;
  }

  /// Executes block if value is not null, returns the original value
  /// Usage: user?.also((it) => print(it.name))
  T? also(void Function(T it) block) {
    final self = this;
    if (self != null) {
      block(self);
      return self;
    }
    return null;
  }

  /// Returns value if it satisfies the predicate, otherwise null
  /// Usage: number.takeIf((it) => it > 0)
  T? takeIf(bool Function(T it) predicate) {
    final self = this;
    if (self != null) {
      return predicate(self) ? this : null;
    }
    return null;
  }
}

/// Scope functions for non-nullable values
extension ScopeExtension<T> on T {
  /// Returns value if it satisfies the predicate, otherwise null
  /// Usage: number.takeIf((it) => it > 0)
  T? takeIf(bool Function(T it) predicate) {
    return predicate(this) ? this : null;
  }
}
