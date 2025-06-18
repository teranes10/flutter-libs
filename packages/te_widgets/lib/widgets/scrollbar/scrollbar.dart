import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class TScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final bool isHorizontal;
  final bool thumbVisibility;

  const TScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.isHorizontal = false,
    this.thumbVisibility = true,
  });

  @override
  State<TScrollbar> createState() => _TScrollbarState();
}

class _TScrollbarState extends State<TScrollbar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: RawScrollbar(
        controller: widget.controller,
        scrollbarOrientation: widget.isHorizontal ? ScrollbarOrientation.bottom : ScrollbarOrientation.right,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: true,
        interactive: true,
        thickness: 8.0,
        radius: const Radius.circular(8.0),
        thumbColor: _isHovered ? AppColors.grey.shade200 : AppColors.grey.shade50.withAlpha(200),
        trackColor: Colors.transparent,
        trackBorderColor: Colors.transparent,
        crossAxisMargin: 0.0,
        mainAxisMargin: 0.0,
        minThumbLength: 36.0,
        child: widget.child,
      ),
    );
  }
}
