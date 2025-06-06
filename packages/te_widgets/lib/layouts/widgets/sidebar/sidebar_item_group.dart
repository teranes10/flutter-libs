import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_item.dart';

class SidebarItemGroup extends StatefulWidget {
  final IconData? icon;
  final String? text;
  final List<dynamic>? items;
  final bool initiallyExpanded;
  final VoidCallback? onTap;
  final Color? hoverColor;

  const SidebarItemGroup({
    super.key,
    this.icon,
    this.text,
    this.items,
    this.initiallyExpanded = false,
    this.onTap,
    this.hoverColor,
  });

  @override
  State<SidebarItemGroup> createState() => _SidebarItemGroupState();
}

class _SidebarItemGroupState extends State<SidebarItemGroup> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late bool _isHovered;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _isHovered = false;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items?.isNotEmpty ?? false;
    final defaultColor = AppColors.grey[500];
    final hoverColor = AppColors.grey[400];
    final activeColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header item
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: hasItems ? _toggleExpanded : widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: 20,
                      color: _isExpanded
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
                          color: _isExpanded
                              ? activeColor
                              : _isHovered
                                  ? hoverColor
                                  : defaultColor,
                        ),
                      ),
                    ),
                  if (hasItems) const Spacer(),
                  if (hasItems)
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                      child: Icon(
                        Icons.expand_more,
                        size: 16,
                        weight: 100,
                        color: _isExpanded
                            ? activeColor
                            : _isHovered
                                ? hoverColor
                                : defaultColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Child items
        if (widget.items != null && widget.items!.isNotEmpty)
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _animation,
            child: Padding(
              padding: const EdgeInsets.only(left: 26.4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.grey[100]!,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  children: widget.items!.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: item is SidebarItemGroup
                          ? SidebarItemGroup(
                              icon: item.icon,
                              text: item.text,
                              items: item.items,
                              initiallyExpanded: item.initiallyExpanded,
                              onTap: item.onTap,
                              hoverColor: widget.hoverColor,
                            )
                          : SidebarItem(
                              icon: item.icon,
                              text: item.text,
                              routeName: item.routeName,
                              onTap: item.onTap,
                              hoverColor: widget.hoverColor,
                            ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
