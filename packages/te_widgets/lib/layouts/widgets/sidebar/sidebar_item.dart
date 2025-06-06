import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:go_router/go_router.dart';

class SidebarItem extends StatefulWidget {
  final IconData? icon;
  final String? text;
  final String? routeName;
  final Widget? child;
  final bool active;
  final VoidCallback? onTap;
  final Color? hoverColor;

  const SidebarItem({
    super.key,
    this.icon,
    this.text,
    this.routeName,
    this.child,
    this.active = false,
    this.onTap,
    this.hoverColor,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.active || (widget.routeName != null && GoRouterState.of(context).matchedLocation == widget.routeName);

    final defaultColor = AppColors.grey[500];
    final hoverColor = AppColors.grey[400];
    final activeColor = AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap ?? (widget.routeName != null ? () => context.go(widget.routeName!) : null),
        hoverColor: Colors.transparent, // Disable default hover background
        splashColor: Colors.transparent, // Disable splash effect
        highlightColor: Colors.transparent, // Disable highlight
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Row(
            children: [
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: 20,
                  color: isActive
                      ? activeColor
                      : _isHovered
                          ? hoverColor
                          : defaultColor,
                ),
              if (widget.text != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    widget.text!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: isActive
                          ? activeColor
                          : _isHovered
                              ? hoverColor
                              : defaultColor,
                    ),
                  ),
                ),
              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }
}
