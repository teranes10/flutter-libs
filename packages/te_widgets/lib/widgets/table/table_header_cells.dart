part of 'table_header.dart';

// Cell builders and width estimators for the specialized [TTableHeader] constructors.

/// One selectable status for [TTableHeader.statusChip]: maps an enum [value] to its display [text], [icon] and
/// [color].
class TStatusOption<V> {
  /// The underlying value (typically an enum constant).
  final V value;

  /// Label shown in the chip and in the dropdown.
  final String text;

  /// Optional icon ([IconData], HugeIcon data or [Widget]).
  final dynamic icon;

  /// Accent color of the chip and the dropdown entry. Defaults to the theme's primary color.
  final Color? color;

  const TStatusOption(this.value, this.text, {this.icon, this.color});

  /// Builds one option per entry of [values], reading text, icon and color through the given callbacks
  /// (typically getters from an extension on your enum). [text] defaults to the humanized enum name.
  static List<TStatusOption<V>> fromValues<V>(
    Iterable<V> values, {
    String Function(V value)? text,
    dynamic Function(V value)? icon,
    Color? Function(V value)? color,
  }) =>
      [
        for (final v in values)
          TStatusOption<V>(
            v,
            text?.call(v) ?? (v is Enum ? humanize(v.name) : '$v'),
            icon: icon?.call(v),
            color: color?.call(v),
          ),
      ];

  /// `inProgress` -> `In Progress`, `done` -> `Done`.
  static String humanize(String name) {
    final spaced = name.replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])|_+'), (_) => ' ').trim();
    return spaced.isEmpty ? spaced : spaced[0].toUpperCase() + spaced.substring(1);
  }

  /// The option in [options] whose value equals [value], or null.
  static TStatusOption<dynamic>? find(List<TStatusOption<dynamic>> options, Object? value) {
    for (final o in options) {
      if (o.value == value) return o;
    }
    return null;
  }
}

Widget Function(BuildContext, TListItem<T, K>, int) _statusChipCellBuilder<T, K>({
  required Object? Function(T) get,
  required List<TStatusOption<dynamic>> options,
  required FutureOr<bool> Function(T data, dynamic value)? onChanged,
  required bool disabled,
  required bool Function(T data)? isDisabled,
  required TVariant? type,
  required TSize size,
}) =>
    (ctx, item, _) => _StatusChipCell<T>(
          data: item.data,
          get: get,
          options: options,
          onChanged: onChanged,
          readOnly: onChanged == null || disabled || (isDisabled?.call(item.data) ?? false),
          type: type,
          size: size,
        );

/// Cell of [TTableHeader.statusChip]. After [onChanged] returns true the picked value is shown right away (until
/// the row's own value changes), so the caller only needs to persist the change.
class _StatusChipCell<T> extends StatefulWidget {
  const _StatusChipCell({
    required this.data,
    required this.get,
    required this.options,
    required this.onChanged,
    required this.readOnly,
    required this.type,
    required this.size,
  });

  final T data;
  final Object? Function(T) get;
  final List<TStatusOption<dynamic>> options;
  final FutureOr<bool> Function(T data, dynamic value)? onChanged;
  final bool readOnly;
  final TVariant? type;
  final TSize size;

  @override
  State<_StatusChipCell<T>> createState() => _StatusChipCellState<T>();
}

class _StatusChipCellState<T> extends State<_StatusChipCell<T>> {
  /// Accepted value not yet reflected by the row's own value.
  TStatusOption<dynamic>? _accepted;
  bool _busy = false;

  @override
  void didUpdateWidget(_StatusChipCell<T> old) {
    super.didUpdateWidget(old);
    // The row now reports its own value (or another row), so stop overriding it.
    if (widget.get(widget.data) != old.get(old.data) || !identical(widget.data, old.data)) _accepted = null;
  }

