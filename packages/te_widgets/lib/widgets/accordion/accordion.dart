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

    return TCard(
      padding: EdgeInsets.zero,
      backgroundColor: accordionTheme.backgroundColor,
      borderRadius: BorderRadius.circular(accordionTheme.borderRadius),
      elevation: accordionTheme.elevation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(accordionTheme.borderRadius),
              bottom: Radius.circular(_isExpanded ? 0 : accordionTheme.borderRadius),
            ),
            child: Padding(
              padding: accordionTheme.tilePadding,
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    Icon(widget.leading, size: 20, color: colors.onSurfaceVariant),
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
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more, size: 20),
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
