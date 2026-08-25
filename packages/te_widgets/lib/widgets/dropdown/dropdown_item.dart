import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/menu/menu_item_data.dart';

class TDropdownItem extends TMenuItemData<TDropdownItem> {
  @override
  final IconData? icon;
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
   });
 
   @override
   bool get isClickable => onTap != null;
 
   @override
   void tap(BuildContext context) => onTap?.call();
 }