  Future<void> _pick(TStatusOption<dynamic> option) async {
    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await widget.onChanged!(widget.data, option.value);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          if (ok) _accepted = option;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final isDense = TTableScope.maybeOf(context)?.dense ?? false;
    final current = _accepted ?? TStatusOption.find(options, widget.get(widget.data));
    final readOnly = widget.readOnly || _busy;
    final accent = current?.color ?? context.colors.primary;

    final chip = TChip(
      text: current?.text ?? '—',
      icon: current?.icon,
      color: current?.color,
      type: widget.type,
      size: widget.size,
      padding: isDense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : null,
      trailing: widget.readOnly ? null : TIcon.raw(HugeIcons.strokeRoundedArrowDown01, size: 12, color: accent),
    );
    if (readOnly) return Opacity(opacity: _busy ? 0.6 : 1, child: chip);

    // TPopover stretches its content to the popover width, so size the popover to the widest option:
    // row padding (10 + 10) + icon (16 + 8) + check (8 + 14) + popover padding (6 + 6) + border.
    final textWidth = options.fold<double>(0, (m, o) => math.max(m, TTableTheme.measureTextWidth(o.text)));
    final hasIcon = options.any((o) => o.icon != null);
    final width = (textWidth + 20 + (hasIcon ? 24 : 0) + 22 + 12 + 4).ceilToDouble();

    return TPopover(
      padding: const EdgeInsets.all(6),
      width: width,
      builder: (popCtx, close) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final o in options)
            _StatusOptionRow(
              option: o,
              selected: o == current,
              onTap: () {
                close();
                if (o != current) _pick(o);
              },
            ),
        ],
      ),
      child: chip,
    );
  }
}

class _StatusOptionRow extends StatelessWidget {
  const _StatusOptionRow({required this.option, required this.selected, required this.onTap});

  final TStatusOption<dynamic> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = option.color ?? context.colors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              TIcon.raw(option.icon, size: 16, color: color),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(color: color, fontWeight: selected ? FontWeight.w400 : FontWeight.w300),
              ),
            ),
            if (selected) TIcon.raw(HugeIcons.strokeRoundedTick02, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

double Function(T data) _chipsWidthEstimator<T>({
  required List<TChip> Function(T) builder,
  required dynamic Function(T data, String chipText)? icon,
  required double spacing,
}) =>
    (data) {
      final items = builder(data);
      if (items.isEmpty) return 0.0;
      double totalWidth = 0.0;
      for (int i = 0; i < items.length; i++) {
        final chip = items[i];
        final text = chip.text ?? '';
        final hasIcon = chip.icon != null || (icon != null && icon(data, text) != null);
        final hasTrailing = chip.trailing != null;
        final textWidth = text.isNotEmpty ? TTableTheme.measureTextWidth(text) : 0.0;
        final iconWidth = hasIcon ? 18.0 : 0.0;
        final trailingWidth = hasTrailing ? 18.0 : 0.0;
        totalWidth += textWidth + 24.0 + iconWidth + trailingWidth;
      }
      if (items.length > 1) {
        totalWidth += (items.length - 1) * spacing;
      }
      return totalWidth;
    };

Widget Function(BuildContext, TListItem<T, K>, int) _chipsCellBuilder<T, K>({
  required List<TChip> Function(T) builder,
  required double spacing,
  required double runSpacing,
  required WrapCrossAlignment crossAxisAlignment,
  required WrapAlignment wrapAlignment,
  required dynamic Function(T data, String chipText)? icon,
  required Color? Function(T data, String chipText)? color,
  required TVariant? Function(T data, String chipText)? typeBuilder,
  required TVariant? type,
  required TSize size,
  required void Function(String chipText)? Function(T data)? onTap,
}) =>
    (ctx, item, __) {
      final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
      final items = builder(item.data);
      if (items.isEmpty) return const SizedBox.shrink();

      final effectiveSpacing = isDense ? spacing * 0.75 : spacing;
      final effectiveRunSpacing = isDense ? runSpacing * 0.75 : runSpacing;

      return Wrap(
        spacing: effectiveSpacing,
        runSpacing: effectiveRunSpacing,
        crossAxisAlignment: crossAxisAlignment,
        alignment: wrapAlignment,
        children: [
          for (final chip in items)
            TChip(
              key: chip.key,
              text: chip.text,
              icon: chip.icon ?? icon?.call(item.data, chip.text ?? ''),
              trailing: chip.trailing,
              color: chip.color ?? color?.call(item.data, chip.text ?? ''),
              background: chip.background,
              textColor: chip.textColor,
              type: chip.type ?? typeBuilder?.call(item.data, chip.text ?? '') ?? type,
              size: chip.size != TChipSize.md ? chip.size : size,
              onTap: chip.onTap ?? (onTap?.call(item.data) != null ? () => onTap!(item.data)!(chip.text ?? '') : null),
              padding: isDense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : chip.padding,
              borderRadius: chip.borderRadius,
            ),
        ],
      );
    };

Widget Function(BuildContext, TListItem<T, K>, int) _progressCellBuilder<T, K>({
  required double? Function(T) map,
  required String? Function(T)? valueText,
  required bool showPercentage,
  required TProgressValuePosition valuePosition,
  required double progressMaxWidth,
  required double Function(T data)? widthEstimator,
  required double height,
  required Color? color,
  required Color? Function(double value, double percentage)? colorBuilder,
  required Color? backgroundColor,
  required bool flowing,
  required TextStyle? valueStyle,
}) =>
    (ctx, item, __) {
      final scope = TTableScope.maybeOf(ctx);
      final isDense = scope?.dense ?? false;
      final val = map(item.data) ?? 0.0;
      final customValueText = valueText?.call(item.data);

      final contentStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
      final fallbackValStyle = TextStyle(
        fontSize: isDense ? 10 : 11.0,
        fontWeight: FontWeight.w400,
      );
      final defaultValStyle = contentStyle?.adjust(sizeMultiplier: 0.8, weightStep: 1, clearColor: true) ?? fallbackValStyle;
      final effectiveValueStyle = valueStyle != null ? defaultValStyle.merge(valueStyle) : defaultValStyle;

      final effectiveEstimator = widthEstimator ??
          _defaultProgressWidthEstimator(
            map: map,
            valueText: valueText,
            showPercentage: showPercentage,
            valuePosition: valuePosition,
            progressMaxWidth: progressMaxWidth,
          );
      final estimatedWidth = effectiveEstimator(item.data);

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: estimatedWidth),
        child: TProgressBar(
          value: val,
          height: isDense ? (height * 0.75).clamp(3.0, 12.0) : height,
          showPercentage: showPercentage,
          valueText: customValueText,
          valuePosition: valuePosition,
          color: color,
          colorBuilder: colorBuilder,
          backgroundColor: backgroundColor,
          flowing: flowing,
          valueStyle: effectiveValueStyle,
        ),
      );
    };

