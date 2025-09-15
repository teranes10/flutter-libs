import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButtonGroup extends StatelessWidget {
  final TButtonGroupTheme? theme;
  final TButtonGroupType? type;
  final TButtonSize? size;
  final Color? color;
  final List<TButtonGroupItem> items;

  const TButtonGroup({
    super.key,
    this.theme,
    this.type,
    this.color,
    this.size,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ??
        TButtonGroupTheme.fromBaseTheme(
          context: context,
          type: type ?? TButtonGroupType.solid,
          size: size,
          color: color,
        );

    Widget buttonGroup = _buildButtonRow(context, effectiveTheme);

    if (effectiveTheme.enableBoxedMode) {
      buttonGroup = Container(
        padding: effectiveTheme.boxedPadding,
        decoration: effectiveTheme.boxedDecoration,
        child: buttonGroup,
      );
    }

    return buttonGroup;
  }

  Widget _buildButtonRow(BuildContext context, TButtonGroupTheme groupTheme) {
    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    final total = items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final button = _buildButton(
        context,
        groupTheme: groupTheme,
        item: item,
        index: i,
        total: total,
      );

      children.add(button);

      if (i < total - 1 && groupTheme.needsSeparator()) {
        children.add(groupTheme.buildSeparator());
      }
    }

    return Wrap(children: children);
  }

  Widget _buildButton(
    BuildContext context, {
    required TButtonGroupTheme groupTheme,
    required TButtonGroupItem item,
    required int index,
    required int total,
  }) {
    final isFirst = index == 0;
    final isLast = index == total - 1;
    final isSingle = total == 1;

    TButton button = TButton(
      type: groupTheme.type.buttonType,
      color: item.color ?? groupTheme.color,
      size: groupTheme.size,
      text: item.text,
      icon: item.icon,
      loading: item.loading,
      loadingText: item.loadingText,
      active: item.active,
      tooltip: item.tooltip,
      onTap: item.onTap,
      onPressed: item.onPressed,
      child: item.child,
    );

    if (!isSingle) {
      return groupTheme.applyGroupStyling(
        context,
        groupTheme: groupTheme,
        button: button,
        isFirst: isFirst,
        isLast: isLast,
      );
    }

    return button;
  }
}
