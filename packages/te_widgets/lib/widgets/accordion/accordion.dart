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
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      value: widget.initiallyExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    final target = !_isExpanded;
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
          spacing: widget.headerSpacing ?? 12.0,
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
