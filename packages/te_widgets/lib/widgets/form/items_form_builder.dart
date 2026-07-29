import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A dynamic form builder for managing lists of sub-forms.
///
/// `TItemsFormBuilder` provides dynamic list management with:
/// - Add/remove items dynamically
/// - Each item is a complete form (TFormBase)
/// - Configurable add button position
/// - Automatic value synchronization
///
/// ## Usage Example
///
/// ```dart
/// class AddressForm extends TFormBase {
///   final street = TFieldProp<String>('');
///   final city = TFieldProp<String>('');
///
///   @override
///   List<TFormField> get fields => [
///     TFormField.text(street, 'Street'),
///     TFormField.text(city, 'City'),
///   ];
/// }
///
/// final addresses = TFieldProp<List<AddressForm>>([]);
///
/// TFormField.items(
///   addresses,
///   () => AddressForm(),
///   label: 'Addresses',
///   buttonLabel: 'Add Address',
/// )
/// ```
///
/// Type parameter:
/// - [T]: The form type (must extend TFormBase)
///
/// See also:
/// - [TFormBase] for form models
/// - [TFormField.items] for field creation
class TItemsFormBuilder<T extends TFormBase> extends StatefulWidget with TInputValueMixin<List<T>> {
  @override
  final List<T>? value;
  @override
  final ValueChanged<List<T>?>? onValueChanged;
  @override
  final ValueNotifier<List<T>?>? valueNotifier;

  /// Optional label for the form list.
  final String? label;

  /// Label for the add button.
  final String buttonLabel;

  /// Factory function to create new items.
  final T Function() onNewItem;

  /// Where to add new items (first or last).
  final TItemAddPosition itemAddPosition;

  /// Custom layout builder for the items list content.
  final Widget Function(BuildContext context, Widget child, VoidCallback onAddNew)? layoutBuilder;

  /// Creates an items form builder.
  const TItemsFormBuilder({
    super.key,
    this.value,
    this.onValueChanged,
    this.valueNotifier,
    required this.onNewItem,
    this.label,
    this.buttonLabel = 'Add New',
    this.itemAddPosition = TItemAddPosition.first,
    this.layoutBuilder,
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
    final backgroundColor = context.getBackgroundColor(context.colors.surface);
    final borderColor = Colors.transparent;

    final content = TList<T, int>(
      controller: _listController,
      itemBuilder: (ctx, item, i) => TCard(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(bottom: 10),
        child: Stack(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: TFormBuilder(input: item.data, onValueChanged: _update)),
            Positioned(top: -9, right: -9, child: TIcon.close(size: 16, onTap: () => _removeItem(item.data)))
          ],
        ),
      ),
      theme: context.theme.listTheme.copyWith(
        shrinkWrap: true,
        infiniteScroll: false,
        padding: EdgeInsets.zero,
        animationBuilder: TListAnimationBuilders.slideInDown,
        animationDuration: Duration(microseconds: 100),
        emptyStateBuilder: (ctx) {
          return TCard(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                children: [
                  Text(
                    'No items yet.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: _onNewItem,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Add your first item'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return widget.layoutBuilder?.call(context, content, _onNewItem) ??
        Column(
          children: [
            _buildToolbar(colors),
            content,
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
      padding: const EdgeInsets.fromLTRB(16, 2, 2, 2),
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.label != null
              ? Text(
                  widget.label!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onSurface),
                )
              : SizedBox.shrink(),
          TButton(
            type: TButtonType.text,
            size: TButtonSize.sm.copyWith(hPad: 0),
            text: widget.buttonLabel,
            icon: Icons.add_rounded,
            onTap: _onNewItem,
          )
        ],
      ),
    );
  }
}
