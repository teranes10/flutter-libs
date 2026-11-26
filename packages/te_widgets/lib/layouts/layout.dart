import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/layouts/widgets/mobile_sidebar.dart';
import 'package:te_widgets/te_widgets.dart';

/// App layout: sidebar (full / minified / hidden) plus a top bar with breadcrumbs.
///
/// The profile lives in the top bar or pinned in the sidebar, following the user's [TProfilePosition] choice
/// (changeable in the theme customizer) or [profilePosition] if given. With the profile in the sidebar the top bar
/// shrinks to a compact row: breadcrumbs on the left, [topBarCenter] in the middle, [topBarTrailing] on the right.
class TLayout extends ConsumerStatefulWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? minifiedLogo;

  /// Context switcher: below the logo in the sidebar, after the logo in the top bar when there is no sidebar.
  /// See [TSwitcher].
  final TSwitcherBuilder? switcher;
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

  /// Extra details in the middle of the desktop top bar; the bar grows to fit them.
  final Widget? topBarCenter;

  /// Extra details at the right of the desktop top bar (before the actions); the bar grows to fit them.
  final Widget? topBarTrailing;

  /// Forces a profile position instead of following the saved preference.
  final TProfilePosition? profilePosition;

  /// Show the profile under the logo instead of pinned at the bottom (sidebar position only).
  final bool showProfileBelowLogo;

  const TLayout({
    super.key,
    this.items = const [],
    this.logo,
    this.minifiedLogo,
    this.switcher,
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
    this.topBarCenter,
    this.topBarTrailing,
    this.profilePosition,
    this.showProfileBelowLogo = false,
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
    final isMobile = !context.isDesktop;
    final cardColor = context.scaffoldBackgroundColor;
    final savedPosition = ref.watch(themeNotifierProvider.select((t) => t.profilePosition));
    final sidebarMode = ref.watch(sidebarNotifierProvider);
    // Without a sidebar (top-nav mode) there's nowhere else to put the profile.
    final profileInSidebar =
        widget.profile != null && (widget.profilePosition ?? savedPosition) == TProfilePosition.sidebar && !sidebarMode.isNone;
    final topBarProfile = profileInSidebar ? null : widget.profile;

    final resolved = resolveLayoutItems(
      context,
      TSidebarItemsResolver.resolve(widget.items),
      isMobile: isMobile,
      showHamburgerMenu: widget.showHamburgerMenu,
    );

    Widget buildSidebar(TSidebarMode mode) => LayoutDesktopSidebar(
          showDivider: false,
          backgroundColor: TGlassStyle.resolve(context) != null
              ? Colors.transparent
              // Light mode: a touch dimmer than the surface, following custom surface colours too.
              : colors.brightness == Brightness.light
                  ? Color.alphaBlend(colors.onSurface.withValues(alpha: 0.02), colors.surface)
                  : colors.surface,
          // The sidebar floats on its own, so its header doesn't follow the top bar height.
          headerHeight: 56,
          profileBelowLogo: widget.showProfileBelowLogo,
          switcher: widget.switcher,
          profile: !profileInSidebar
              ? null
              : ({required bool minified}) => LayoutProfileButton(
                    expand: true,
                    minified: minified,
                    profile: widget.profile!,
                    showThemeToggle: widget.showThemeToggle,
                    showColorToggle: widget.showColorToggle,
                    showLogout: widget.showLogout,
                    onLogout: widget.onLogout,
                    actions: widget.actions,
                  ),
          items: resolved.sidebarItems,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          minifiedWidth: widget.minifiedWidth,
          mode: mode,
          theme: widget.sidebarTheme,
          logo: widget.logo,
          minifiedLogo: widget.minifiedLogo,
          onToggle: () =>
              ref.read(sidebarNotifierProvider.notifier).setMode(mode == TSidebarMode.full ? TSidebarMode.minified : TSidebarMode.full),
        );

    return Scaffold(
      backgroundColor: cardColor,
      bottomNavigationBar: isMobile && resolved.bottomBarItems.isNotEmpty
          ? LayoutBottomBar(
              items: resolved.bottomBarItems,
              logo: widget.minifiedLogo ?? widget.logo,
              onOpenMore: _toggleMobileSidebar,
            )
          : null,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _background(
                context,
                base: cardColor,
                child: isMobile
                    ? Column(
                        children: [
                          LayoutMobileTopBar(
                            resolvedItems: resolved.allItems,
                            showHamburgerMenu: widget.showHamburgerMenu || resolved.bottomBarItems.isEmpty,
                            isSidebarOpen: _isMobileSidebarOpen,
                            onToggleSidebar: _toggleMobileSidebar,
                          ),
                          Expanded(child: LayoutMainContent(isMobile: true, backgroundColor: Colors.transparent, child: widget.child)),
                        ],
                      )
                    : Builder(
                        builder: (context) {
                          final topBar = Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.outlineVariant.withAlpha(160)))),
                            child: LayoutDesktopTopBar(
                              logo: widget.logo,
                              minifiedLogo: widget.minifiedLogo,
                              switcher: widget.switcher,
                              homeItem: resolved.homeItem,
                              resolvedItems: resolved.allItems,
                              sidebarItems: resolved.sidebarItems,
                              profile: topBarProfile,
                              // With the profile in the sidebar its menu owns these; the top bar keeps only breadcrumbs + details.
                              showThemeToggle: !profileInSidebar && widget.showThemeToggle,
                              showColorToggle: !profileInSidebar && widget.showColorToggle,
                              actions: profileInSidebar ? null : widget.actions,
                              showFullscreenToggle: widget.showFullscreenToggle,
                              showLogout: !profileInSidebar && widget.showLogout,
                              onLogout: widget.onLogout,
                              sidebarTheme: widget.sidebarTheme,
                              centerContent: widget.topBarCenter,
                              trailingContent: widget.topBarTrailing,
                            ),
                          );

                          final content = Expanded(
                            child: LayoutMainContent(
                              isMobile: false,
                              backgroundColor: Colors.transparent,
                              child: widget.child,
                            ),
                          );

                          final sidebar = buildSidebar(sidebarMode);
                          return Padding(
                            // No vertical padding here: the top bar sits tighter to the edge than the floating sidebar.
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(children: [
                              if (!sidebarMode.isNone)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: _floatingPanel(context, sidebar),
                                ),
                              if (!sidebarMode.isNone) const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                                  child: Column(children: [topBar, content]),
                                ),
                              ),
                            ]),
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

