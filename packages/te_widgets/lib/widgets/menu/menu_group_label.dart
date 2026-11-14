import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Non-interactive heading for a group item ([TMenuItemData.isGroup]),
/// shadcn `DropdownMenuLabel` / `SidebarGroupLabel` style.
class TMenuGroupLabel extends StatelessWidget {
  final String? text;
  final TMenuTheme theme;
  final EdgeInsetsGeometry? padding;

  const TMenuGroupLabel({super.key, required this.text, required this.theme, this.padding});

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return const SizedBox(height: 4);
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(theme.itemPadding.left, 8, theme.itemPadding.right, 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.fontSize * 0.85,
            fontWeight: FontWeight.w500,
            color: theme.defaultColor.withAlpha(150),
          ),
        ),
      ),
    );
  }
}
