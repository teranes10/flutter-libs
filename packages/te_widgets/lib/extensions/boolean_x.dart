/// Boolean extensions inspired by Kotlin
extension BoolX on bool {
  /// Executes block if true
  /// Usage: isValid.ifTrue(() => save())
  void ifTrue(void Function() block) {
    if (this) block();
  }

  /// Executes block if false
  /// Usage: isValid.ifFalse(() => showError())
  void ifFalse(void Function() block) {
    if (!this) block();
  }
}