const _floatRadius = 16.0;

/// Fill alpha of the glass sidebar (0-255): denser than a card so the panel stands apart from the backdrop.
const _glassPanelAlpha = 40;

/// Floating card around the sidebar: a frosted pane in glass mode, else rounded, bordered and softly shadowed.
Widget _floatingPanel(BuildContext context, Widget child) {
  final colors = context.colors;
  final radius = BorderRadius.circular(_floatRadius);
  final glass = TGlassStyle.resolve(context);
  if (glass != null) {
    return TGlassSurface(style: glass, borderRadius: radius, color: colors.surface, alpha: _glassPanelAlpha, child: child);
  }
  return DecoratedBox(
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: radius,
      border: Border.all(color: colors.outlineVariant.withAlpha(160)),
      boxShadow: [BoxShadow(color: colors.shadow.withAlpha(18), blurRadius: 12, offset: const Offset(0, 2))],
    ),
    child: ClipRRect(borderRadius: radius, child: child),
  );
}

Widget _background(BuildContext context, {required Color base, required Widget child}) {
  // Glass mode swaps the flat base for a flowing colourful gradient the glass surfaces can blur.
  if (TGlassStyle.resolve(context) != null) return TGlassBackground(child: child);
  return _DotCanvas(child: child);
}

/// Flat grey ground with a regular grid of slightly darker dots, like a design canvas.
class _DotCanvas extends StatelessWidget {
  final Widget child;
  const _DotCanvas({required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ground = dark ? const Color(0xFF16181C) : const Color(0xFFF6F7F9);
    final dot = dark ? const Color(0xFF2A2D33) : const Color(0xFFDFE2E6);
    return CustomPaint(painter: _DotPainter(ground, dot), child: child);
  }
}

class _DotPainter extends CustomPainter {
  final Color ground;
  final Color dot;
  const _DotPainter(this.ground, this.dot);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);
    const gap = 20.0;
    final points = <Offset>[
      for (double y = gap / 2; y < size.height; y += gap)
        for (double x = gap / 2; x < size.width; x += gap) Offset(x, y),
    ];
    canvas.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = dot
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.ground != ground || old.dot != dot;
}
