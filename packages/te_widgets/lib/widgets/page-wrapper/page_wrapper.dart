import 'package:flutter/material.dart';

/// A uniform page wrapper widget used across popups, details pages, and fullscreen modals on mobile.
class TPageWrapper extends StatelessWidget {
  /// The main content of the page.
  final Widget child;

  /// Optional title displayed in the AppBar.
  final String? title;

  /// Optional callback for the back button in the AppBar.
  final VoidCallback? onBackPressed;

  /// Optional actions to display in the AppBar.
  final List<Widget>? actions;

  /// Creates a page wrapper.
  const TPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (title != null || onBackPressed != null || actions != null)
          ? AppBar(
              leading: onBackPressed != null
                  ? BackButton(onPressed: onBackPressed)
                  : null,
              title: title != null ? Text(title!) : null,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: child,
      ),
    );
  }
}
