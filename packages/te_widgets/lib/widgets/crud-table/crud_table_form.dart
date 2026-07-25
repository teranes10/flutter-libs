part of 'crud_table.dart';

class _TCrudInlineForm<T, K, F extends TFormBase> extends StatelessWidget {
  final F form;
  final void Function(BuildContext ctx, F) onSave;
  final VoidCallback onCancel;

  const _TCrudInlineForm({
    required this.form,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        TFormBuilder(input: form),
        Padding(
          padding: EdgeInsets.only(top: context.isDesktop ? 24 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              TButton(
                baseTheme: TWidgetTheme.surfaceTheme(context.colors),
                size: TButtonSize.md.copyWith(minW: 125),
                text: 'Cancel',
                onPressed: (_) => onCancel(),
              ),
              TButton(
                size: TButtonSize.md.copyWith(minW: 100),
                color: theme.primary,
                text: 'Save',
                onPressed: (_) {
                  final errors = form.validationErrors;
                  if (errors.isNotEmpty) {
                    for (var message in errors) {
                      TToastService.error(context, message);
                    }
                    return;
                  }
                  onSave(context, form);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

extension _TCrudTableFormExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  TTableCreateBuilder<T, K>? _buildInlineCreateBuilder() {
    if (!canCreate && !canEdit) return null;

    return (ctx, item, index) {
      final form = item != null ? widget.editForm?.call(item.data) : widget.createForm?.call();
      if (form == null) return const SizedBox.shrink();

      return _TCrudInlineForm<T, K, F>(
        form: form,
        onSave: (ctx, f) => item != null ? handleEditInline(ctx, item.data, f) : handleCreateInline(ctx, f),
        onCancel: () => TTableScope.of(ctx).close(ctx),
      );
    };
  }
}
