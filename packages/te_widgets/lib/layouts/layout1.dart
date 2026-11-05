import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/layouts/widgets/mobile_sidebar.dart';
import 'package:te_widgets/te_widgets.dart';

/// Top-bar layout: sidebar (full / minified / hidden) with the profile in the top bar.
class TLayout1 extends ConsumerStatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? minifiedLogo;
  final Widget? profile;
  final List<Widget>? actions;
  final Widget child;
  final String? pageTitle;
  final double mainCardRadius;
  final double? minWidth;
  final double maxWidth;
  final double minifiedWidth;
  final bool? isMinimized;
  final TSidebarMode? sidebarMode;
  final bool showHamburgerMenu;
  final bool showThemeToggle;
  final bool showFullscreenToggle;
  final bool showColorToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final TSidebarTheme? sidebarTheme;

  const TLayout1({
    super.key,
    this.items = const [],
    this.logo,
    this.minifiedLogo,
    this.profile,
    this.actions,
    required this.child,
    this.pageTitle,
    this.mainCardRadius = 12,
    this.minWidth = 235,
    this.maxWidth = 300,
    this.minifiedWidth = 80,
    this.isMinimized,
    this.sidebarMode,
    this.showHamburgerMenu = false,
    this.showThemeToggle = true,
    this.showFullscreenToggle = true,
    this.showColorToggle = true,
    this.showLogout = true,
    this.onLogout,
    this.sidebarTheme,
  });

  @override
  ConsumerState<TLayout1> createState() => _TLayout1State();
}

class _TLayout1State extends ConsumerState<TLayout1> with SingleTickerProviderStateMixin {
  bool _isMobileSidebarOpen = false;

  late final AnimationController _overlayController;
  late final Animation<double> _overlayCurve;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _overlayCurve = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.sidebarMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentMode = ref.read(sidebarNotifierProvider);
        if (currentMode != widget.sidebarMode) {
          ref.read(sidebarNotifierProvider.notifier).setMode(widget.sidebarMode!);
        }
      });
    } else if (widget.isMinimized != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentMode = ref.read(sidebarNotifierProvider);
        final targetMode = widget.isMinimized! ? TSidebarMode.minified : TSidebarMode.full;
        if (currentMode != targetMode) {
          ref.read(sidebarNotifierProvider.notifier).setMode(targetMode);
        }
      });
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
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
    if (!_isMobileSidebarOpen) return;
    setState(() {
      _isMobileSidebarOpen = false;
      _overlayController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final isMobile = !context.isDesktop;
    final cardColor = colors.surface.adaptiveContrast(context, 0.007);

    final resolved = resolveLayoutItems(
      context,
      TSidebarItemsResolver.resolve(widget.items),
      isMobile: isMobile,
      showHamburgerMenu: widget.showHamburgerMenu,
    );

    return Scaffold(
      backgroundColor: theme.layoutFrame,
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
            Padding(
              padding: EdgeInsets.all(isMobile ? 0.0 : widget.mainCardRadius / 2.4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(isMobile ? 0 : widget.mainCardRadius),
                ),
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
                    : Builder(
                        builder: (context) {
                          final sidebarMode = ref.watch(sidebarNotifierProvider);

                          return Row(
                            children: [
                              LayoutDesktopSidebar(
                                showDivider: false,
                                backgroundColor: cardColor, // same as the top bar
                                items: resolved.sidebarItems,
                                minWidth: widget.minWidth,
                                maxWidth: widget.maxWidth,
                                minifiedWidth: widget.minifiedWidth,
                                mode: sidebarMode,
                                theme: widget.sidebarTheme,
                                logo: widget.logo,
                                minifiedLogo: widget.minifiedLogo,
                                onToggle: () => ref
                                    .read(sidebarNotifierProvider.notifier)
                                    .setMode(sidebarMode == TSidebarMode.full ? TSidebarMode.minified : TSidebarMode.full),
                              ),
                              // ── Top bar + content ──────────────────────────
                              Expanded(
                                child: Column(
                                  children: [
                                    LayoutDesktopTopBar(
                                      logo: widget.logo,
                                      minifiedLogo: widget.minifiedLogo,
                                      homeItem: resolved.homeItem,
                                      resolvedItems: resolved.allItems,
                                      sidebarItems: resolved.sidebarItems,
                                      profile: widget.profile,
                                      showThemeToggle: widget.showThemeToggle,
                                      showColorToggle: widget.showColorToggle,
                                      actions: widget.actions,
                                      showFullscreenToggle: widget.showFullscreenToggle,
                                      showLogout: widget.showLogout,
                                      onLogout: widget.onLogout,
                                      sidebarTheme: widget.sidebarTheme,
                                    ),
                                    Expanded(child: LayoutMainContent(isMobile: false, child: widget.child)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
                  minifiedWidth: widget.minifiedWidth,
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
