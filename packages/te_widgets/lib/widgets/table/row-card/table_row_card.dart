import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A standard table row rendered as a card.
///
/// `TTableRowCard` renders a single row in a [TTable] using a [Table] layout.
/// It integrates with:
/// - [TTableHeader] for cell rendering
/// - [TListController] for selection/expansion state
class TTableRowCard<T, K> extends StatelessWidget {
  /// The index of the item.
  final int index;

  /// The list item data.
  final TListItem<T, K> item;

  /// The table headers definitions.
  final List<TTableHeader<T, K>> headers;

  /// Theme for the row card.
  final TTableRowCardTheme? theme;

  /// Optional fixed width.
  final double? width;

  /// Column width configuration for the underlying [Table].
  final Map<int, TableColumnWidth>? columnWidths;

  //expandable
  /// Whether the row is expandable.
  final bool expandable;

  /// Whether to render the leading expand/collapse icon.
  final bool showExpandIcon;

  /// Whether the row is currently expanded.
  final bool isExpanded;
  final bool isDetailExpanded;

  /// Callback when expansion toggles.
  final VoidCallback? onExpansionChanged;

  /// Content to show when expanded.
  final Widget? expandedContent;

  /// The expansion mode for details (bottom, side, dialog, page).
  final TTableExpansionMode expansionMode;

  /// Whether expansion happens on the side.
  final bool expandSide;

  /// Custom icon for collapsed state.
  final dynamic expandIcon;

  /// Custom icon for expanded state.
  final dynamic collapseIcon;

  //selectable
  /// Whether the row is selectable.
  final bool selectable;

  /// Whether the row is selected.
  final bool isSelected;

  /// Callback when selection toggles.
  final VoidCallback? onSelectionChanged;

  /// When non-null, a trailing delete icon is shown and calls this.
  final VoidCallback? onRemove;

  /// Callback when row card tapped.
  final VoidCallback? onTap;

  /// Custom background color for the row.
  final Color? backgroundColor;

  /// Creates a table row card.
  /// Renders only the row cells, without the card surface or built-in tree chevron/indent.
  /// Used inside a [TTreeCard] which supplies the surface and the tree connectors.
  final bool bare;

  const TTableRowCard({
    super.key,
    required this.index,
    required this.item,
    required this.headers,
    this.columnWidths,
    this.theme,
    this.width,

    //expandable
    this.expandable = false,
    this.showExpandIcon = true,
    this.isExpanded = false,
    this.isDetailExpanded = false,
    this.onExpansionChanged,
    this.expandedContent,
    this.expansionMode = TTableExpansionMode.bottom,
    this.expandSide = false,
    this.expandIcon,
    this.collapseIcon,

    //selectable
    this.selectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onTap,
    this.onRemove,
    this.backgroundColor,
    this.bare = false,
  });