double Function(T data) _keyValuesWidthEstimator<T>({
  required List<TKeyValue> Function(T) builder,
  required TextStyle? keyStyle,
  required TextStyle? valueStyle,
  required bool inline,
}) =>
    (data) {
      final items = builder(data);
      if (items.isEmpty) return 0.0;
      final effectiveKeyStyle = keyStyle ??
          TTableTheme.fallbackTextStyle.adjust(
            sizeMultiplier: 0.8,
            weightStep: 1,
          );
      final effectiveValueStyle = valueStyle ?? TTableTheme.fallbackTextStyle;
      double maxWidth = 0.0;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final keyText = inline ? '${item.key}: ' : item.key;
        final valText = item.value ?? '—';
        final keyWidth = TTableTheme.measureTextWidth(keyText, effectiveKeyStyle);
        final valWidth = TTableTheme.measureTextWidth(valText, effectiveValueStyle);
        final iconWidth = item.icon != null ? 20.0 : 0.0;
        final rowWidth = inline ? (iconWidth + keyWidth + valWidth) : math.max(iconWidth + keyWidth, valWidth);
        if (rowWidth > maxWidth) maxWidth = rowWidth;
      }
      return maxWidth;
    };

Widget Function(BuildContext, TListItem<T, K>, int) _keyValuesCellBuilder<T, K>({
  required List<TKeyValue> Function(T) builder,
  required bool inline,
  required double spacing,
  required TextStyle? keyStyle,
  required TextStyle? valueStyle,
}) =>
    (ctx, item, __) {
      final scope = TTableScope.maybeOf(ctx);
      final isDense = scope?.dense ?? false;
      final items = builder(item.data);
      if (items.isEmpty) return const SizedBox.shrink();

      // Keys are the quieter label (onSurfaceVariant), values the prominent text (onSurface).
      final colors = ctx.colors;
      final baseStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
      final defaultValueStyle = baseStyle?.copyWith(color: colors.onSurface);
      final defaultKeyStyle = baseStyle?.adjust(
        sizeMultiplier: 0.8,
        color: Color.lerp(colors.onSurfaceVariant, colors.surface, 0.06),
        weightStep: 1,
      );

      final effectiveSpacing = isDense ? spacing * 0.75 : spacing;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: effectiveSpacing),
            if (inline)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (items[i].icon != null) ...[
                    items[i].icon!,
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '${items[i].key}: ',
                    style: keyStyle ?? defaultKeyStyle,
                  ),
                  if (items[i].widget != null)
                    Flexible(child: items[i].widget!)
                  else
                    Flexible(
                      child: Text(
                        items[i].value ?? '—',
                        style: valueStyle ?? defaultValueStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              )
            else ...[
              Text(
                items[i].key,
                style: keyStyle ?? defaultKeyStyle,
              ),
              if (items[i].widget != null)
                items[i].widget!
              else
                Text(
                  items[i].value ?? '—',
                  style: valueStyle ?? defaultValueStyle,
                ),
            ],
          ],
        ],
      );
    };

