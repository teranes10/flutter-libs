import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/button/button.dart';
import 'package:te_widgets/widgets/button/button_config.dart';

class TButtonGroup extends StatelessWidget {
  final TButtonGroupType type;
  final TButtonSize? size;
  final MaterialColor color;
  final List<TButtonGroupItem> items;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  const TButtonGroup({
    super.key,
    this.type = TButtonGroupType.fill,
    this.color = AppColors.primary,
    this.size,
    this.items = const [],
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isBoxed = type == TButtonGroupType.boxed;
    final effectiveType = isBoxed ? TButtonType.textFill : mapGroupTypeToButtonType(type);

    Widget buttonGroup = Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildButtons(effectiveType),
    );

    if (isBoxed) {
      buttonGroup = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
        child: buttonGroup,
      );
    }

    return buttonGroup;
  }

  List<Widget> _buildButtons(TButtonType buttonType) {
    final allButtons = <Widget>[];
    final total = items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final button = _buildButton(
        item: item,
        index: i,
        total: total,
        buttonType: buttonType,
      );
      allButtons.add(button);
    }

    return allButtons;
  }

  Widget _buildButton({
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
      return _applyGroupStyling(button: button, isFirst: isFirst, isLast: isLast);
    }

    return button;
  }

  Widget _applyGroupStyling({
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
          right: isLast || button.type == TButtonType.outline || button.type == TButtonType.outlineFill
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade300, width: 0.25),
        ),
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
  final MaterialColor? color;
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
