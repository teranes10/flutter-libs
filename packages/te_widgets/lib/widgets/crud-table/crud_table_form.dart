part of 'crud_table.dart';

class _TCrudInlineForm<T, K, F extends TFormBase> extends StatefulWidget {
  final F form;
  final Future<bool> Function(BuildContext ctx, F form) onSave;
  final VoidCallback onCancel;

  const _TCrudInlineForm({
    super.key,
    required this.form,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_TCrudInlineForm<T, K, F>> createState() => _TCrudInlineFormState<T, K, F>();
}

class _TCrudInlineFormState<T, K, F extends TFormBase> extends State<_TCrudInlineForm<T, K, F>> {
  late F _form;
  TError? _serverError;
  final GlobalKey _errorKey = GlobalKey();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _form = widget.form;
  }

  void _scrollToError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null && scrollable.position.hasPixels) {
        scrollable.position.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_errorKey.currentContext != null) {
        Scrollable.ensureVisible(
          _errorKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleSave() async {
    final errors = _form.validationErrors;
    if (errors.isNotEmpty) {
      for (var message in errors) {
        TToastService.error(context, message);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    try {
      await widget.onSave(context, _form);
    } catch (e) {
      if (mounted) {
        final err = TError.from(e);
        setState(() {
          _serverError = err;
        });
        _scrollToError();
        TToastService.error(context, null, null, TError.from(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_serverError != null && _serverError!.hasError)
          KeyedSubtree(
            key: _errorKey,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              child: TErrorBuilder(error: _serverError!),
            ),
          ),
        const SizedBox(height: 10),
        TFormBuilder(input: _form),
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
                onPressed: (_) => widget.onCancel(),
              ),
              TButton(
                size: TButtonSize.md.copyWith(minW: 100),
                color: theme.primary,
                text: 'Save',
                loading: _isLoading,
                onPressed: (_) => _handleSave(),
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
        key: ValueKey(item?.key ?? 'create_form'),
        form: form,
        onSave: (ctx, f) => item != null ? handleEditInline(ctx, item.data, f) : handleCreateInline(ctx, f),
        onCancel: () => TTableScope.of(ctx).close(ctx),
      );
    };
  }
}
