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
  final colors = context.colors;
  final glass = TGlassStyle.resolve(context) != null;
  // Glass: a filled primary button (a tinted outline looked like a text box); text is onPrimary for contrast.
  final base = TWidgetTheme.surfaceTheme(colors).copyWith(
    container: glass ? colors.primary.withAlpha(colors.isDarkMode ? 190 : 225) : colors.surfaceContainerLowest,
    containerVariant: glass ? colors.primary : null,
    outline: glass ? Colors.white.withAlpha(90) : null,
    outlineVariant: glass ? Colors.white.withAlpha(140) : null,
    onContainer: glass ? colors.onPrimary : colors.primary,
    onContainerVariant: glass ? colors.onPrimary : colors.primary.withAlpha(160),
  );
  return Padding(
    padding: const EdgeInsets.all(8),
    child: TButton(
      baseTheme: base,
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
