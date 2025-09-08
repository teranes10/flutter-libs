import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TButtonGroup extends StatelessWidget {
  final TButtonGroupType type;
  final TButtonSize? size;
  final Color? color;
  final List<TButtonGroupItem> items;

  const TButtonGroup({
    super.key,
    this.type = TButtonGroupType.solid,
    this.color,
    this.size,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isBoxed = type == TButtonGroupType.boxed;
    final effectiveType = isBoxed ? TButtonType.filledText : mapGroupTypeToButtonType(type);

    Widget buttonGroup = Wrap(children: _buildButtons(theme, effectiveType));

    if (isBoxed) {
      buttonGroup = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: theme.outline), borderRadius: BorderRadius.circular(8)),
        child: buttonGroup,
      );
    }

    return buttonGroup;
  }

  List<Widget> _buildButtons(ColorScheme theme, TButtonType buttonType) {
    final allButtons = <Widget>[];
    final total = items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final button = _buildButton(theme, item: item, index: i, total: total, buttonType: buttonType);
      allButtons.add(button);
    }

    return allButtons;
  }

  Widget _buildButton(
    ColorScheme theme, {
    required TButtonGroupItem item,
    required int index,
    required int total,
    required TButtonType buttonType,
  }) {
    final isFirst = index == 0;
    final isLast = index == total - 1;
    final isSingle = total == 1;

    TButton button = TButton(
      type: buttonType,
      color: item.color ?? color,
      size: size,
      text: item.text,
      icon: item.icon,
      loading: item.loading,
      loadingText: item.loadingText,
      active: item.active,
      tooltip: item.tooltip,
      onPressed: item.onPressed,
      child: item.child,
    );

    if (!isSingle) {
      return _applyGroupStyling(theme, button: button, isFirst: isFirst, isLast: isLast);
    }

    return button;
  }

  Widget _applyGroupStyling(
    ColorScheme theme, {
    required TButton button,
    required bool isFirst,
    required bool isLast,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? 6 : 0),
        bottomLeft: Radius.circular(isFirst ? 6 : 0),
        topRight: Radius.circular(isLast ? 6 : 0),
        bottomRight: Radius.circular(isLast ? 6 : 0),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
            right: isLast ||
                    button.type == TButtonType.solid ||
                    button.type == TButtonType.tonal ||
                    button.type == TButtonType.outline ||
                    button.type == TButtonType.softOutline ||
                    button.type == TButtonType.filledOutline
                ? BorderSide.none
                : BorderSide(color: theme.outline, width: 0.25)),
      ),
      child: button.copyWith(shape: shape),
    );
  }
}

class TButtonGroupItem {
  final IconData? icon;
  final String? text;
  final bool loading;
  final String loadingText;
  final Color? color;
  final String? tooltip;
  final bool active;
  final Widget? child;
  final Function(TButtonPressOptions)? onPressed;

  TButtonGroupItem({
    this.icon,
    this.text,
    this.loading = false,
    this.loadingText = 'Loading...',
    this.color,
    this.tooltip,
    this.active = false,
    this.child,
    this.onPressed,
  });
}
