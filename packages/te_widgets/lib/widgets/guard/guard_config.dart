/// Action to take when a guard condition is not met.
enum TGuardAction {
  /// Hide the widget completely.
  hide,

  /// Show the widget in a disabled state.
  disable
}

/// Function type for guard conditions.
typedef TGuardCondition<T> = bool Function(T);
