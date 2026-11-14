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

  /// Optional footer widget to display below the items list.
  final Widget? footer;

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
    this.footer,
  });

  @override
  State<TItemsFormBuilder<T>> createState() => _TItemsFormBuilderState<T>();
}

class _TItemsFormBuilderState<T extends TFormBase> extends State<TItemsFormBuilder<T>>
    with TInputValueStateMixin<List<T>, TItemsFormBuilder<T>> {
  late TListController<T, int> _listController;
  late final ValueNotifier<String?> _activeRow = ValueNotifier<String?>(null);
  late final List<TTableHeader<T, int>> _headers;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.value != null ? List<T>.from(widget.value!) : <T>[];
    _lastCount = initial.length;
    _listController = TListController(items: initial, itemKey: (item) => identityHashCode(item));
    _listController.addListener(_onListChanged);
    _headers = widget.onNewItem().toTableHeaders<int>(onChanged: _update);
  }

  @override
  void dispose() {
    _listController.removeListener(_onListChanged);
    _listController.dispose();
    _activeRow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backgroundColor = context.getBackgroundColor();

    final content = TTable<T, int>(
      headers: _headers,
      controller: _listController,
      editable: true,
      removable: true,
      selectableText: false,
      activeCellNotifier: _activeRow,
      theme: context.theme.tableTheme.copyWith(
        shrinkWrap: true,
        infiniteScroll: false,
        emptyStateBuilder: (ctx) => TCard(
          backgroundColor: backgroundColor,
          borderColor: Colors.transparent,
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              children: [
                Text('No items yet.', style: TextStyle(color: colors.onSurfaceVariant)),
                TextButton(
                  onPressed: _onNewItem,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Add your first item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Bottom bar appends to the end of the list; the header button adds to the start.
    final withBottomBar = ValueListenableBuilder(
      valueListenable: _listController,
      builder: (ctx, _, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
          if (_listController.localItems.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TButton(
                type: TButtonType.text,
                size: TButtonSize.sm.copyWith(hPad: 0),
                text: widget.buttonLabel,
                icon: HugeIcons.strokeRoundedAdd01,
                onTap: () => _onNewItem(first: false),
              ),
            ),
        ],
      ),
    );

    return widget.layoutBuilder?.call(context, withBottomBar, _onNewItem) ??
        TAccordion(
          title: widget.label ?? 'Items',
          initiallyExpanded: true,
          content: withBottomBar,
          footer: widget.footer,
          builder: (context, isExpanded, toggleExpand) {
            return TButton(
              type: TButtonType.text,
              size: TButtonSize.sm.copyWith(hPad: 0),
              text: widget.buttonLabel,
              icon: HugeIcons.strokeRoundedAdd01,
              onTap: () {
                if (!isExpanded) toggleExpand();
                _onNewItem(first: true);
              },
            );
          },
        );
  }

  void _update() => widget.onValueChanged?.call(_listController.localItems);

  // Rows removed through the table's own delete icon only surface here.
  void _onListChanged() {
    final count = _listController.localItems.length;
    if (count == _lastCount) return;
    _lastCount = count;
    _update();
  }

  /// Adds a new item; [first] overrides [TItemsFormBuilder.itemAddPosition].
  void _onNewItem({bool? first}) {
    final item = widget.onNewItem();
    _listController.addItem(item, prepend: first ?? widget.itemAddPosition == TItemAddPosition.first);
    // The new row opens straight in edit mode.
    _activeRow.value = TTable.rowCellKey(identityHashCode(item));
  }
}
