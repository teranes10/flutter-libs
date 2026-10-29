import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/layouts/widgets/mobile_sidebar.dart';
import 'package:te_widgets/te_widgets.dart';

class TLayout extends ConsumerStatefulWidget {
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

  const TLayout({
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
  ConsumerState<TLayout> createState() => _TLayoutState();
}

class _TLayoutState extends ConsumerState<TLayout> with SingleTickerProviderStateMixin {
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

    final resolved = _resolveLayoutItems(
      context,
      TSidebarItemsResolver.resolve(widget.items),
      isMobile: isMobile,
      showHamburgerMenu: widget.showHamburgerMenu,
    );

    return Scaffold(
      backgroundColor: theme.layoutFrame,
      bottomNavigationBar: isMobile && resolved.bottomBarItems.isNotEmpty
          ? _LayoutBottomBar(
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
                  color: colors.surface.adaptiveContrast(context, 0.007),
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
                          Expanded(child: _MainContent(isMobile: true, child: widget.child)),
                        ],
                      )
                    : Builder(
                        builder: (context) {
                          final sidebarMode = ref.watch(sidebarNotifierProvider);

                          return Row(
                            children: [
                              // ── Sidebar (full height) ──────────────────────
                              Sidebar(
                                items: resolved.sidebarItems,
                                minWidth: widget.minWidth,
                                maxWidth: widget.maxWidth,
                                minifiedWidth: widget.minifiedWidth,
                                mode: sidebarMode,
                                theme: widget.sidebarTheme,
                                header: widget.logo != null
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                        child: widget.logo!,
                                      )
                                    : null,
                                minifiedHeader: widget.minifiedLogo != null
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                                        child: widget.minifiedLogo!,
                                      )
                                    : null,
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
                                    Expanded(child: _MainContent(isMobile: false, child: widget.child)),
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

// ─────────────────────────────────────────────────────────────────────────
// Item resolution (pure, unit-testable)
// ─────────────────────────────────────────────────────────────────────────

@immutable
class _ResolvedLayoutItems {
  const _ResolvedLayoutItems({
    required this.allItems,
    required this.sidebarItems,
    required this.bottomBarItems,
    required this.homeItem,
  });

  final List<TSidebarItem> allItems;
  final List<TSidebarItem> sidebarItems;
  final List<TSidebarItem> bottomBarItems;
  final TSidebarItem? homeItem;
}

_ResolvedLayoutItems _resolveLayoutItems(
  BuildContext context,
  List<TSidebarItem> resolvedItems, {
  required bool isMobile,
  required bool showHamburgerMenu,
}) {
  TSidebarItem? homeItem;
  final bottomBarCandidates = <TSidebarItem>[];

  for (final item in resolvedItems) {
    if (item.home) homeItem = item;
    if (item.bottomBarPosition != null && !item.isHiddenIn(context)) bottomBarCandidates.add(item);
  }

  final bottomBarItems = <TSidebarItem>[];
  if (homeItem != null && !homeItem.isHiddenIn(context) && (homeItem.children?.isEmpty ?? true)) bottomBarItems.add(homeItem);

  if (bottomBarCandidates.isEmpty && resolvedItems.isNotEmpty) {
    final slotCount = showHamburgerMenu ? 5 : 4;
    bottomBarItems.addAll(
      resolvedItems
          .where((item) => item != homeItem && !item.isHiddenIn(context) && (item.children?.isEmpty ?? true))
          .take(slotCount - bottomBarItems.length),
    );
  } else {
    bottomBarCandidates.sort((a, b) => a.bottomBarPosition!.compareTo(b.bottomBarPosition!));
    bottomBarItems.addAll(bottomBarCandidates.take(4 - bottomBarItems.length));
  }

  final sidebarItems = isMobile ? resolvedItems.where((item) => !bottomBarItems.contains(item)).toList() : resolvedItems;

  return _ResolvedLayoutItems(
    allItems: resolvedItems,
    sidebarItems: sidebarItems,
    bottomBarItems: bottomBarItems,
    homeItem: homeItem,
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Main content + bottom bar
// ─────────────────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  const _MainContent({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = colors.surface;

    return TBackgroundColorScope(
      backgroundColor: background,
      child: DecoratedBox(
        decoration: isMobile
            ? BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(color: colors.shadow, width: 0.5),
                  bottom: BorderSide(color: colors.shadow, width: 0.5),
                ),
              )
            : BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(color: colors.outlineVariant, width: 1),
                  left: BorderSide(color: colors.outlineVariant, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-2, -4),
                    blurRadius: 12,
                    spreadRadius: -6,
                    color: colors.outline.withAlpha(50),
                  )
                ],
              ),
        child: Column(
          children: [
            SizedBox(height: isMobile ? 4 : 8),
            Expanded(
              child: Padding(
                padding: isMobile
                    ? const EdgeInsets.symmetric(vertical: 4, horizontal: 6)
                    : const EdgeInsets.only(left: 20, right: 6, bottom: 6, top: 14),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutBottomBar extends StatelessWidget {
  const _LayoutBottomBar({required this.items, required this.onOpenMore, this.logo});

  final List<TSidebarItem> items;
  final Widget? logo;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (items.length == 1) return _buildSingleItemBar(context, currentRoute);

    var currentIndex = -1;
    for (var i = 0; i < items.length; i++) {
      if (items[i].containsRoute(currentRoute)) {
        currentIndex = i;
        break;
      }
    }

    return TBottomBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < items.length) {
          items[index].tap(context);
        } else {
          onOpenMore();
        }
      },
      items: [
        for (final item in items) TBottomBarItem(icon: item.icon ?? HugeIcons.strokeRoundedCircle, label: item.text ?? ''),
        const TBottomBarItem(icon: HugeIcons.strokeRoundedMoreHorizontal, label: 'More'),
      ],
    );
  }

  /// One qualified item: logo on the left, item in the center, "More" on the right.
  Widget _buildSingleItemBar(BuildContext context, String currentRoute) {
    final colors = context.colors;
    final item = items.first;
    final isActive = item.containsRoute(currentRoute);
    final contentColor = isActive ? colors.primary : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (logo != null)
                    SizedBox(
                      height: 32,
                      child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: logo),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () => item.tap(context),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TIcon.raw(item.icon ?? HugeIcons.strokeRoundedCircle, color: contentColor, size: 24),
                    const SizedBox(height: 4),
                    Text(item.text ?? '',
                        style: TextStyle(color: contentColor, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onOpenMore,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TIcon.raw(HugeIcons.strokeRoundedMoreHorizontal, color: colors.onSurfaceVariant, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
