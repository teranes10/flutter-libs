import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Desktop sidebar shared by `TLayout1` and `TLayout2`: surface + divider, logo
/// header and an optional pinned profile.
///
/// When [onToggle] is set, hovering the sidebar reveals a collapse button after
/// the logo (full) or swaps the logo for an expand button (minified).
class LayoutDesktopSidebar extends StatefulWidget {
  const LayoutDesktopSidebar({
    super.key,
    required this.items,
    this.mode = TSidebarMode.full,
    this.onToggle,
    this.minWidth,
    this.maxWidth,
    this.minifiedWidth = 80,
    this.theme,
    this.logo,
    this.minifiedLogo,
    this.profile,
    this.profileBelowLogo = false,
    this.showDivider = true,
    this.backgroundColor,
  });

  final List<TSidebarItem> items;
  final TSidebarMode mode;
  final VoidCallback? onToggle;
  final double? minWidth;
  final double? maxWidth;
  final double minifiedWidth;
  final TSidebarTheme? theme;
  final Widget? logo;
  final Widget? minifiedLogo;

  /// Builds the profile; `minified` is true while the sidebar is collapsed.
  final Widget Function({required bool minified})? profile;
  final bool profileBelowLogo;

  /// Draws the 1px border on the sidebar's right edge.
  final bool showDivider;

  /// Sidebar background; defaults to the theme surface.
  final Color? backgroundColor;

  @override
  State<LayoutDesktopSidebar> createState() => _LayoutDesktopSidebarState();
}

class _LayoutDesktopSidebarState extends State<LayoutDesktopSidebar> {
  bool _hovered = false;

  Widget _toggleButton({required bool minified}) {
    return TButton(
      type: TButtonType.icon,
      size: TButtonSize.xs.copyWith(icon: 18),
      icon: minified ? HugeIcons.strokeRoundedMenu03 : HugeIcons.strokeRoundedMenuCollapse,
      color: context.colors.onSurfaceVariant,
      tooltip: minified ? 'Expand sidebar' : 'Collapse sidebar',
      onPressed: (_) => widget.onToggle?.call(),
    );
  }

  Widget _header({required bool minified}) {
    final logo = minified ? (widget.minifiedLogo ?? widget.logo) : widget.logo;
    final profile = widget.profileBelowLogo ? widget.profile?.call(minified: minified) : null;
    final canToggle = widget.onToggle != null;
    const fade = Duration(milliseconds: 150);

    final Widget top = minified
        ? Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: fade,
                opacity: canToggle && _hovered ? 0 : 1,
                child: logo ?? const SizedBox(height: 32),
              ),
              if (canToggle)
                Positioned.fill(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: fade,
                      opacity: _hovered ? 1 : 0,
                      child: IgnorePointer(ignoring: !_hovered, child: _toggleButton(minified: true)),
                    ),
                  ),
                ),
            ],
          )
        : Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: logo ?? const SizedBox(height: 32))),
              if (canToggle)
                AnimatedOpacity(
                  duration: fade,
                  opacity: _hovered ? 1 : 0,
                  child: IgnorePointer(ignoring: !_hovered, child: _toggleButton(minified: false)),
                ),
            ],
          );

    // Left edge 20 lines the logo up with the sidebar icons (item margin + padding).
    return Padding(
      padding: EdgeInsets.fromLTRB(minified ? 8 : 20, 18, minified ? 8 : 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          if (profile != null) ...[
            const SizedBox(height: 12),
            minified ? Center(child: profile) : profile,
          ],
        ],
      ),
    );
  }

  Widget? _pinnedProfile({required bool minified}) {
    if (widget.profile == null || widget.profileBelowLogo) return null;
    final profile = widget.profile!(minified: minified);
    return Padding(
      padding: EdgeInsets.fromLTRB(minified ? 8 : 14, 12, minified ? 8 : 12, 12),
      child: minified ? Center(child: profile) : profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (widget.mode == TSidebarMode.none) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? colors.surface,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Sidebar(
              items: widget.items,
              minWidth: widget.minWidth,
              maxWidth: widget.maxWidth,
              minifiedWidth: widget.minifiedWidth,
              mode: widget.mode,
              theme: widget.theme,
              header: _header(minified: false),
              minifiedHeader: _header(minified: true),
              pinnedFooter: _pinnedProfile(minified: false),
              minifiedPinnedFooter: _pinnedProfile(minified: true),
            ),
          ),
          if (widget.showDivider) SizedBox(width: 1, child: ColoredBox(color: colors.outlineVariant, child: const SizedBox.expand())),
        ],
      ),
    );
  }
}
