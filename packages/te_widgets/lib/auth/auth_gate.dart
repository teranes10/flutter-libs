import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/result/result.dart';

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

/// Guards a whole page: shows [child] when [permission] is granted, otherwise an "access denied" result.
///
/// `TSidebarItem.permission` hides the menu entry; this stops the same page being opened by its address.
/// `toGoRoutes()` wraps every routed item that has a permission in it.
class TAuthRouteGuard extends StatelessWidget {
  final Object? permission;
  final Widget child;

  const TAuthRouteGuard({super.key, required this.permission, required this.child});

  @override
  Widget build(BuildContext context) {
    if (context.authResolve(permission, target: TAuthTarget.sidebarItem).isAllowed) return child;
    return const TResult.forbidden(title: 'Access denied', subtitle: 'Your role does not include access to this page.');
  }
}
