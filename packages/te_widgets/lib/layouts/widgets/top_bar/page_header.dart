import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Shows the current page as a [TTile] built from the route metadata set by `toGoRoutes()`:
/// icon, title, and info as subtitle.
class LayoutPageHeader extends StatelessWidget {
  const LayoutPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.leafRouteState;
    final meta = state.metadata;
    final segment = state.matchedLocation.split('/').where((s) => s.isNotEmpty).lastOrNull;
    final title = meta[TRouteMeta.title] as String? ?? segment?.capitalize();
    if (title == null) return const SizedBox.shrink();

    return TTile.h4(
      icon: meta[TRouteMeta.icon],
      iconBackgroundColor: Colors.transparent,
      title: title,
      subtitle: meta[TRouteMeta.info] as String?,
    );
  }
}
