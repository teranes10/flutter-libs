import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Builds the sticky "Add New" footer shared by [TSelect] and [TMultiSelect].
///
/// Shows the form from [createForm] in a modal; when the form is saved, [onCreateItem]
/// converts it to an item, and a non-null result is added to [controller].
Widget buildSelectCreateFooter<T, K>({
  required BuildContext context,
  required TListController<T, K> controller,
  required TFormBase Function() createForm,
  required FutureOr<T?> Function(dynamic form)? onCreateItem,
  required String label,
  void Function(T item)? onCreated,
}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: TButton(
      baseTheme: TWidgetTheme.surfaceTheme(context.colors).copyWith(
          container: context.colors.surfaceContainerLowest,
          onContainer: context.colors.primary,
          onContainerVariant: context.colors.primary.withAlpha(160)),
      size: TButtonSize.block,
      icon: HugeIcons.strokeRoundedAdd01,
      text: label,
      onTap: () async {
        final form = createForm();
        final saved = await TFormService.show(context, form);
        if (saved == null) return;
        final item = await onCreateItem?.call(saved);
        if (item != null) {
          controller.addItem(item);
          onCreated?.call(item);
        }
        form.reset();
        form.dispose();
      },
    ),
  );
}

/// Returns [base] with the create footer composed after any existing footer.
TListTheme withSelectCreateFooter(TListTheme base, Widget Function(BuildContext) createFooter) {
  final existing = base.footerBuilder;
  return base.copyWith(
    footerSticky: true,
    footerBuilder: (ctx) =>
        existing == null ? createFooter(ctx) : Column(mainAxisSize: MainAxisSize.min, children: [existing(ctx), createFooter(ctx)]),
  );
}
