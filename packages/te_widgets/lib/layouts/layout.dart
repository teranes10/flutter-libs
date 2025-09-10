import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TLayout extends StatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? profile;
  final List<Widget>? actions;
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
    this.actions,
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

class _TLayoutState extends State<TLayout> with TickerProviderStateMixin {
  bool _isMobileSidebarOpen = false;
  late bool _isMinified;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    _isMinified = widget.isMinimized;
    _overlayController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _overlayAnimation = CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _isMinified = !_isMinified);
  }

  void _toggleMobileSidebar() {
    setState(() {
      _isMobileSidebarOpen = !_isMobileSidebarOpen;
      if (_isMobileSidebarOpen) {
        _overlayController.forward();
      } else {
        _overlayController.reverse();
      }
    });
  }

  void _closeMobileSidebar() {
    if (_isMobileSidebarOpen) {
      setState(() {
        _isMobileSidebarOpen = false;
        _overlayController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;

    return Scaffold(
      backgroundColor: exTheme.layoutFrame,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(isMobile ? 0.0 : widget.mainCardRadius / 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : widget.mainCardRadius),
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(theme, isMobile),
                        Expanded(
                          child: Row(
                            children: [
                              if (!isMobile)
                                Padding(
                                  padding: const EdgeInsets.only(top: 45, bottom: 28),
                                  child: Sidebar(
                                    items: widget.items,
                                    width: widget.width,
                                    minifiedWidth: widget.minifiedWidth,
                                    isMinimized: _isMinified,
                                  ),
                                ),
                              _buildMainContent(theme, isMobile, widget.child),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mobile sidebar overlay
                if (isMobile) _buildSidebarOverlay(theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme theme, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: isMobile ? const EdgeInsets.fromLTRB(16, 16, 16, 12) : const EdgeInsets.fromLTRB(10, 24, 10, 14),
      child: isMobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.logo != null) Expanded(child: widget.logo!) else SizedBox.shrink(),
                GestureDetector(
                  onTap: _toggleMobileSidebar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isMobileSidebarOpen ? Icons.close_rounded : Icons.menu_rounded,
                      size: 24,
                      color: theme.onSurface,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (widget.logo != null) SizedBox(width: widget.width - 20, child: widget.logo!),
                _buildSidebarToggle(theme),
                const SizedBox(width: 10),
                Expanded(child: _buildPageTitle(theme)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    if (widget.profile != null) widget.profile!,
                    if (widget.actions != null) ...widget.actions!,
                  ],
                ),
                const SizedBox(width: 15),
              ],
            ),
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
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMainContent(ColorScheme theme, bool isMobile, Widget child) {
    return Expanded(
      child: DecoratedBox(
        decoration: isMobile
            ? BoxDecoration(
                color: theme.surface,
                border: Border.all(color: theme.outlineVariant, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              )
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
            SizedBox(height: isMobile ? 4 : 8),
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: SingleChildScrollView(child: child),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarOverlay(ColorScheme theme) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Visibility(
          visible: _overlayAnimation.value > 0,
          child: Stack(
            children: [
              // Backdrop
              GestureDetector(
                onTap: _closeMobileSidebar,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Color.fromRGBO(0, 0, 0, 0.5 * _overlayAnimation.value),
                ),
              ),
              // Sidebar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(-widget.width * (1 - _overlayAnimation.value), 0),
                  child: Container(
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 20,
                          offset: const Offset(4, 0),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Logo section
                          if (widget.logo != null)
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: widget.logo!,
                            ),
                          // Sidebar items
                          Expanded(
                            child: Sidebar(
                              items: widget.items,
                              width: widget.width,
                              minifiedWidth: widget.minifiedWidth,
                              isMinimized: false,
                              onTap: (_) => _closeMobileSidebar(),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: theme.surfaceDim,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 15,
                              runSpacing: 10,
                              children: [
                                if (widget.profile != null) widget.profile!,
                                ...widget.actions!,
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
