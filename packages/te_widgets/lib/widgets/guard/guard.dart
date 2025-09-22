import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TGuard extends StatelessWidget {
  final bool condition;
  final TGuardAction action;
  final Widget child;

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
