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

  /// Executes block if value is null
  /// Usage: user.ifNull(() => print('No user'))
  void ifNull(void Function() block) {
    if (this == null) block();
  }
}

/// Scope functions for non-nullable values
extension ScopeExtension<T> on T {
  /// Executes block with value as 'this' context and returns result
  /// Usage: user.run((self) => self.name.toUpperCase())
  R run<R>(R Function(T self) block) {
    return block(this);
  }

  /// Executes block with value as parameter and returns the original value
  /// Usage: user.also((it) => print(it.name))
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Executes block with value as 'this' context and returns the original value
  /// Usage: StringBuilder().apply((self) => self..write('Hello')..write('World'))
  T apply(void Function(T self) block) {
    block(this);
    return this;
  }

  /// Returns value if it satisfies the predicate, otherwise null
  /// Usage: number.takeIf((it) => it > 0)
  T? takeIf(bool Function(T it) predicate) {
    return predicate(this) ? this : null;
  }
}
