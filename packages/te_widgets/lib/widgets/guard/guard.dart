import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A conditional widget wrapper for permissions/access control.
///
/// `TGuard` provides conditional rendering with:
/// - Hide or disable based on condition
/// - Useful for permission-based UI
/// - Simple boolean condition
///
/// ## Hide When False
///
/// ```dart
/// TGuard(
///   condition: user.canEdit,
///   action: TGuardAction.hide,
///   child: EditButton(),
/// )
/// ```
///
/// ## Disable When False
///
/// ```dart
/// TGuard(
///   condition: user.canDelete,
///   action: TGuardAction.disable,  // Default
///   child: DeleteButton(),
/// )
/// ```
///
/// See also:
/// - [Visibility] for visibility control
/// - [IgnorePointer] for interaction control
class TGuard extends StatelessWidget {
  /// The condition to evaluate.
  final bool condition;

  /// The action to take when condition is false.
  final TGuardAction action;

  /// The child widget to guard.
  final Widget child;

  /// Creates a guard widget.
  const TGuard({
    super.key,
    this.action = TGuardAction.disable,
    required this.condition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) return child;

    return switch (action) {
      TGuardAction.hide => const SizedBox.shrink(),
      TGuardAction.disable => IgnorePointer(child: Opacity(opacity: 0.45, child: child))
    };
  }
}
