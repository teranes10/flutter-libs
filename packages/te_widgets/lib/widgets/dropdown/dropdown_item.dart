import 'package:flutter/material.dart';
import 'package:te_widgets/auth/auth_mode.dart';
import 'package:te_widgets/widgets/menu/menu_item_data.dart';

class TDropdownItem extends TMenuItemData<TDropdownItem> {
  @override
  final dynamic icon;
  @override
  final String? text;
  @override
  final List<TDropdownItem>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;
  final Object? extra;
  @override
  final bool hidden;
  @override
  final Color? color;
  @override
  final Widget? customContent;
  @override
  final Object? permission;
  @override
  final TAuthMode? onDenied;

  const TDropdownItem({
    this.icon,
    this.text,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
    this.extra,
    this.hidden = false,
    this.color,
    this.customContent,
    this.permission,
    this.onDenied,
  });

  @override
  bool get isClickable => onTap != null;

  @override
  void tap(BuildContext context) => onTap?.call();
}