  dynamic _getDetailExpandIcon(TTableExpansionMode mode, bool isExpanded) {
    if (isExpanded && collapseIcon != null) return collapseIcon;
    if (!isExpanded && expandIcon != null) return expandIcon;

    switch (mode) {
      case TTableExpansionMode.dialog:
        return isExpanded ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedArrowUp02;
      case TTableExpansionMode.sideOverlay:
        return isExpanded ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedArrowUpRight01;
      case TTableExpansionMode.side:
        return isExpanded ? HugeIcons.strokeRoundedArrowLeft01 : HugeIcons.strokeRoundedArrowRight01;
      case TTableExpansionMode.page:
        return isExpanded ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedLinkForward;
      case TTableExpansionMode.bottom:
        return isExpanded ? HugeIcons.strokeRoundedArrowUp01 : HugeIcons.strokeRoundedArrowDown01;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wTheme = theme ?? TTableScope.maybeOf(context)?.theme?.rowCardTheme ?? context.theme.tableTheme.rowCardTheme;
    final states = <WidgetState>{if (isSelected) WidgetState.selected};
    final themeBgColor = wTheme.backgroundColor.resolve(states);
    final resolvedBgColor = backgroundColor ?? themeBgColor;

    final controller = TTableScope.maybeOf(context)?.controller;
    final isDense = TTableScope.maybeOf(context)?.dense ?? false;
    final indentWidth = bare ? 0.0 : item.level * 16.0;

    final content = _buildContent(context, colors, wTheme, controller, isDense, indentWidth);
    if (bare) return content;

    final hover = colors.onSurface.withAlpha(12);
    final activeTint = colors.onSurface.withAlpha(6); // lighter than hover
    final active = TTableCellScope.maybeOf(context);

    Widget buildCard(Color bg) => TCard(
          margin: wTheme.margin,
          elevation: wTheme.elevation,
          borderRadius: wTheme.borderRadius,
          borderColor: Colors.transparent,
          backgroundColor: bg,
          padding: wTheme.padding,
          // A non-null tap keeps the InkWell enabled; the tint itself is painted via [bg] below.
          onTap: () {
            // Editable tables: tapping anywhere on the row switches every editable cell to its input.
            if (active != null && !(active.value?.startsWith('${item.key}_') ?? false)) active.value = '${item.key}_';
            onTap?.call();
          },
          mouseCursor: onTap == null && active == null ? SystemMouseCursors.basic : null,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: content,
        );

    // Hover tint is painted on the background so it can persist while the row is in input mode
    // (focus inside the row's inputs never darkens the whole row).
    return TTableRowHover(
      builder: (hovered) {
        if (active == null) return buildCard(hovered ? Color.alphaBlend(hover, resolvedBgColor) : resolvedBgColor);
        return ValueListenableBuilder<String?>(
          valueListenable: active,
          builder: (_, v, __) {
            final isActive = v?.startsWith('${item.key}_') ?? false;
            return buildCard(Color.alphaBlend(hovered ? hover : (isActive ? activeTint : Colors.transparent), resolvedBgColor));
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colors, TTableRowCardTheme wTheme, TListController<dynamic, dynamic>? controller,
      bool isDense, double indentWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              if (controller?.reorderable ?? false)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TDragHandle(index: index, size: 14, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
                ),
              if (expandable && showExpandIcon)
                Builder(builder: (context) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: TIcon(
                      icon: _getDetailExpandIcon(expansionMode, isDetailExpanded),
                      size: isDense ? 18 : 20,
                      padding: isDense ? const EdgeInsets.all(3) : const EdgeInsets.all(6),
                      color: colors.onSurfaceVariant,
                      background: TGlassStyle.frost(context, colors.surfaceContainerLow),
                      active: isDetailExpanded,
                      onTap: onExpansionChanged,
                    ),
                  );
                }),
              if (selectable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TCheckbox(value: isSelected, onValueChanged: (v) => onSelectionChanged?.call()),
                ),
              ...headers.asMap().entries.map((entry) {
                final headerIndex = entry.key;
                final header = entry.value;

                Widget cellWidget = header.builder != null
                    ? Builder(
                        builder: (context) => DefaultTextStyle.merge(
                          style: wTheme.contentTextStyle,
                          child: header.builder!(context, item, index),
                        ),
                      )
                    : Text(header.getValue(item.data), style: wTheme.contentTextStyle);

                if (headerIndex == 0) {
                  final iconSlotWidth = isDense ? 20.0 : 24.0;
                  final isTreeMode = !bare && ((controller?.isHierarchical ?? false) || item.level > 0 || item.hasChildren);

                  cellWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (indentWidth > 0) SizedBox(width: indentWidth),
                      if (item.hasChildren && !bare) ...[
                        Builder(builder: (ctx) {
                          final isTreeExpanded = controller?.isExpanded(item.key) ?? false;
                          final isAutoMode = controller?.expansionMode == TExpansionMode.auto;

                          Widget iconWidget = Padding(
                            padding: const EdgeInsets.only(top: 1.5),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                controller?.toggleExpansion(item.key);
                              },
                              onDoubleTap: isAutoMode
                                  ? () {
                                      controller?.toggleExpandDescendants(item.key);
                                    }
                                  : null,
                              child: TIcon(
                                icon: isTreeExpanded ? HugeIcons.strokeRoundedArrowDown01 : HugeIcons.strokeRoundedArrowRight01,
                                size: isDense ? 18 : 20,
                                padding: const EdgeInsets.all(0),
                                color: colors.onSurfaceVariant,
                                background: TGlassStyle.frost(context, colors.surfaceContainerLow),
                                active: isTreeExpanded,
                              ),
                            ),
                          );

                          return iconWidget;
                        }),
                        const SizedBox(width: 6),
                      ] else if (isTreeMode) ...[
                        SizedBox(width: iconSlotWidth),
                      ],
                      Flexible(child: cellWidget),
                    ],
                  );
                }

                final isTreeMode = !bare && ((controller?.isHierarchical ?? false) || item.level > 0 || item.hasChildren);
                final treeArrowWidth = item.hasChildren ? 26.0 : (isTreeMode ? (isDense ? 20.0 : 24.0) : 0.0);
                final rowTreeExtraWidth = (headerIndex == 0 && isTreeMode) ? (indentWidth + treeArrowWidth) : 0.0;
                final cellMinWidth = (header.minWidth ?? 50) + rowTreeExtraWidth;
                final cellMaxWidth = (header.maxWidth != null && header.maxWidth != double.infinity)
                    ? header.maxWidth! + rowTreeExtraWidth
                    : double.infinity;
                final cellKey = "${item.key}_${header.text}";
                final cellScope = TTableCellScope.maybeScopeOf(context);
                final activeCursor = cellScope?.activeCellNotifier ?? TTableCellScope.maybeOf(context);

                // Per-value scoreboard flip: the cell flips to its new content whenever the value it shows changes.
                final Object? valueSignature = header.map != null
                    ? header.getValue(item.data)
                    : header.keyValuesBuilder != null
                        ? header.keyValuesBuilder!(item.data).map((e) => '${e.key}=${e.value}').join('|')
                        : item.data;

                final cellContainer = Container(
                  constraints: BoxConstraints(minWidth: cellMinWidth, maxWidth: cellMaxWidth),
                  padding: header.fullBleedCell ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 5),
                  alignment: header.alignment ?? Alignment.centerLeft,
                  // Action columns (showInDetails: false) never flip.
                  child: _TCellFlip(signature: header.showInDetails ? valueSignature : null, child: cellWidget),
                );

                if (activeCursor != null) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => activeCursor.value = cellKey,
                    child: cellContainer,
                  );
                }

                return cellContainer;
              }),
              if (onRemove != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    size: isDense ? 16 : 18,
                    padding: const EdgeInsets.all(4),
                    color: colors.error,
                    onTap: onRemove,
                  ),
                ),
            ])
          ],
        ),
        if (expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isDetailExpanded && !expandSide
                ? Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: wTheme.padding.top),
                    child: expandedContent,
                  )
                : const SizedBox.shrink(),
          )
      ],
    );
  }
}

