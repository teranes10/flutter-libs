import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TListInteraction<T> {
  final TListInteractionType tapAction;
  final TListInteractionType longPressAction;
  final TListInteractionType doubleTapAction;
  final Function(T item, int index)? onTap;
  final Function(T item, int index)? onDoubleTap;
  final Function(T item, int index)? onLongPress;
  final bool enableMouseCursor;

  TListInteraction({
    this.tapAction = TListInteractionType.none,
    this.longPressAction = TListInteractionType.none,
    this.doubleTapAction = TListInteractionType.none,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.enableMouseCursor = true,
  });

  TListInteraction<T> copyWith({
    TListInteractionType? tapAction,
    TListInteractionType? longPressAction,
    TListInteractionType? doubleTapAction,
    Function(T item, int index)? onTap,
    Function(T item, int index)? onDoubleTap,
    Function(T item, int index)? onLongPress,
    bool? enableMouseCursor,
  }) {
    return TListInteraction<T>(
      tapAction: tapAction ?? this.tapAction,
      longPressAction: longPressAction ?? this.longPressAction,
      doubleTapAction: doubleTapAction ?? this.doubleTapAction,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      enableMouseCursor: enableMouseCursor ?? this.enableMouseCursor,
    );
  }

  Widget buildGestureDetector<K>({
    Key? key,
    required T item,
    required int index,
    required bool selectable,
    required bool expandable,
    required TListController<T, K> controller,
    required Widget child,
  }) {
    void handleInteraction(TListInteractionType type) {
      switch (type) {
        case TListInteractionType.expand:
          if (expandable) controller.toggleExpansion(item);
          break;
        case TListInteractionType.select:
          if (selectable) controller.toggleSelection(item);
          break;
        case TListInteractionType.none:
          break;
      }
    }

    Widget content = child;

    if (enableMouseCursor) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      );
    }

    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onTap?.call(item, index);
        handleInteraction(tapAction);
      },
      onDoubleTap: doubleTapAction != TListInteractionType.none || onDoubleTap != null
          ? () {
              onDoubleTap?.call(item, index);
              handleInteraction(doubleTapAction);
            }
          : null,
      onLongPress: longPressAction != TListInteractionType.none || onLongPress != null
          ? () {
              onLongPress?.call(item, index);
              handleInteraction(longPressAction);
            }
          : null,
      child: content,
    );
  }
}
