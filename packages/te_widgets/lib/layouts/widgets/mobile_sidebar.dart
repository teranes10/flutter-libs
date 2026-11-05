import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────
// Mobile sidebar overlay
// ─────────────────────────────────────────────────────────────────────────

class MobileSidebarOverlay extends StatelessWidget {
  const MobileSidebarOverlay({
    super.key,
    required this.controller,
    required this.curve,
    required this.onClose,
    required this.panel,
  });

  final AnimationController controller;
  final Animation<double> curve;
  final VoidCallback onClose;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(curve);

    return AnimatedBuilder(
      animation: controller,
      // `child` is built once and reused across animation frames instead of
      // being rebuilt every tick.
      child: panel,
      builder: (context, child) {
        if (controller.status == AnimationStatus.dismissed) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: curve,
                child: GestureDetector(
                  onTap: onClose,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.black.withValues(alpha: 0.45)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(position: slide, child: child),
            ),
          ],
        );
      },
    );
  }
}

class MobileSidebarOverlayPanel extends StatelessWidget {
  const MobileSidebarOverlayPanel({
    super.key,
    required this.logo,
    required this.sidebarItems,
    required this.minWidth,
    required this.maxWidth,
    required this.minifiedWidth,
    required this.profile,
    required this.showThemeToggle,
    required this.showColorToggle,
    required this.actions,
    required this.showFullscreenToggle,
    required this.showLogout,
    required this.onLogout,
    required this.onItemTap,
  });

  final Widget? logo;
  final List<TSidebarItem> sidebarItems;
  final double? minWidth;
  final double maxWidth;
  final double minifiedWidth;
  final Widget? profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final List<Widget>? actions;
  final bool showFullscreenToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(right: BorderSide(color: colors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Sidebar(
          items: sidebarItems,
          minWidth: minWidth,
          maxWidth: maxWidth,
          minifiedWidth: minifiedWidth,
          isMinimized: false,
          onTap: (_) => onItemTap(),
          theme: TSidebarTheme.defaultTheme(context).copyWith(
            itemPadding: const EdgeInsets.fromLTRB(8, 12, 6, 12),
            childPadding: const EdgeInsets.fromLTRB(8, 9, 4, 9),
          ),
          header: logo == null ? null : Padding(padding: const EdgeInsets.fromLTRB(14, 12, 12, 0), child: logo),
          pinnedFooter: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 12),
            child: profile == null
                ? LayoutActionsRow(
                    profile: null,
                    showThemeToggle: showThemeToggle,
                    showColorToggle: showColorToggle,
                    actions: actions,
                    showFullscreenToggle: showFullscreenToggle,
                    showLogout: showLogout,
                    onLogout: onLogout,
                    spacing: 10,
                    runSpacing: 10,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (actions != null && actions!.isNotEmpty) ...[
                        Wrap(spacing: 10, runSpacing: 10, children: actions!),
                        const SizedBox(height: 8),
                      ],
                      LayoutProfileButton(
                        profile: profile!,
                        expand: true,
                        showThemeToggle: showThemeToggle,
                        showColorToggle: showColorToggle,
                        showFullscreenToggle: showFullscreenToggle,
                        showLogout: showLogout,
                        onLogout: onLogout,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
