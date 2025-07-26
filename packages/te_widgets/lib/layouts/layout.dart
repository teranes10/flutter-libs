import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:te_widgets/te_widgets.dart';

class TLayout extends StatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? profile;
  final Widget child;
  final String? pageTitle;
  final double mainCardRadius;
  final double width;
  final double minifiedWidth;
  final bool isMinimized;

  const TLayout({
    super.key,
    this.items = const [],
    this.logo,
    this.profile,
    required this.child,
    this.pageTitle,
    this.mainCardRadius = 28,
    this.width = 275,
    this.minifiedWidth = 80,
    this.isMinimized = false,
  });

  @override
  State<TLayout> createState() => _TLayoutState();
}

class _TLayoutState extends State<TLayout> {
  late bool _isMinified;

  @override
  void initState() {
    super.initState();
    _isMinified = widget.isMinimized;
  }

  void _toggleSidebar() {
    setState(() => _isMinified = !_isMinified);
  }

  final double kNarrowMaxWidth = 600;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;

    return Scaffold(
      backgroundColor: exTheme.layoutFrame,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(widget.mainCardRadius / 2),
          child: ResponsiveBuilder(
            builder: (context, sizing) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(widget.mainCardRadius),
                ),
                child: Column(
                  children: [
                    _buildTopBar(theme, sizing),
                    Expanded(
                      child: Row(
                        children: [
                          if (!sizing.isMobile)
                            Padding(
                              padding: EdgeInsets.only(top: 45, bottom: 28),
                              child: Sidebar(
                                items: widget.items,
                                width: widget.width,
                                minifiedWidth: widget.minifiedWidth,
                                isMinimized: _isMinified,
                              ),
                            ),
                          _MainContent(
                            isMobile: sizing.isMobile,
                            child: widget.child,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /* ─────────────────────────────── top bar ─────────────────────────────── */

  Widget _buildTopBar(ColorScheme theme, SizingInformation sizing) {
    final List<Widget> children = [
      if (widget.logo != null) SizedBox(width: widget.width - 20, child: widget.logo!),
      if (!sizing.isMobile) const SizedBox(width: 5),
      if (!sizing.isMobile) _buildSidebarToggle(theme),
      if (!sizing.isMobile) const SizedBox(width: 10),
      if (!sizing.isMobile) _buildPageTitle(theme),
      Spacer(),
      if (widget.profile != null) widget.profile!,
      SizedBox(width: 25)
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 24, 10, 14),
      child: sizing.isMobile
          ? Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: children,
            )
          : Row(children: children),
    );
  }

  Widget _buildSidebarToggle(ColorScheme theme) {
    return InkWell(
      onTap: _toggleSidebar,
      borderRadius: BorderRadius.circular(24),
      child: CircleAvatar(
          radius: 16,
          backgroundColor: theme.surfaceContainerHigh,
          child: Icon(_isMinified ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, size: 20, color: theme.onSurface)),
    );
  }

  Widget _buildPageTitle(ColorScheme theme) {
    final String title = widget.pageTitle ?? GoRouterState.of(context).topRoute?.name ?? '';

    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: theme.onSurfaceVariant),
    );
  }
}

/* ─────────────────────────── main/content helpers ─────────────────────────── */

class _MainContent extends StatelessWidget {
  final bool isMobile;
  final Widget child;

  const _MainContent({
    required this.isMobile,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Expanded(
      child: DecoratedBox(
        decoration: isMobile
            ? const BoxDecoration()
            : BoxDecoration(
                color: theme.surface,
                border: Border(
                  top: BorderSide(color: theme.outlineVariant, width: 1),
                  left: BorderSide(color: theme.outlineVariant, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(child: _Content(child: child)),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(child: child),
    );
  }
}
