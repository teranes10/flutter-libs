import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A uniform page wrapper widget used across popups, details pages, and fullscreen modals on mobile.
class TPageWrapper extends StatefulWidget {
  /// The main content of the page.
  final Widget child;

  /// Optional title displayed in the AppBar.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subTitle;

  /// Optional image URL to display next to the title.
  final String? imageUrl;

  /// Optional description displayed below the title area.
  final String? description;

  /// Optional callback for the back button in the AppBar.
  final VoidCallback? onBackPressed;

  /// Optional actions to display in the AppBar.
  final List<Widget>? actions;

  /// Whether the page wrapper should shrink wrap its content vertically.
  final bool shrinkWrap;

  final EdgeInsets padding;
  final EdgeInsets contentPadding;

  /// Optional background color for the entire wrapper.
  /// Defaults to [ColorScheme.surface] when null.
  final Color? backgroundColor;

  /// Creates a page wrapper.
  const TPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.subTitle,
    this.imageUrl,
    this.description,
    this.onBackPressed,
    this.actions,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.backgroundColor,
  });

  @override
  State<TPageWrapper> createState() => _TPageWrapperState();
}

class _TPageWrapperState extends State<TPageWrapper> {
  late final ScrollController _scrollController;
  final ValueNotifier<bool> _isScrolled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (_isScrolled.value != scrolled) {
      _isScrolled.value = scrolled;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isScrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final colors = context.colors;
    final effectiveBg = widget.backgroundColor ?? context.getBackgroundColor(colors.surface);

    final bool hasHeaderInfo = widget.title != null || widget.subTitle != null || widget.imageUrl != null;
    final bool showAppBar = hasHeaderInfo || widget.onBackPressed != null || widget.actions != null;

    Widget? buildTitleWidget() {
      if (!hasHeaderInfo) return null;

      if (widget.subTitle == null && widget.imageUrl == null) {
        return Text(widget.title ?? '');
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TImage(
                url: widget.imageUrl,
                size: 60,
                color: colors.surfaceContainerLow,
                disabled: true,
                border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (widget.subTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subTitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    double? toolbarHeight;
    if (hasHeaderInfo) {
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        toolbarHeight = 80.0;
      } else if (widget.subTitle != null) {
        toolbarHeight = 68.0;
      }
    }

    Widget buildAppBar() {
      final titleWidget = buildTitleWidget();

      return ValueListenableBuilder<bool>(
        valueListenable: _isScrolled,
        builder: (context, isScrolled, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: isScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black54.withAlpha(20),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: AppBar(
              toolbarHeight: toolbarHeight,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              scrolledUnderElevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              leading: !isDesktop && widget.onBackPressed != null
                  ? Padding(
                      padding: EdgeInsets.only(left: widget.padding.left),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBackPressed,
                      ),
                    )
                  : null,
              titleSpacing: (!isDesktop && widget.onBackPressed != null) ? 0.0 : widget.padding.left,
              title: titleWidget,
              centerTitle: false,
              actions: [
                if (widget.actions != null) ...widget.actions!,
                if (isDesktop && widget.onBackPressed != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onBackPressed,
                  ),
                SizedBox(width: widget.padding.right),
              ],
            ),
          );
        },
      );
    }

    final appBarWidget = showAppBar ? buildAppBar() : null;

    final descriptionWidget = widget.description != null && widget.description!.isNotEmpty
        ? Container(
            padding: EdgeInsets.only(
              left: widget.padding.left,
              right: widget.padding.right,
            ),
            child: Text(
              widget.description!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          )
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShrinkWrap = widget.shrinkWrap || !constraints.hasBoundedHeight;

        if (shouldShrinkWrap) {
          final appBarHeight = appBarWidget != null ? (toolbarHeight ?? kToolbarHeight) : 0.0;

          // Column shrink-wraps naturally. Inside, we use a nested Stack only for
          // the scroll area so the AppBar (positioned absolutely at the top of
          // that Stack) always paints above the scrollable content.
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stack wraps the AppBar + scroll content so appbar z-order is correct
              Flexible(
                child: Stack(
                  children: [
                    // Scroll content — top-padded to avoid being hidden behind AppBar
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: appBarHeight),
                          if (descriptionWidget != null) descriptionWidget,
                          Padding(
                            padding: widget.contentPadding,
                            child: widget.child,
                          ),
                        ],
                      ),
                    ),
                    // AppBar painted last — always on top of scroll content
                    if (appBarWidget != null) Positioned(top: 0, left: 0, right: 0, child: appBarWidget),
                  ],
                ),
              ),
            ],
          );
        }

        // For the Scaffold path: put the AppBar in a Stack inside the body
        // so it paints on top of the scrollable content and the shadow is visible.
        final appBarHeight = toolbarHeight ?? kToolbarHeight;

        return Scaffold(
          backgroundColor: effectiveBg,
          body: SafeArea(
            child: Stack(
              children: [
                // Scrollable body padded so content starts below the AppBar
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (appBarWidget != null) SizedBox(height: appBarHeight),
                        if (descriptionWidget != null) descriptionWidget,
                        Padding(
                          padding: widget.contentPadding,
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),
                // AppBar on top so its shadow always renders above scroll content
                if (appBarWidget != null) Positioned(top: 0, left: 0, right: 0, child: appBarWidget),
              ],
            ),
          ),
        );
      },
    );
  }
}
