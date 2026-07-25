import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TAccordion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget content;
  final TAccordionTheme? theme;
  final bool initiallyExpanded;

  const TAccordion({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.content,
    this.theme,
    this.initiallyExpanded = false,
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
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accordionTheme = widget.theme ?? TAccordionTheme.defaultTheme(colors);

    final resolvedBgColor = accordionTheme.backgroundColor == colors.surface
        ? (TBackgroundColorScope.maybeOf(context) ?? colors.surface)
        : accordionTheme.backgroundColor;

    return TCard(
      padding: EdgeInsets.zero,
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(accordionTheme.borderRadius),
              bottom: Radius.circular(_isExpanded ? 0 : accordionTheme.borderRadius),
            ),
            child: Padding(
              padding: accordionTheme.tilePadding,
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _isHovered ? colors.primaryContainer.withAlpha(128) : colors.onSurface.withAlpha(13),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(
                        widget.leading,
                        size: 20,
                        color: _isHovered ? colors.primary : colors.onSurfaceVariant,
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
                            color: _isHovered ? colors.onSurfaceVariant : colors.onSurface,
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
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: _isHovered ? colors.primary : colors.onSurfaceVariant,
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
                margin: accordionTheme.padding,
                child: widget.content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
