part of 'table_header.dart';

// Editable-cell builders for [TTableHeader.editable], [TTableHeader.textField] and [TTableHeader.numberField].

Widget Function(BuildContext, TListItem<T, K>, int) _editableCellBuilder<T, K>({
  required String text,
  required Object? Function(T) get,
  required Widget Function(BuildContext ctx, T data) builder,
  required Widget Function(BuildContext ctx, T data)? displayBuilder,
  required String? Function(T data)? error,
  required String? placeholder,
}) =>
    (ctx, item, index) {
      final cellScope = TTableCellScope.maybeScopeOf(ctx);
      final activeCursor = cellScope?.activeCellNotifier ?? TTableCellScope.maybeOf(ctx);
      final data = item.data;
      final cellKey = "${item.key}_$text";
      final colors = ctx.colors;
      final cellError = error?.call(data) ?? cellScope?.getError(data, text, cellKey);
      final hasError = cellError != null && cellError.isNotEmpty;
      final textStyle = TTableScope.maybeOf(ctx)?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
      Widget buildDisplay() {
        if (displayBuilder != null) {
          return displayBuilder(ctx, data);
        }

        final rawVal = get(data);
        final displayStr = rawVal?.toString() ?? '';
        final isEmpty = displayStr.trim().isEmpty;

        if (hasError) {
          return TTooltip(
            message: cellError,
            waitDuration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isEmpty ? (placeholder ?? '—') : displayStr,
                    style: textStyle?.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                TIcon.raw(
                  HugeIcons.strokeRoundedAlert02,
                  size: 14,
                  color: colors.error,
                ),
              ],
            ),
          );
        }

        if (isEmpty && placeholder != null) {
          return Text(
            placeholder,
            style: textStyle?.copyWith(
                  color: colors.onSurfaceVariant.withAlpha(100),
                  fontStyle: FontStyle.italic,
                ) ??
                TextStyle(
                  color: colors.onSurfaceVariant.withAlpha(100),
                  fontStyle: FontStyle.italic,
                ),
            overflow: TextOverflow.ellipsis,
          );
        }

        return Text(
          displayStr,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
        );
      }

      Widget buildEditor() {
        final editorWidget = builder(ctx, data);
        if (hasError) {
          return TTooltip(
            message: cellError,
            waitDuration: const Duration(milliseconds: 200),
            child: editorWidget,
          );
        }
        return editorWidget;
      }

      if (activeCursor != null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => activeCursor.value = cellKey,
          child: ValueListenableBuilder(
            valueListenable: activeCursor,
            builder: (ctx, active, _) => (active?.startsWith('${item.key}_') ?? false) ? buildEditor() : buildDisplay(),
          ),
        );
      }
      return buildDisplay();
    };

Widget Function(BuildContext ctx, T data) _textFieldEditor<T>({
  required TInputDecorationType decorationType,
  required TInputSize size,
  required String? placeholder,
  required String? Function(T) get,
  required void Function(T, String?) set,
}) =>
    (ctx, data) {
      return TTextField<String>(
        theme: ctx.theme.textFieldTheme.copyWith(
          decorationType: decorationType,
          size: size,
          labelPosition: TLabelPosition.aboveField,
        ),
        placeholder: placeholder,
        autoFocus: true,
        value: get(data),
        onValueChanged: (v) => set(data, v),
      );
    };

Widget Function(BuildContext ctx, T data) _numberFieldEditor<T>({
  required TInputDecorationType decorationType,
  required TInputSize size,
  required String? placeholder,
  required num? Function(T) get,
  required void Function(T, num?) set,
}) =>
    (ctx, data) {
      return TNumberField<num>(
        theme: ctx.theme.numberFieldTheme.copyWith(
          decorationType: decorationType,
          size: size,
          labelPosition: TLabelPosition.aboveField,
          splitStepper: true,
        ),
        placeholder: placeholder,
        autoFocus: true,
        value: get(data),
        onValueChanged: (v) => set(data, v),
      );
    };
