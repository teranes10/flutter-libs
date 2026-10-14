import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A collapsible section that allows users to show or hide content.
///
/// `TAccordion` provides an expandable panel with a customizable header
/// ([TAccordionHeader]), animated transition, and themed container styling.
class TAccordion extends StatefulWidget {
  /// The title text to display in the header.
  final String? title;

  /// Custom widget for the title.
  final Widget? titleWidget;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Custom widget for the subtitle.
  final Widget? subtitleWidget;

  /// Leading icon before the title. Supports [IconData], HugeIcon, or [Widget].
  final dynamic leading;

  /// Leading icon. Alias for [leading].
  final dynamic icon;

  /// Description shown under the title/subtitle (see [TTile.desc]).
  final String? desc;

  /// Custom widget for the description.
  final Widget? descWidget;

  /// Product/entity thumbnail URL shown as the leading image when no icon is set.
  final String? imageUrl;

  /// Size of the header tile. Defaults to [TTileSize.h5]; use [TTileSize.sm]
  /// to [TTileSize.lg] for product-style headers.
  final TSize size;

  /// Cross-axis alignment of the header tile row.
  final CrossAxisAlignment? crossAxisAlignment;

  /// Stacks the leading icon above the title block (see [TTile.iconOnTop]).
  final bool iconOnTop;

  /// Always-visible widget at the end of the header, before the expand arrow
  /// (e.g. a price tag or status chip).
  final Widget? trailing;

  /// Custom header widget. If provided, overrides default [TAccordionHeader].
  final Widget? header;

  /// Color of the leading icon.
  final Color? iconColor;

  /// Color of the leading icon when hovered.
  final Color? hoveredIconColor;

  /// Color of the leading icon when expanded.
  final Color? expandedIconColor;

  /// Background color of the leading icon container.
  final Color? iconBackgroundColor;

  /// Background color of the leading icon container when hovered.
  final Color? hoveredIconBackgroundColor;

  /// Background color of the leading icon container when expanded.
  final Color? expandedIconBackgroundColor;

  /// Padding inside the leading icon container.
  final EdgeInsetsGeometry? iconPadding;

  /// Border radius of the leading icon container.
  final BorderRadius? iconBorderRadius;

  /// Size of the leading icon.
  final double? iconSize;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Horizontal spacing between the leading icon and title/subtitle.
  final double? headerSpacing;

  /// The content displayed when the accordion is expanded.
  final Widget content;

  /// Theme configuration for the accordion.
  final TAccordionTheme? theme;

  /// Whether the accordion starts in an expanded state.
  final bool initiallyExpanded;

  /// Externally controlled expansion state. When provided, the accordion
  /// becomes controlled: its expanded/collapsed state is driven by this
  /// value instead of internal state, and [onExpansionChanged] must be
  /// used to react to taps (e.g. from [TAccordionGroup]).
  final bool? isExpanded;

  /// Called when the header is tapped, with the next expansion state.
  /// If [isExpanded] is null (uncontrolled), the accordion still toggles
  /// itself internally in addition to invoking this callback.
  final ValueChanged<bool>? onExpansionChanged;

  /// Padding for the header tile.
  final EdgeInsetsGeometry? tilePadding;

  /// Padding for the expanded content.
  final EdgeInsetsGeometry? contentPadding;

  /// Margin around the accordion when collapsed.
  final EdgeInsetsGeometry? margin;

  /// Margin around the accordion when expanded.
  final EdgeInsetsGeometry? expandedMargin;

  /// Whether to display the expand/collapse arrow icon.
  final bool showExpandIcon;

  /// Custom expand/collapse trailing icon widget.
  final Widget? expandIcon;

  /// Optional footer displayed below the content when expanded.
  final Widget? footer;

  /// Optional builder for trailing header actions.
  final Widget Function(BuildContext context, bool isExpanded, VoidCallback toggleExpand)? builder;

  const TAccordion({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.icon,
    this.desc,
    this.descWidget,
    this.imageUrl,
    this.size = TTileSize.h5,
    this.crossAxisAlignment,
    this.iconOnTop = false,
    this.trailing,
    this.header,
    this.iconColor,
    this.hoveredIconColor,
    this.expandedIconColor,
    this.iconBackgroundColor,
    this.hoveredIconBackgroundColor,
    this.expandedIconBackgroundColor,
    this.iconPadding,
    this.iconBorderRadius,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.headerSpacing,
    required this.content,
    this.theme,
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onExpansionChanged,
    this.tilePadding,
    this.contentPadding,
    this.margin,
    this.expandedMargin,
    this.showExpandIcon = true,
    this.expandIcon,
    this.footer,
    this.builder,
  });

  @override
  State<TAccordion> createState() => _TAccordionState();
}

