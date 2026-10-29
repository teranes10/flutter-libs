import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'auth_mode.dart';

/// Wraps [child] and hides or disables it when [permission] is not granted.
///
/// Prefer a widget's own `permission` parameter when it has one (native
/// disabled styling); use this gate for anything else.
class TAuthGate extends StatelessWidget {
  final Object? permission;
  final TAuthMode? onDenied;
  final TAuthTarget target;
  final Widget child;

  const TAuthGate({super.key, required this.permission, this.onDenied, this.target = TAuthTarget.button, required this.child});

  @override
  Widget build(BuildContext context) {
    final result = context.authResolve(permission, target: target, onDenied: onDenied);
    if (result.isAllowed) return child;
    if (result.isHidden) return const SizedBox.shrink();
    return IgnorePointer(child: Opacity(opacity: 0.45, child: child));
  }
}
