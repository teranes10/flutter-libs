import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButtonGroup extends StatelessWidget {
  final TButtonGroupTheme? theme;
  final TButtonGroupType? type;
  final TButtonSize? size;
  final Color? color;
  final List<TButtonGroupItem> items;
  final WrapAlignment alignment;

  const TButtonGroup({
    super.key,
    this.theme,
    this.type,
    this.color,
    this.size,
    this.items = const [],
    this.alignment = WrapAlignment.start,
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
      final button = _buildButton(context, groupTheme: groupTheme, item: item, index: i, total: total);

      children.add(button);

      if (i < total - 1 && groupTheme.needsSeparator()) {
        children.add(groupTheme.buildSeparator());
      }
    }

    return Wrap(alignment: alignment, children: children);
  }

  Widget _buildButton(
    BuildContext context, {
    required TButtonGroupTheme groupTheme,
    required TButtonGroupItem item,
    required int index,
    required int total,
  }) {
    TButton button = TButton(
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

    final isSingle = total == 1;
    final buttonTheme = (button.theme ?? context.theme.buttonTheme).copyWith(
      type: type?.buttonType,
      color: item.color ?? groupTheme.color,
      size: size,
    );

    if (isSingle) {
      return button.copyWith(theme: buttonTheme);
    }

    final isFirst = index == 0;
    final isLast = index == total - 1;
    final borderRadius = groupTheme.borderRadius;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? borderRadius : 0),
        bottomLeft: Radius.circular(isFirst ? borderRadius : 0),
        topRight: Radius.circular(isLast ? borderRadius : 0),
        bottomRight: Radius.circular(isLast ? borderRadius : 0),
      ),
    );

    return button.copyWith(
      theme: buttonTheme.copyWith(
        buttonStyle: buttonTheme.buttonStyle.copyWith(shape: WidgetStateProperty.all(shape)),
      ),
    );
  }
}
