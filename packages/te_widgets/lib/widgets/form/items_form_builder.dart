import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/close-icon/close_icon.dart';

class TItemsFormBuilder<T extends TFormBase> extends StatefulWidget with TInputValueMixin<List<T>> {
  @override
  final List<T>? value;
  @override
  final ValueChanged<List<T>>? onValueChanged;
  @override
  final ValueNotifier<List<T>>? valueNotifier;

  final String? label;
  final String buttonLabel;
  final T Function() onNewItem;
  final TItemAddPosition itemAddPosition;

  const TItemsFormBuilder({
    super.key,
    this.value,
    this.onValueChanged,
    this.valueNotifier,
    required this.onNewItem,
    this.label,
    this.buttonLabel = 'Add New',
    this.itemAddPosition = TItemAddPosition.first,
  });

  @override
  State<TItemsFormBuilder<T>> createState() => _TItemsFormBuilderState<T>();
}

class _TItemsFormBuilderState<T extends TFormBase> extends State<TItemsFormBuilder<T>>
    with TInputValueStateMixin<List<T>, TItemsFormBuilder<T>> {
  late List<T> _items;

  @override
  void initState() {
    _items = widget.value != null ? List.from(widget.value!) : List.empty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      children: [
        _buildToolbar(theme),
        TList(
          items: _items,
          padding: const EdgeInsets.all(2),
          itemBuilder: (ctx, item, i) => TCard(
              padding: EdgeInsets.all(0),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: TFormBuilder(input: item, onValueChanged: _update),
                  ),
                  Positioned(top: 2, right: 2, child: TCloseIcon(size: 14, onClose: () => _removeItem(item)))
                ],
              )),
        )
      ],
    );
  }

  void _update() {
    widget.onValueChanged?.call(_items);
  }

  void _onNewItem() {
    setState(() {
      if (widget.itemAddPosition == TItemAddPosition.first) {
        _items.insert(0, widget.onNewItem());
      } else {
        _items.add(widget.onNewItem());
      }

      _update();
    });
  }

  void _removeItem(T item) {
    setState(() {
      _items.remove(item);
      _update();
    });
  }

  Widget _buildToolbar(ColorScheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.label != null
              ? Text(widget.label!, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: theme.onSurface))
              : SizedBox.shrink(),
          TButton(
              type: TButtonType.softText,
              size: TButtonSize.sm,
              text: widget.buttonLabel,
              icon: Icons.add_rounded,
              onPressed: (_) => _onNewItem())
        ],
      ),
    );
  }
}
