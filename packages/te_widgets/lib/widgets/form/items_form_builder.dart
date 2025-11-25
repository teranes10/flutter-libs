import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TItemsFormBuilder<T extends TFormBase> extends StatefulWidget with TInputValueMixin<List<T>> {
  @override
  final List<T>? value;
  @override
  final ValueChanged<List<T>?>? onValueChanged;
  @override
  final ValueNotifier<List<T>?>? valueNotifier;

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
  late TListController<T, int> _listController;

  @override
  void initState() {
    super.initState();
    _listController = TListController(items: widget.value != null ? List.from(widget.value!) : List.empty());
  }

  @override
  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        _buildToolbar(colors),
        TList<T, int>(
          theme: context.theme.listTheme.copyWith(shrinkWrap: true, infiniteScroll: false, padding: EdgeInsets.all(0)),
          controller: _listController,
          itemBuilder: (ctx, item, i) => TCard(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.only(bottom: 10),
              child: Stack(
                children: [
                  Padding(padding: EdgeInsets.all(10), child: TFormBuilder(input: item.data, onValueChanged: _update)),
                  Positioned(top: 2, right: 2, child: TIcon.close(colors, size: 14, onTap: () => _removeItem(item.data)))
                ],
              )),
        )
      ],
    );
  }

  void _update() {
    final value = _listController.localItems;
    widget.onValueChanged?.call(value);
  }

  void _onNewItem() {
    _listController.addItem(widget.onNewItem(), widget.itemAddPosition == TItemAddPosition.first);
    _update();
  }

  void _removeItem(T item) {
    _listController.removeItem(item);
    _update();
  }

  Widget _buildToolbar(ColorScheme colors) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.label != null
              ? Text(widget.label!, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: colors.onSurface))
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