double Function(T data) _valuesWidthEstimator<T>({
  required List<TKeyValue> Function(T) builder,
}) =>
    (data) {
      final items = builder(data);
      if (items.isEmpty) return 0.0;
      double maxWidth = 0.0;
      for (int i = 0; i < items.length; i++) {
        final kv = items[i];
        final displayValue = kv.value ?? kv.key;
        final double sizeMultiplier = switch (i) {
          0 => 1.015,
          1 => 0.85,
          2 => 0.7,
          _ => 0.55,
        };
        final style = TTableTheme.fallbackTextStyle.adjust(sizeMultiplier: sizeMultiplier);
        var itemWidth = TTableTheme.measureTextWidth(displayValue, style);
        if (kv.icon != null) itemWidth += 20.0;
        if (itemWidth > maxWidth) maxWidth = itemWidth;
      }
      return maxWidth;
    };

Widget Function(BuildContext, TListItem<T, K>, int) _valuesCellBuilder<T, K>({
  required List<TKeyValue> Function(T) builder,
  required double spacing,
  required CrossAxisAlignment crossAxisAlignment,
  required MainAxisAlignment mainAxisAlignment,
}) =>
    (ctx, item, __) {
      final scope = TTableScope.maybeOf(ctx);
      final isDense = scope?.dense ?? false;
      final items = builder(item.data);
      if (items.isEmpty) return const SizedBox.shrink();

      final contentStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle ?? const TextStyle(fontSize: 13.6);

      final effectiveSpacing = isDense ? spacing * 0.75 : spacing;

      TextStyle? getLevelStyle(int index) {
        final double sizeMultiplier;
        final double? contrast;

        switch (index) {
          case 0:
            sizeMultiplier = 1.015;
            contrast = null;
            break;
          case 1:
            sizeMultiplier = 0.85;
            contrast = -0.5;
            break;
          case 2:
            sizeMultiplier = 0.7;
            contrast = -0.85;
            break;
          default:
            sizeMultiplier = 0.55;
            contrast = -1.0;
            break;
        }

        final baseColor = contentStyle.color;
        final targetColor = (contrast != null && baseColor != null) ? baseColor.adaptiveContrast(ctx, contrast) : baseColor;

        return contentStyle.adjust(
          sizeMultiplier: sizeMultiplier,
          color: targetColor,
        );
      }

      Widget buildItemWidget(TKeyValue kv, int index) {
        final levelStyle = getLevelStyle(index);
        final displayValue = kv.value ?? kv.key;

        Widget content;
        if (kv.widget != null) {
          content = DefaultTextStyle(
            style: levelStyle ?? const TextStyle(),
            child: kv.widget!,
          );
        } else {
          content = Text(
            displayValue,
            style: levelStyle,
            overflow: TextOverflow.ellipsis,
          );
        }

        if (kv.icon != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              kv.icon!,
              const SizedBox(width: 4),
              Flexible(child: content),
            ],
          );
        }

        return content;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: effectiveSpacing),
            buildItemWidget(items[i], i),
          ],
        ],
      );
    };

