import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TAccordion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget content;
  final TAccordionTheme? theme;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? tilePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? expandedMargin;
  final bool showExpandIcon;
  final Widget Function(BuildContext context, bool isExpanded, VoidCallback toggleExpand)? builder;

  const TAccordion({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.content,
    this.theme,
    this.initiallyExpanded = false,
    this.tilePadding,
    this.contentPadding,
    this.margin,
    this.expandedMargin,
    this.showExpandIcon = true,
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
                    if (widget.leading != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isHovered || _isExpanded ? colors.primaryContainer.withAlpha(128) : colors.onSurface.withAlpha(13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.leading,
                          size: 20,
                          color: _isHovered || _isExpanded ? colors.primary : colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colors.onSurface,
                            ),
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.builder != null) ...[
                      widget.builder!(context, _isExpanded, _toggleExpand),
                      if (widget.showExpandIcon) const SizedBox(width: 8),
                    ],
                    if (widget.showExpandIcon)
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
                child: Container(
                  padding: resolvedContentPadding,
                  child: widget.content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
