import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Grip that starts a drag-reorder of the item at [index] in a reorderable list.
///
/// Rendered automatically by [TList] (see [TListDragHandle.auto]); place it yourself
/// inside an item builder when the theme uses [TListDragHandle.builder].
/// Gray by default, primary-colored on hover, with a grab cursor.
class TDragHandle extends StatelessWidget {
  /// The index of the item this handle drags, as received by the item builder.
  final int index;

  /// Icon size. Defaults to 16.
  final double size;

  /// Padding around the icon (the touch target). Defaults to 8.
  final EdgeInsets padding;

  const TDragHandle({
    super.key,
    required this.index,
    this.size = 16,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: TIcon(
        icon: HugeIcons.strokeRoundedGripVertical,
        size: size,
        padding: padding,
        themeType: TThemeType.primary,
        semanticLabel: 'Drag to reorder',
      ),
    );
  }
}
