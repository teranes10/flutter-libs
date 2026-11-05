import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/layouts/widgets/mobile_sidebar.dart';
import 'package:te_widgets/te_widgets.dart';

/// Sidebar layout: always-visible desktop sidebar with the profile pinned at
/// its bottom (or under the logo). No top bar, no minified / hidden modes.
class TLayout2 extends ConsumerStatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? minifiedLogo;
  final Widget? profile;
  final bool showProfileBelowLogo;
  final List<Widget>? actions;
  final Widget child;
  final String? pageTitle;
  final double? minWidth;
  final double maxWidth;
  final bool showHamburgerMenu;
  final bool showThemeToggle;
  final bool showFullscreenToggle;
  final bool showColorToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final TSidebarTheme? sidebarTheme;

  const TLayout2({
    super.key,
    this.items = const [],
    this.logo,
    this.minifiedLogo,
    this.profile,
    this.showProfileBelowLogo = false,
    this.actions,
    required this.child,
    this.pageTitle,
    this.minWidth = 235,
    this.maxWidth = 300,
    this.showHamburgerMenu = false,
    this.showThemeToggle = true,
    this.showFullscreenToggle = true,
    this.showColorToggle = true,
    this.showLogout = true,
    this.onLogout,
    this.sidebarTheme,
  });

  @override
  ConsumerState<TLayout2> createState() => _TLayout2State();
}

class _TLayout2State extends ConsumerState<TLayout2> with SingleTickerProviderStateMixin {
  bool _isMobileSidebarOpen = false;

  late final AnimationController _overlayController;
  late final Animation<double> _overlayCurve;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(duration: const Duration(milliseconds: 280), vsync: this);
    _overlayCurve = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleMobileSidebar() {
    setState(() {
      _isMobileSidebarOpen = !_isMobileSidebarOpen;
      _isMobileSidebarOpen ? _overlayController.forward() : _overlayController.reverse();
    });
  }

  void _closeMobileSidebar() {
    if (!_isMobileSidebarOpen) return;
    setState(() {
      _isMobileSidebarOpen = false;
      _overlayController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = !context.isDesktop;

    final resolved = resolveLayoutItems(
      context,
      TSidebarItemsResolver.resolve(widget.items),
      isMobile: isMobile,
      showHamburgerMenu: widget.showHamburgerMenu,
    );

    return Scaffold(
      backgroundColor: isMobile ? context.theme.layoutFrame : context.scaffoldBackgroundColor,
      bottomNavigationBar: isMobile && resolved.bottomBarItems.isNotEmpty
          ? LayoutBottomBar(
              items: resolved.bottomBarItems,
              logo: widget.minifiedLogo ?? widget.logo,
              onOpenMore: _toggleMobileSidebar,
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            ColoredBox(
              color: isMobile ? colors.surface.adaptiveContrast(context, 0.007) : Colors.transparent,
              child: isMobile
                  ? Column(
                      children: [
                        LayoutMobileTopBar(
                          resolvedItems: resolved.allItems,
                          showHamburgerMenu: widget.showHamburgerMenu || resolved.bottomBarItems.isEmpty,
                          isSidebarOpen: _isMobileSidebarOpen,
                          onToggleSidebar: _toggleMobileSidebar,
                        ),
                        Expanded(child: LayoutMainContent(isMobile: true, child: widget.child)),
                      ],
                    )
                  : Row(
                      children: [
                        LayoutDesktopSidebar(
                          items: resolved.sidebarItems,
                          minWidth: widget.minWidth,
                          maxWidth: widget.maxWidth,
                          theme: widget.sidebarTheme,
                          logo: widget.logo,
                          profileBelowLogo: widget.showProfileBelowLogo,
                          profile: widget.profile == null
                              ? null
                              : ({required bool minified}) => LayoutProfileButton(
                                    expand: true,
                                    profile: widget.profile!,
                                    showThemeToggle: widget.showThemeToggle,
                                    showColorToggle: widget.showColorToggle,
                                    showFullscreenToggle: widget.showFullscreenToggle,
                                    showLogout: widget.showLogout,
                                    onLogout: widget.onLogout,
                                    actions: widget.actions,
                                  ),
                        ),
                        Expanded(child: LayoutMainContent(isMobile: false, framed: false, child: widget.child)),
                      ],
                    ),
            ),
            if (isMobile)
              MobileSidebarOverlay(
                controller: _overlayController,
                curve: _overlayCurve,
                onClose: _closeMobileSidebar,
                panel: MobileSidebarOverlayPanel(
                  logo: widget.logo,
                  sidebarItems: resolved.sidebarItems,
                  minWidth: widget.minWidth,
                  maxWidth: widget.maxWidth,
                  minifiedWidth: 80,
                  profile: widget.profile,
                  showThemeToggle: widget.showThemeToggle,
                  showColorToggle: widget.showColorToggle,
                  actions: widget.actions,
                  showFullscreenToggle: widget.showFullscreenToggle,
                  showLogout: widget.showLogout,
                  onLogout: widget.onLogout,
                  onItemTap: _closeMobileSidebar,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
