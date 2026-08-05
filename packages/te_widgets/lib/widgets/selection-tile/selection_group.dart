import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A group of [TSelectionTile]s for single-value selection.
///
/// Ideal for package type, delivery type, or similar option pickers.
///
/// ## Basic Usage
///
/// ```dart
/// TSelectionGroup<String>(
///   label: 'Package type',
///   items: [
///     TSelectionItem(value: 'parcel', label: 'Parcel', icon: Icons.inventory_2_outlined),
///     TSelectionItem(value: 'box', label: 'Box', icon: Icons.archive_outlined),
///     TSelectionItem(value: 'bag', label: 'Bag', icon: Icons.shopping_bag_outlined),
///   ],
///   value: 'parcel',
///   onValueChanged: (v) => print(v),
/// )
/// ```
///
/// Type parameter:
/// - [T]: The type of values for the selection items
///
/// See also:
/// - [TSelectionTile] for a single tile
/// - [TRadioGroup] for classic radio selection
class TSelectionGroup<T> extends StatefulWidget with TInputValueMixin<T>, TFocusMixin, TInputValidationMixin<T> {
  /// Section label displayed above the tiles.
  @override
  final String? label;

  /// Whether a selection is required.
  @override
  final bool isRequired;

  /// Validation rules for the selected value.
  @override
  final List<String? Function(T?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  /// Custom focus node.
  @override
  final FocusNode? focusNode;

  /// The currently selected value.
  @override
  final T? value;

  /// A ValueNotifier for two-way binding.
  @override
  final ValueNotifier<T?>? valueNotifier;

  /// Callback fired when the selection changes.
  @override
  final ValueChanged<T?>? onValueChanged;

  /// The list of selectable items.
  final List<TSelectionItem<T>> items;

  /// Whether the group is disabled.
  final bool disabled;

  /// Accent color for selected tiles.
  final Color? color;

  /// Spacing between tiles.
  final double spacing;

  /// Whether tiles expand equally to fill the row.
  final bool expanded;

  /// Whether to show a checkmark badge on the selected tile.
  final bool showCheckmark;

  /// Creates a selection group.
  const TSelectionGroup({
    super.key,
    this.label,
    this.isRequired = false,
    this.rules,
    this.validationDebounce,
    this.focusNode,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    required this.items,
    this.disabled = false,
    this.color,
    this.spacing = 12,
    this.expanded = true,
    this.showCheckmark = true,
  });

  @override
  State<TSelectionGroup<T>> createState() => _TSelectionGroupState<T>();
}

class _TSelectionGroupState<T> extends State<TSelectionGroup<T>>
    with
        TInputValueStateMixin<T, TSelectionGroup<T>>,
        TFocusStateMixin<TSelectionGroup<T>>,
        TInputValidationStateMixin<T, TSelectionGroup<T>> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final tiles = [
      for (final item in widget.items)
        TSelectionTile(
          label: item.label,
          icon: item.icon,
          image: item.image,
          isSelected: currentValue == item.value,
          disabled: widget.disabled || item.disabled,
          color: widget.color,
          showCheckmark: widget.showCheckmark,
          onTap: () {
            notifyValueChanged(item.value);
            setState(() {});
          },
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              if (widget.expanded) Expanded(child: tiles[i]) else tiles[i],
            ],
          ],
        ),
        if (hasErrors)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errors.first,
              style: TextStyle(fontSize: 12, color: colors.error),
            ),
          ),
      ],
    );
  }
}
