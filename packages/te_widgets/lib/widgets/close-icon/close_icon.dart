import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Icon(
          Icons.cancel_outlined,
          color: _isHovering ? AppColors.danger.shade400 : AppColors.grey.shade300,
          size: widget.size ?? 20,
        ),
      ),
    );
  }
}
