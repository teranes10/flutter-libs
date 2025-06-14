import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/layouts/widgets/logo.dart';
import 'package:te_widgets/layouts/widgets/profile.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_config.dart';

class Layout extends StatefulWidget {
  final List<TSidebarItem> items;
  final TLogo? logo;
  final TProfile? profile;
  final Widget child;
  final String? pageTitle;
  final double mainCardRadius;
  final double width;
  final double minifiedWidth;
  final bool isMinimized;

  const Layout({
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
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
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
    return Scaffold(
      backgroundColor: AppColors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(widget.mainCardRadius / 2),
          child: ResponsiveBuilder(
            builder: (context, sizing) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.mainCardRadius),
                ),
                child: Column(
                  children: [
                    _buildTopBar(context, sizing),
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
                            pageTitle: widget.pageTitle,
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

  Widget _buildTopBar(BuildContext context, SizingInformation sizing) {
    final List<Widget> children = [
      if (widget.logo != null) SizedBox(width: widget.width - 20, child: widget.logo!),
      if (!sizing.isMobile) const SizedBox(width: 5),
      if (!sizing.isMobile) _buildSidebarToggle(),
      if (!sizing.isMobile) const SizedBox(width: 10),
      if (!sizing.isMobile) _buildPageTitle(),
      Spacer(),
      if (widget.profile != null) widget.profile!,
      SizedBox(width: 25)
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 20),
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

  Widget _buildSidebarToggle() {
    return InkWell(
      onTap: _toggleSidebar,
      borderRadius: BorderRadius.circular(24),
      child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.grey.shade50.withAlpha(150),
          child: Icon(_isMinified ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, size: 20, color: AppColors.grey.shade500)),
    );
  }

  Widget _buildPageTitle() {
    final String title = widget.pageTitle ?? GoRouterState.of(context).topRoute?.name ?? '';

    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: AppColors.grey.shade500),
    );
  }
}

/* ─────────────────────────── main/content helpers ─────────────────────────── */

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.isMobile,
    required this.pageTitle,
    required this.child,
  });

  final bool isMobile;
  final String? pageTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: isMobile
            ? const BoxDecoration()
            : BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.grey.shade50, width: 1),
                  left: BorderSide(color: AppColors.grey.shade50, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
        child: Column(
          children: [
            if (pageTitle != null)
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  pageTitle!,
                  style: TextStyle(fontSize: 24, color: AppColors.grey[600]),
                ),
              ),
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
