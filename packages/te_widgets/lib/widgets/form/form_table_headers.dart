part of 'form_builder.dart';

/// Turns the [TFormField]s of a [TFormBase] into [TTableHeader] columns.
///
/// Each table row is one form instance, so a list of forms can be shown and edited
/// as a table while the form class stays the single definition of its fields.
///
/// ```dart
/// final headers = ProductForm().toTableHeaders<int>();
/// TTable<ProductForm, int>(headers: headers, controller: controller, editable: true);
/// ```
extension TFormBaseTableHeaders<F extends TFormBase> on F {
  /// Input fields need room to type in once a row is edited, and an empty table has no sample
  /// content to measure, so each column reserves this width; the table switches to card view
  /// when the columns no longer fit. Toggles are compact and don't need it.
  static double _editorMinWidth(Widget editor) => editor is TSwitch || editor is TCheckbox ? 90 : 200;

  /// Builds one editable [TTableHeader] per field in [fields].
  ///
  /// The receiver is only used as a template for column titles; cells always read
  /// and edit the fields of the row's own form instance. Sub-form fields and fields
  /// without a [TFormField.prop] are skipped. Column title comes from the field's
  /// label (falling back to `Field n`); use [titles] to override per field index.
  /// [onChanged] fires whenever a cell edit changes a field of any row.
  List<TTableHeader<F, K>> toTableHeaders<K>({
    Map<int, String>? titles,
    String? Function(F form, int fieldIndex)? error,
    int? flex,
    double? minWidth,
    double? maxWidth,
    VoidCallback? onChanged,
  }) {
    final template = fields;
    final headers = <TTableHeader<F, K>>[];

    for (var i = 0; i < template.length; i++) {
      final field = template[i];
      if (field.isSubForm || field.prop == null) continue;

      final widget = field._field;
      final label = widget is TInputFieldMixin ? (widget as TInputFieldMixin).label : null;
      final title = titles?[i] ?? (label.isNullOrBlank ? 'Field ${i + 1}' : label!);

      final cell = TTableHeader<F, K>.editable(
        title,
        // Read-only cells show what a person reads, not Dart's `true`/`false`.
        get: (form) => switch (form.fields[i].prop?.value) { final bool b => b ? 'Yes' : 'No', final v => v },
        error: error == null ? null : (form) => error(form, i),
        flex: flex,
        maxWidth: maxWidth,
        builder: (ctx, form) {
          final f = form.fields[i];
          if (onChanged != null) f._attach(onChanged);
          return THideInputLabel(child: f._field);
        },
      );
      headers.add(_FormColumn<F, K>(cell, minWidth ?? _editorMinWidth(widget)));
    }

    return headers;
  }
}

/// A form column whose [minWidth] only drives the table/card decision.
///
/// Reserving room for the inputs keeps an empty table from staying in table view, but the card's
/// read-only key-values must not inherit it, so they come from the underlying [cell] unconstrained.
class _FormColumn<F, K> extends TTableHeader<F, K> {
  final TTableHeader<F, K> cell;
  final double editorWidth;

  _FormColumn(this.cell, double minWidth)
      : editorWidth = minWidth,
        super(
          cell.text,
          map: cell.map,
          builder: cell.builder,
          flex: cell.flex,
          minWidth: minWidth,
          maxWidth: cell.maxWidth,
          alignment: cell.alignment,
          key: cell.key,
          filterable: cell.filterable,
          showInDetails: cell.showInDetails,
        );

  @override
  List<TKeyValue> toKeyValues(BuildContext ctx, TListItem<F, K> item, int index) {
    final active = TTableCellScope.maybeOf(ctx);
    return cell.toKeyValues(ctx, item, index).map((kv) {
      final w = kv.widget;
      if (active == null || w == null) return kv;
      // Only a row in edit mode needs room for its inputs; otherwise the value sizes to its content.
      return TKeyValue(
        kv.key,
        value: kv.value,
        icon: kv.icon,
        width: kv.width,
        alignment: kv.alignment,
        minWidth: kv.minWidth,
        maxWidth: kv.maxWidth,
        widget: ValueListenableBuilder<String?>(
          valueListenable: active,
          builder: (_, v, child) => (v?.startsWith('${item.key}_') ?? false)
              ? ConstrainedBox(constraints: BoxConstraints(minWidth: editorWidth), child: child)
              : child!,
          child: w,
        ),
      );
    }).toList();
  }
}