double Function(T data) _tileWidthEstimator<T>({
  required String? Function(T) title,
  required String? Function(T)? subtitle,
  required String? Function(T)? desc,
  required dynamic Function(T)? leading,
  required dynamic Function(T)? icon,
  required double? iconSize,
  required double spacing,
  required Widget Function(T)? trailing,
}) =>
    (data) {
      final t = title(data);
      final sub = subtitle?.call(data);
      final d = desc?.call(data);
      final tWidth = t != null ? TTableTheme.measureTextWidth(t) : 0.0;
      final sWidth = sub != null ? TTableTheme.measureTextWidth(sub) * 0.85 : 0.0;
      final dWidth = d != null ? TTableTheme.measureTextWidth(d) * 0.8 : 0.0;
      final textWidth = math.max(math.max(tWidth, sWidth), dWidth);
      final lead = leading?.call(data) ?? icon?.call(data);
      final hasIcon = lead != null;
      final iconWidth = hasIcon ? ((iconSize ?? (lead is Widget ? 80.0 : 20.0)) + 12.0 + spacing) : 0.0;
      final trailingWidth = trailing != null ? 30.0 : 0.0;
      return iconWidth + textWidth + trailingWidth;
    };

Widget Function(BuildContext, TListItem<T, K>, int) _tileCellBuilder<T, K>({
  required String? Function(T) title,
  required String? Function(T)? subtitle,
  required String? Function(T)? desc,
  required dynamic Function(T)? leading,
  required dynamic Function(T)? icon,
  required Color? Function(T)? iconColor,
  required Color? Function(T)? iconBackgroundColor,
  required Widget Function(T)? trailing,
  required double? iconSize,
  required EdgeInsetsGeometry? iconPadding,
  required BorderRadius? iconBorderRadius,
  required double spacing,
  required CrossAxisAlignment? crossAxisAlignment,
  required TextStyle? titleStyle,
  required TextStyle? subtitleStyle,
  required TextStyle? descStyle,
}) =>
    (ctx, item, __) {
      final scope = TTableScope.maybeOf(ctx);
      final isDense = scope?.dense ?? false;
      final t = title(item.data);
      final sub = subtitle?.call(item.data);
      final d = desc?.call(item.data);
      final lead = leading?.call(item.data) ?? icon?.call(item.data);
      final icColor = iconColor?.call(item.data);
      final icBgColor = iconBackgroundColor?.call(item.data);
      final tr = trailing?.call(item.data);

      final contentStyle = scope?.contentTextStyle ?? ctx.theme.tableTheme.rowCardTheme.contentTextStyle;
      final defaultTitleStyle = contentStyle?.adjust(
        sizeMultiplier: 1.015,
      );
      final defaultSubtitleStyle = contentStyle?.adjust(
        color: contentStyle.color?.adaptiveContrast(ctx, -0.5),
        sizeMultiplier: 0.85,
      );
      final defaultDescStyle = contentStyle?.adjust(
        color: contentStyle.color?.adaptiveContrast(ctx, -0.6),
        sizeMultiplier: 0.8,
      );

      return TTile(
        title: t,
        subtitle: sub,
        desc: d,
        icon: lead,
        iconColor: icColor,
        iconBackgroundColor: icBgColor,
        iconSize: isDense ? (iconSize != null ? iconSize * 0.8 : 16.0) : (iconSize ?? 20.0),
        iconPadding: isDense ? const EdgeInsets.all(6) : iconPadding,
        iconBorderRadius: iconBorderRadius,
        spacing: isDense ? spacing * 0.75 : spacing,
        crossAxisAlignment: crossAxisAlignment,
        titleStyle: titleStyle ?? defaultTitleStyle,
        subtitleStyle: subtitleStyle ?? defaultSubtitleStyle,
        descStyle: descStyle ?? defaultDescStyle,
        trailing: tr,
      );
    };

