import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A uniform page wrapper widget used across popups, details pages, and fullscreen modals on mobile.
///
/// Provides a modern elevated content layout with sticky header and footer,
/// and dynamic vertical edge shadows as content scrolls.
class TPageWrapper extends StatefulWidget {
  /// The main content of the page.
  final Widget child;

  /// Optional title displayed in the header.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subTitle;

  /// Optional image URL to display next to the title.
  final String? imageUrl;

  /// Optional description displayed below the title area.
  final String? description;

  /// Optional callback for the back/close button in the header.
  final VoidCallback? onBackPressed;

  /// Optional actions to display in the header.
  final List<Widget>? actions;

  /// Optional key-value information to display below the description.
  final List<TKeyValue>? itemInfo;

  /// Whether to display key and value inline in grid layout (Key: Value) for itemInfo. Defaults to true.
  final bool itemInfoGridInline;

  /// Whether the page wrapper should shrink wrap its content vertically.
  final bool shrinkWrap;

  /// Padding for the header area.
  final EdgeInsets padding;

  /// Padding for the scrollable content area.
  final EdgeInsets contentPadding;

  /// Optional background color for the entire wrapper.
  /// Defaults to [ColorScheme.surface] when null.
  final Color? backgroundColor;

  /// Optional bottom sticky footer widget.
  final Widget? footer;

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
    this.itemInfo,
    this.itemInfoGridInline = true,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.backgroundColor,
    this.footer,
  });

  @override
  State<TPageWrapper> createState() => _TPageWrapperState();
}

class _TPageWrapperState extends State<TPageWrapper> {
  late final ScrollController _scrollController;
  final ValueNotifier<bool> _canScrollUp = ValueNotifier(false);
  final ValueNotifier<bool> _canScrollDown = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;
    final pos = _scrollController.position;
    final canUp = pos.pixels > 0;
    final canDown = pos.pixels < (pos.maxScrollExtent - 1);

    if (_canScrollUp.value != canUp) {
      _canScrollUp.value = canUp;
    }
    if (_canScrollDown.value != canDown) {
      _canScrollDown.value = canDown;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isDark, bool isDesktop) {
    final hasMainRow = widget.title != null ||
        widget.subTitle != null ||
        widget.imageUrl != null ||
        widget.onBackPressed != null ||
        widget.actions != null;

    final hasDescription = widget.description != null && widget.description!.isNotEmpty;
    final hasItemInfo = widget.itemInfo != null && widget.itemInfo!.isNotEmpty;

    if (!hasMainRow && !hasDescription && !hasItemInfo) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasMainRow)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isDesktop && widget.onBackPressed != null) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onBackPressed,
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: TImage(
                      url: widget.imageUrl,
                      size: widget.subTitle != null ? 52 : 42,
                      color: colors.surfaceContainerLow,
                      disabled: true,
                      border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (widget.subTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subTitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.actions != null) ...widget.actions!,
                if (isDesktop && widget.onBackPressed != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onBackPressed,
                  ),
                ],
              ],
            ),
          if (hasDescription) ...[
            if (hasMainRow) const SizedBox(height: 8),
            Text(
              widget.description!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
          if (hasItemInfo) ...[
            const SizedBox(height: 10),
            TKeyValueSection(
              values: widget.itemInfo!,
              theme: context.theme.keyValueTheme.copyWith(
                gridInline: widget.itemInfoGridInline,
                valueStyle: context.theme.keyValueTheme.valueStyle.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                keyStyle: context.theme.keyValueTheme.keyStyle.copyWith(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
                labelStyle: context.theme.keyValueTheme.labelStyle.copyWith(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors, bool isDark, bool shouldShrinkWrap) {
    final scrollView = SingleChildScrollView(
      controller: _scrollController,
      padding: widget.contentPadding,
      child: widget.child,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll();
        return false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (shouldShrinkWrap) scrollView else Positioned.fill(child: scrollView),
          // Top vertical shadow (casts downward when scrolled down from top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _canScrollUp,
              builder: (context, canScrollUp, _) {
                return IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: canScrollUp ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withAlpha(isDark ? 80 : 35),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom vertical shadow (casts upward when content can scroll further down)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _canScrollDown,
              builder: (context, canScrollDown, _) {
                return IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: canScrollDown ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withAlpha(isDark ? 80 : 35),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFooter(BuildContext context, ColorScheme colors, bool isDark) {
    if (widget.footer == null) return null;

    final effectiveBg = widget.backgroundColor ?? context.getBackgroundColor(colors.surface);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
      ),
      child: widget.footer!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isDark = context.isDarkMode;
    final colors = context.colors;
    final effectiveBg = widget.backgroundColor ?? context.getBackgroundColor(colors.surface);

    final headerWidget = _buildHeader(context, colors, isDark, isDesktop);
    final footerWidget = _buildFooter(context, colors, isDark);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShrinkWrap = widget.shrinkWrap || !constraints.hasBoundedHeight;

        if (shouldShrinkWrap) {
          return Material(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerWidget,
                Flexible(
                  child: _buildContent(context, colors, isDark, true),
                ),
                if (footerWidget != null) footerWidget,
              ],
            ),
          );
        }

        return Material(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(12),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerWidget,
                Expanded(
                  child: _buildContent(context, colors, isDark, false),
                ),
                if (footerWidget != null) footerWidget,
              ],
            ),
          ),
        );
      },
    );
  }
}