class _TAccordionState extends State<TAccordion> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  bool _isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded ?? widget.initiallyExpanded;
    _controller = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(TAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null && widget.isExpanded != _isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded!;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    final target = !_isExpanded;
    widget.onExpansionChanged?.call(target);
    if (widget.isExpanded != null) return;
    if (_isExpanded != target) {
      setState(() {
        _isExpanded = target;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }

  void _handleTap() {
    _toggleExpand();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accordionTheme = widget.theme ?? context.theme.accordionTheme;

    final resolvedBgColor = accordionTheme.backgroundColor == colors.surface
        ? (TBackgroundColorScope.maybeOf(context) ?? colors.surface)
        : accordionTheme.backgroundColor;

    final resolvedTilePadding = widget.tilePadding ?? accordionTheme.tilePadding;
    final resolvedContentPadding = widget.contentPadding ?? accordionTheme.contentPadding;
    final resolvedMargin = _isExpanded
        ? (widget.expandedMargin ?? accordionTheme.expandedMargin ?? widget.margin ?? accordionTheme.margin ?? EdgeInsets.zero)
        : (widget.margin ?? accordionTheme.margin ?? EdgeInsets.zero);

    final headerContent = widget.header ??
        TAccordionHeader(
          title: widget.title,
          titleWidget: widget.titleWidget,
          subtitle: widget.subtitle,
          subtitleWidget: widget.subtitleWidget,
          desc: widget.desc,
          descWidget: widget.descWidget,
          imageUrl: widget.imageUrl,
          size: widget.size,
          crossAxisAlignment: widget.crossAxisAlignment,
          iconOnTop: widget.iconOnTop,
          leading: widget.leading ?? widget.icon,
          iconColor: widget.iconColor,
          hoveredIconColor: widget.hoveredIconColor,
          expandedIconColor: widget.expandedIconColor,
          iconBackgroundColor: widget.iconBackgroundColor,
          hoveredIconBackgroundColor: widget.hoveredIconBackgroundColor,
          expandedIconBackgroundColor: widget.expandedIconBackgroundColor,
          iconPadding: widget.iconPadding,
          iconBorderRadius: widget.iconBorderRadius,
          iconSize: widget.iconSize,
          titleStyle: widget.titleStyle,
          subtitleStyle: widget.subtitleStyle,
          spacing: widget.headerSpacing,
          isHovered: _isHovered,
          isExpanded: _isExpanded,
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      margin: resolvedMargin,
      child: TCard(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        backgroundColor: resolvedBgColor,
        borderColor: accordionTheme.borderColor,
        borderRadius: BorderRadius.circular(accordionTheme.borderRadius),
        elevation: accordionTheme.elevation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _handleTap,
              onHover: (hovered) {
                setState(() {
                  _isHovered = hovered;
                });
              },
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(accordionTheme.borderRadius),
              child: Padding(
                padding: resolvedTilePadding,
                child: Row(
                  children: [
                    Expanded(child: headerContent),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                      if (widget.showExpandIcon || widget.builder != null) const SizedBox(width: 8),
                    ],
                    if (widget.builder != null) ...[
                      widget.builder!(context, _isExpanded, _toggleExpand),
                      if (widget.showExpandIcon) const SizedBox(width: 8),
                    ],
                    if (widget.showExpandIcon)
                      widget.expandIcon ??
                          RotationTransition(
                            turns: _iconTurns,
                            child: Icon(
                              Icons.expand_more,
                              size: 20,
                              color: _isHovered || _isExpanded ? colors.primary : colors.onSurfaceVariant,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            ClipRect(
              child: AnimatedBuilder(
                animation: _controller.view,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _heightFactor,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: resolvedContentPadding,
                      child: widget.content,
                    ),
                    if (widget.footer != null) widget.footer!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A group of [TAccordion] items where expanding one automatically
/// collapses the others, so at most one item is open at a time.
///
/// Pass the accordions as [children]; `TAccordionGroup` controls their
/// expansion state internally and ignores any `initiallyExpanded`,
/// `isExpanded`, or `onExpansionChanged` set directly on the children.
class TAccordionGroup extends StatefulWidget {
  /// The accordions managed by this group.
  final List<TAccordion> children;

  /// Spacing between consecutive accordion items.
  final double spacing;

  /// Index of the item expanded by default. Pass `null` to start with
  /// all items collapsed.
  final int? initiallyExpandedIndex;

  const TAccordionGroup({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.initiallyExpandedIndex,
  });

  @override
  State<TAccordionGroup> createState() => _TAccordionGroupState();
}

class _TAccordionGroupState extends State<TAccordionGroup> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initiallyExpandedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          _buildItem(i, widget.children[i]),
        ],
      ],
    );
  }

  Widget _buildItem(int index, TAccordion accordion) {
    return TAccordion(
      key: accordion.key,
      title: accordion.title,
      titleWidget: accordion.titleWidget,
      subtitle: accordion.subtitle,
      subtitleWidget: accordion.subtitleWidget,
      desc: accordion.desc,
      descWidget: accordion.descWidget,
      imageUrl: accordion.imageUrl,
      size: accordion.size,
      crossAxisAlignment: accordion.crossAxisAlignment,
      iconOnTop: accordion.iconOnTop,
      trailing: accordion.trailing,
      leading: accordion.leading,
      icon: accordion.icon,
      header: accordion.header,
      iconColor: accordion.iconColor,
      hoveredIconColor: accordion.hoveredIconColor,
      expandedIconColor: accordion.expandedIconColor,
      iconBackgroundColor: accordion.iconBackgroundColor,
      hoveredIconBackgroundColor: accordion.hoveredIconBackgroundColor,
      expandedIconBackgroundColor: accordion.expandedIconBackgroundColor,
      iconPadding: accordion.iconPadding,
      iconBorderRadius: accordion.iconBorderRadius,
      iconSize: accordion.iconSize,
      titleStyle: accordion.titleStyle,
      subtitleStyle: accordion.subtitleStyle,
      headerSpacing: accordion.headerSpacing,
      content: accordion.content,
      theme: accordion.theme,
      tilePadding: accordion.tilePadding,
      contentPadding: accordion.contentPadding,
      margin: accordion.margin,
      expandedMargin: accordion.expandedMargin,
      showExpandIcon: accordion.showExpandIcon,
      expandIcon: accordion.expandIcon,
      footer: accordion.footer,
      builder: accordion.builder,
      isExpanded: _expandedIndex == index,
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedIndex = expanded ? index : null;
        });
      },
    );
  }
}
