import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TLayout extends ConsumerStatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? profile;
  final List<Widget>? actions;
  final Widget child;
  final String? pageTitle;
  final double mainCardRadius;
  final double width;
  final double minifiedWidth;
  final bool? isMinimized;
  final bool showHamburgerMenu;
  final bool showThemeToggle;
  final bool showLogout;
  final VoidCallback? onLogout;

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
    this.isMinimized,
    this.showHamburgerMenu = false,
    this.showThemeToggle = true,
    this.showLogout = true,
    this.onLogout,
  });

  @override
  ConsumerState<TLayout> createState() => _TLayoutState();
}

class _TLayoutState extends ConsumerState<TLayout> with TickerProviderStateMixin {
  bool _isMobileSidebarOpen = false;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _overlayAnimation = CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut);

    if (widget.isMinimized != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final isCurrentlyMinimized = ref.read(sidebarNotifierProvider);
        if (isCurrentlyMinimized != widget.isMinimized) {
          ref.read(sidebarNotifierProvider.notifier).toggleSidebar();
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
    if (_isMobileSidebarOpen) {
      setState(() {
        _isMobileSidebarOpen = false;
        _overlayController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final isMinimized = ref.watch(sidebarNotifierProvider);

    // --- Validation and Logic ---
    final isMobile = context.isMobile;

    // Centralized Resolution and Validation
    final resolvedItems = TSidebarItemsResolver.resolve(widget.items);

    TSidebarItem? homeItem;
    final List<TSidebarItem> bottomBarItemsCandidates = [];
    final List<TSidebarItem> sidebarItems = [];

    // 1. Identify Home and Bottom Bar items using resolved items
    for (final item in resolvedItems) {
      if (item.home) {
        homeItem = item;
      }

      if (item.bottomBarPosition != null) {
        bottomBarItemsCandidates.add(item);
      }
    }

    // 2. Prepare Bottom Bar Items
    final List<TSidebarItem> finalBottomBarItems = [];
    if (homeItem != null) {
      finalBottomBarItems.add(homeItem);
    }

    if (bottomBarItemsCandidates.isEmpty && resolvedItems.isNotEmpty) {
      // Auto-get first 4 items including home
      final itemsCount = widget.showHamburgerMenu ? 5 : 4;
      final candidates = resolvedItems.where((item) => item != homeItem).take(itemsCount - finalBottomBarItems.length);
      finalBottomBarItems.addAll(candidates);
    } else {
      bottomBarItemsCandidates.sort((a, b) => a.bottomBarPosition!.compareTo(b.bottomBarPosition!));
      finalBottomBarItems.addAll(bottomBarItemsCandidates.take(4 - finalBottomBarItems.length));
    }

    // 3. Prepare Sidebar Items (Exclude Bottom Bar items only for Mobile)
    if (isMobile) {
      for (final item in resolvedItems) {
        if (!finalBottomBarItems.contains(item)) {
          sidebarItems.add(item);
        }
      }
    } else {
      sidebarItems.addAll(resolvedItems);
    }
    // --- End Validation and Logic ---

    return Scaffold(
      backgroundColor: theme.layoutFrame,
      bottomNavigationBar: isMobile ? _buildBottomBar(context, colors, finalBottomBarItems) : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(isMobile ? 0.0 : widget.mainCardRadius / 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : widget.mainCardRadius),
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(colors, isMobile, homeItem, isMinimized, resolvedItems),
                        Expanded(
                          child: Row(
                            children: [
                              if (!isMobile)
                                Padding(
                                  padding: const EdgeInsets.only(top: 45, bottom: 28),
                                  child: Sidebar(
                                    items: sidebarItems,
                                    width: widget.width,
                                    minifiedWidth: widget.minifiedWidth,
                                    isMinimized: isMinimized,
                                  ),
                                ),
                              _buildMainContent(colors, isMobile, widget.child),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mobile sidebar overlay
                if (isMobile) _buildSidebarOverlay(colors, sidebarItems),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colors, bool isMobile, TSidebarItem? homeItem, bool isMinimized, List<TSidebarItem> resolvedItems) {
    return Container(
      width: double.infinity,
      padding: isMobile ? const EdgeInsets.symmetric(vertical: 8, horizontal: 16) : const EdgeInsets.fromLTRB(10, 24, 10, 14),
      child: isMobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (Navigator.canPop(context))
                      TButton(
                        type: TButtonType.icon,
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    _buildBreadCrumbs(colors, null, resolvedItems)
                  ],
                ),
                if (widget.showHamburgerMenu)
                  TButton(
                    type: TButtonType.icon,
                    icon: _isMobileSidebarOpen ? Icons.close_rounded : Icons.menu_rounded,
                    size: TButtonSize.md.copyWith(icon: 20),
                    color: colors.onSurface,
                    onTap: _toggleMobileSidebar,
                  )
              ],
            )
          : Row(
              children: [
                if (widget.logo != null) SizedBox(width: widget.width - 20, child: widget.logo!),
                _buildSidebarToggle(colors, isMinimized),
                const SizedBox(width: 10),
                Expanded(child: _buildBreadCrumbs(colors, homeItem, resolvedItems)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    if (widget.profile != null) widget.profile!,
                    if (widget.showThemeToggle) _buildThemeToggle(colors),
                    if (widget.actions != null) ...widget.actions!,
                    if (widget.showLogout) _buildLogoutButton(colors),
                  ],
                ),
                const SizedBox(width: 15),
              ],
            ),
    );
  }

  Widget _buildThemeToggle(ColorScheme colors) {
    return TButton(
      size: TButtonSize.xs.copyWith(icon: 16),
      type: TButtonType.icon,
      icon: Icons.wb_sunny,
      color: Colors.yellow.shade700,
      activeIcon: Icons.nights_stay,
      activeColor: Colors.cyan.shade600,
      active: context.isDarkMode,
      onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
    );
  }

  Widget _buildLogoutButton(ColorScheme colors) {
    return TButton(
      type: TButtonType.icon,
      icon: Icons.logout_rounded,
      size: TButtonSize.xs.copyWith(icon: 16),
      color: colors.onSurfaceVariant,
      onPressed: (_) => widget.onLogout?.call(),
    );
  }

  Widget _buildSidebarToggle(ColorScheme colors, bool isMinimized) {
    final sidebarNotifier = ref.read(sidebarNotifierProvider.notifier);

    return InkWell(
      onTap: sidebarNotifier.toggleSidebar,
      borderRadius: BorderRadius.circular(24),
      child: CircleAvatar(
          radius: 16,
          backgroundColor: colors.surfaceContainerLowest,
          child: Icon(isMinimized ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, size: 20, color: colors.onSurfaceVariant)),
    );
  }

  Widget _buildBreadCrumbs(ColorScheme colors, TSidebarItem? homeItem, List<TSidebarItem> resolvedItems) {
    return TBreadcrumbs(
      items: resolvedItems,
      includeHome: homeItem != null,
      homeLabel: homeItem?.text ?? 'Home',
      homeRoute: homeItem?.route ?? '/',
    );
  }

  Widget _buildMainContent(ColorScheme colors, bool isMobile, Widget child) {
    return Expanded(
      child: DecoratedBox(
        decoration: isMobile
            ? BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.shadow, width: 0.5),
                  bottom: BorderSide(color: colors.shadow, width: 0.5),
                ),
              )
            : BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.outlineVariant, width: 1),
                  left: BorderSide(color: colors.outlineVariant, width: 1),
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
              padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.only(left: 24, right: 24, bottom: 6, top: 16),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ColorScheme colors, List<TSidebarItem> bottomItems) {
    final state = GoRouterState.of(context);
    int currentIndex = -1;
    for (int i = 0; i < bottomItems.length; i++) {
      if (bottomItems[i].containsRoute(state.uri.toString())) {
        currentIndex = i;
        break;
      }
    }

    return TBottomBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < bottomItems.length) {
          final item = bottomItems[index];
          item.tap(context);
        } else {
          _toggleMobileSidebar();
        }
      },
      items: [
        ...bottomItems.map((item) => TBottomBarItem(
              icon: item.icon ?? Icons.circle_outlined,
              label: item.text ?? '',
            )),
        const TBottomBarItem(
          icon: Icons.more_horiz_rounded,
          label: 'More',
        ),
      ],
    );
  }

  Widget _buildSidebarOverlay(ColorScheme colors, List<TSidebarItem> sidebarItems) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Visibility(
          visible: _overlayAnimation.value > 0,
          child: Stack(
            children: [
              // Backdrop
              InkWell(
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
                      color: colors.surface,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 20,
                          offset: Offset(4, 0),
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
                              items: sidebarItems,
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
                              color: colors.surfaceContainer,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 15,
                              runSpacing: 10,
                              children: [
                                if (widget.profile != null) widget.profile!,
                                if (widget.showThemeToggle) _buildThemeToggle(colors),
                                if (widget.actions != null) ...widget.actions!,
                                if (widget.showLogout) _buildLogoutButton(colors),
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