Widget Function(BuildContext, TListItem<T, K>, int) _actionsCellBuilder<T, K>({
  required List<TButtonGroupItem> Function(TListItem<T, K>) builder,
}) =>
    (ctx, item, __) {
      final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
      final allItems = builder(item);
      if (allItems.isEmpty) return const SizedBox.shrink();

      final hasExplicitFlat = allItems.any((b) => b.showFlat);
      final hasExplicitChild = allItems.any((b) => b.child != null);

      final List<TButtonGroupItem> effectiveItems;
      if (!hasExplicitFlat && !hasExplicitChild && allItems.length <= 2) {
        effectiveItems = allItems;
      } else if (!hasExplicitFlat && !hasExplicitChild && allItems.length > 2) {
        effectiveItems = [
          TButtonGroupItem(
            child: _buildActionDropdownMenu(ctx, allItems, isDense),
          ),
        ];
      } else {
        final flatButtons = <TButtonGroupItem>[];
        final menuButtons = <TButtonGroupItem>[];

        for (final btn in allItems) {
          if (btn.showFlat || btn.child != null) {
            flatButtons.add(btn);
          } else {
            menuButtons.add(btn);
          }
        }

        effectiveItems = <TButtonGroupItem>[...flatButtons];
        if (menuButtons.length == 1) {
          effectiveItems.add(menuButtons.first);
        } else if (menuButtons.isNotEmpty) {
          effectiveItems.add(TButtonGroupItem(
            child: _buildActionDropdownMenu(ctx, menuButtons, isDense),
          ));
        }
      }

      // The row card already pads its content, so cancel the cell's end padding to line the buttons up with the header text.
      return Transform.translate(
        offset: const Offset(5, 0),
        child: TButtonGroup(
          type: TButtonGroupType.softText,
          separated: true,
          spacing: 2,
          alignment: WrapAlignment.end,
          size: isDense ? TButtonSize.sm.copyWith(hPad: 3, vPad: 2) : TButtonSize.sm.copyWith(hPad: 6),
          items: effectiveItems,
        ),
      );
    };

double Function(T data) _defaultProgressWidthEstimator<T>({
  required double? Function(T) map,
  required String? Function(T)? valueText,
  required bool showPercentage,
  required TProgressValuePosition valuePosition,
  required double progressMaxWidth,
}) {
  return (data) {
    final val = map(data) ?? 0.0;
    final customValText = valueText?.call(data);
    String displayVal = '';
    if (customValText != null && showPercentage) {
      displayVal = '$customValText (${(val * 100).toInt()}%)';
    } else if (customValText != null) {
      displayVal = customValText;
    } else if (showPercentage) {
      displayVal = '${(val * 100).toInt()}%';
    }
    final valWidth = displayVal.isNotEmpty ? TTableTheme.measureTextWidth(displayVal) : 0.0;
    final isInline = valuePosition == TProgressValuePosition.afterProgress || valuePosition == TProgressValuePosition.beforeProgress;
    final minBarWidth = isInline ? 60.0 : 80.0;
    return math.min(progressMaxWidth, isInline ? (valWidth + minBarWidth + 16.0) : math.max(valWidth, minBarWidth));
  };
}

Widget _buildActionDropdownMenu(BuildContext ctx, List<TButtonGroupItem> buttons, bool isDense) {
  final dropdownItems = buttons.map((button) {
    return TDropdownItem(
      icon: button.icon,
      text: button.tooltip ?? button.text ?? '',
      color: button.color,
      onTap: () {
        if (button.onPressed != null) {
          button.onPressed!(TButtonPressOptions(stopLoading: () {}));
        } else if (button.onTap != null) {
          button.onTap!();
        }
      },
    );
  }).toList();

  return TDropdown(
    items: dropdownItems,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: TIcon.raw(
          HugeIcons.strokeRoundedMoreVertical,
          size: isDense ? 16 : 18,
          color: ctx.colors.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class _TStackedTableHeader<T, K> extends TTableHeader<T, K> {
  @override
  bool get fullBleedCell => true;

  _TStackedTableHeader(
    super.text,
    List<Widget> Function(T) rows, {
    super.flex,
    super.minWidth,
    super.maxWidth,
    super.alignment,
    required double rowHeight,
    required bool showDividers,
    Color? dividerColor,
    required EdgeInsetsGeometry contentPadding,
    super.key,
    super.widthEstimator,
    super.flattenOnMobile,
    super.showInDetails,
    super.mobileKeyPrefixBuilder,
  }) : super(
          estimatedHeight: rowHeight * 2,
          filterable: false,
          builder: (ctx, item, _) {
            final isDense = TTableScope.maybeOf(ctx)?.dense ?? false;
            return TSubRows(
              rowHeight: isDense ? rowHeight * 0.85 : rowHeight,
              showDividers: showDividers,
              dividerColor: dividerColor,
              padding: contentPadding,
              alignment: alignment ?? Alignment.centerLeft,
              children: rows(item.data),
            );
          },
        );
}
