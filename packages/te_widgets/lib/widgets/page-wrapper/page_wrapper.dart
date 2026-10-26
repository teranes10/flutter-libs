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

  /// Optional status/attribute chips ([TChip], [TBadge]) shown below the
  /// subtitle and above [description] / [itemInfo].
  ///
  /// Leave their `size` null so they follow the subtitle font size.
  final List<Widget>? highlights;

  /// Optional key-value information to display below the description.
  final List<TKeyValue>? itemInfo;

  /// Layout presentation mode for [itemInfo]. If provided, takes precedence over [itemInfoGridInline].
  final TKeyValueMode? itemInfoMode;

  /// Whether to display key and value inline in grid layout (Key: Value) for itemInfo. Defaults to true.
  final bool itemInfoGridInline;

  /// Whether the page wrapper should shrink wrap its content vertically.
  final bool shrinkWrap;

  /// Padding for the header area.
  final EdgeInsets? padding;

  /// Padding for the scrollable content area.
  final EdgeInsets? contentPadding;

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
    this.highlights,
    this.itemInfo,
    this.itemInfoMode,
    this.itemInfoGridInline = true,
    this.shrinkWrap = false,
    this.padding,
    this.contentPadding,
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
    final hasHighlights = widget.highlights != null && widget.highlights!.isNotEmpty;

    if (!hasMainRow && !hasDescription && !hasItemInfo && !hasHighlights) {
      return const SizedBox.shrink();
    }

    Widget? leadingWidget;
    if (!isDesktop && widget.onBackPressed != null) {
      leadingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TButton(
            type: TButtonType.text,
            size: TSize.md.copyWith(icon: 32, hPad: 3),
            shape: TButtonShape.circle,
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.onSurfaceVariant,
            onTap: widget.onBackPressed,
          ),
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
            const SizedBox(width: 3),
            TImage(
              url: widget.imageUrl,
              size: widget.subTitle != null ? 45 : 36,
              color: colors.surfaceContainerLow,
              disabled: true,
              border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ],
        ],
      );
    }

    final titleFontSize = isDesktop ? 18.0 : 15.0;
    final titleFontWeight = isDesktop ? FontWeight.w500 : FontWeight.w400;
    final subtitleFontSize = isDesktop ? 12.0 : 11.0;
    final subtitleGap = isDesktop ? 2.0 : 0.0;
    final descFontSize = isDesktop ? 12.0 : 11.0;
    final descGap = isDesktop ? 10.0 : 8.0;
    final iconSize = widget.subTitle != null ? 52.0 : 42.0;

    final hasText = widget.title != null || widget.subTitle != null;

    final titleSubtitleRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          SizedBox(width: isDesktop ? 12 : 20),
        ] else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
          TImage(
            url: widget.imageUrl,
            size: iconSize,
            color: colors.surfaceContainerLow,
            disabled: true,
            border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
        ],
        if (hasText)
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: TextStyle(fontSize: titleFontSize, fontWeight: titleFontWeight, color: colors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.subTitle != null) ...[
                  SizedBox(height: subtitleGap),
                  Text(
                    widget.subTitle!,
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    final hasDescriptionOrValues = hasDescription || hasItemInfo || hasHighlights;

    // Only the title/subtitle line goes beside the trailing actions in
    // TAlignedRow — description/itemInfo are appended below as a separate
    // full-width block so a long description can't push the close button
    // off the title row (TAlignedRow wraps based on the whole left item).
    final descriptionAndInfoBlock = !hasDescriptionOrValues
        ? null
        : Padding(
            // Line the description and info up with the back arrow glyph, not the button's edge.
            padding: EdgeInsets.only(left: leadingWidget != null ? 12 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHighlights) ...[
                  THighlights(items: widget.highlights!, fontSize: subtitleFontSize),
                  if (hasDescription || hasItemInfo) const SizedBox(height: 12),
                ],
                if (hasDescription)
                  Text(
                    widget.description!,
                    style: TextStyle(fontSize: descFontSize, fontWeight: FontWeight.w400, color: colors.onSurfaceVariant),
                  ),
                if (hasItemInfo) ...[
                  if (hasDescription) const SizedBox(height: 24),
                  TKeyValueSection(
                    values: widget.itemInfo!,
                    mode: widget.itemInfoMode ?? (widget.itemInfoGridInline ? TKeyValueMode.inlineFlow : TKeyValueMode.stackedFlow),
                    vSpacing: isDesktop ? null : (widget.itemInfoGridInline ? 8 : 10),
                  ),
                ],
              ],
            ),
          );

    final trailingActions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );

    final hasTrailingActions = widget.actions != null && widget.actions!.isNotEmpty || (isDesktop && widget.onBackPressed != null);

    final effectivePadding = widget.padding ??
        EdgeInsets.only(
          left: isDesktop ? 16 : 8,
          right: isDesktop ? 16 : 8,
          top: isDesktop ? 16 : 12,
          bottom: isDesktop ? 16 : 4,
        );

    final titleRow = hasTrailingActions
        ? TAlignedRow(
            moveAllToSecondRow: true,
            wrapperModeThreshold: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            rowSpacing: 3,
            left: [titleSubtitleRow],
            right: [trailingActions],
          )
        : titleSubtitleRow;

    return Padding(
      padding: effectivePadding,
      child: descriptionAndInfoBlock == null
          ? titleRow
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleRow,
                SizedBox(height: descGap),
                descriptionAndInfoBlock,
              ],
            ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors, bool isDark, bool isDesktop, bool shouldShrinkWrap) {
    final effectiveContentPadding = widget.contentPadding ??
        EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : 12,
          horizontal: isDesktop ? 16 : 12,
        );

    final scrollView = SingleChildScrollView(
      controller: _scrollController,
      padding: effectiveContentPadding,
      child: widget.child,
    );

    if (shouldShrinkWrap) {
      // Rendered outside the Stack below: a Stack sizes non-positioned
      // children using the loose constraints it's handed, and a
      // SingleChildScrollView greedily fills those instead of shrinking to
      // its child's intrinsic size — that's what caused the oversized empty
      // area under shrink-wrapped dialog content.
      return scrollView;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll();
        return false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: scrollView),
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
    final isDark = context.isDarkMode;
    final colors = context.colors;
    final effectiveBg = widget.backgroundColor ?? context.getBackgroundColor(colors.surface);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = context.isDesktop;
        final shouldShrinkWrap = widget.shrinkWrap || !constraints.hasBoundedHeight;
        final headerWidget = _buildHeader(context, colors, isDark, isDesktop);
        final footerWidget = _buildFooter(context, colors, isDark);

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
                  child: _buildContent(context, colors, isDark, isDesktop, true),
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
                  child: _buildContent(context, colors, isDark, isDesktop, false),
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
