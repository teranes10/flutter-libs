import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCloseIcon extends StatefulWidget {
  final VoidCallback onClose;
  final double? size;

  const TCloseIcon({super.key, required this.onClose, this.size});

  @override
  State<TCloseIcon> createState() => TCloseIconState();
}

class TCloseIconState extends State<TCloseIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Icon(
          Icons.cancel_outlined,
          color: _isHovering ? colors.error : colors.surfaceContainerLowest,
          size: widget.size ?? 20,
        ),
      ),
    );
  }
}