/// Tracks pointer hover for a table row/card so the tint can be painted on its background.
class TTableRowHover extends StatefulWidget {
  /// Builds the row; [hovered] is true while the pointer is over it.
  final Widget Function(bool hovered) builder;

  /// Creates a hover tracker.
  const TTableRowHover({super.key, required this.builder});

  @override
  State<TTableRowHover> createState() => TTableRowHoverState();
}

class TTableRowHoverState extends State<TTableRowHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(_hovered),
    );
  }
}

/// Flips its content like a scoreboard card whenever [signature] changes: the old content folds away, the new one folds in.
class _TCellFlip extends StatefulWidget {
  final Object? signature;
  final Widget child;

  const _TCellFlip({required this.signature, required this.child});

  @override
  State<_TCellFlip> createState() => _TCellFlipState();
}

class _TCellFlipState extends State<_TCellFlip> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  Widget? _before;
  Timer? _wait;

  /// True while a dialog / overlay / detail panel covers the table, so a flip would play unseen.
  bool get _obscured {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return true;
    final v = TTableScope.maybeOf(context)?.controller.value;
    return v != null && (v.isEditingItem || v.expandedDetailKey != null);
  }

  @override
  void didUpdateWidget(covariant _TCellFlip old) {
    super.didUpdateWidget(old);
    if (old.signature == widget.signature) return;
    // Keep the oldest content when several changes arrive while waiting.
    if (_wait == null) _before = old.child;
    if (!_obscured) {
      _wait?.cancel();
      _wait = null;
      _c.forward(from: 0);
      return;
    }
    // Hold the flip until the cover closes (bounded, so it never waits forever).
    var polls = 0;
    _wait?.cancel();
    _wait = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) return t.cancel();
      if (_obscured && ++polls < 150) return;
      t.cancel();
      _wait = null;
      _c.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        if (_before == null || !_c.isAnimating) return child!;
        final accent = Theme.of(context).colorScheme.primary;
        final showOld = t < 0.5;
        final angle =
            showOld ? Curves.easeIn.transform(t * 2) * (math.pi / 2) : -(1 - Curves.easeOutBack.transform((t - 0.5) * 2)) * (math.pi / 2);
        // The accent tint peaks right after the new value lands and fades out.
        final tint = t < 0.5 ? 0.0 : (1 - (t - 0.5) * 2) * 0.22;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.004)
            ..rotateX(angle),
          child: DecoratedBox(
            decoration: BoxDecoration(color: accent.withValues(alpha: tint), borderRadius: BorderRadius.circular(6)),
            child: showOld ? _before : child,
          ),
        );
      },
    );
  }
}
