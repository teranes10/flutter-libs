import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Small single-line hint shown next to a compact/icon-only trigger that
/// has nothing to expand into (a leaf item with text but no children).
///
/// Generalized from `TSidebarTooltip`, which used to be sidebar-only —
/// this was the one genuinely missing piece on the dropdown side, since
/// `TDropdown` always assumed there was a list of items to show. It's now
/// part of the shared engine (`TMenuRootTrigger` reaches for it
/// automatically when an item has no visible children).
class TMenuTooltip extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const TMenuTooltip({
    super.key,
    required this.text,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<TMenuTooltip> createState() => _TMenuTooltipState();
}

class _TMenuTooltipState extends State<TMenuTooltip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.animationDuration, vsync: this);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Opacity(opacity: _opacity.value, child: child),
      ),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: colors.surface,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onSurface),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
