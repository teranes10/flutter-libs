import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A master-detail split layout widget that displays a list of items on the left
/// and details of the selected item on the right.
///
/// `TListDetail` is responsive: on wider screens it splits the screen into a sidebar
/// list and a details pane, while on narrower (mobile) screens it behaves like a navigation stack.
class TListDetail<T, K> extends StatefulWidget with TListMixin<T, K> {
  /// Builder for rendering the detail content of the selected item.
  final Widget Function(BuildContext context, TListItem<T, K> item, int index) detailBuilder;

  /// Optional builder to display when creating a new item.
  final Widget Function(BuildContext context)? createBuilder;

  /// Optional builder to display when editing an item.
  final Widget Function(BuildContext context, TListItem<T, K> item, int index)? editBuilder;

  /// Optional builder for a header widget above the sidebar search bar.
  final WidgetBuilder? sidebarHeaderBuilder;

  /// Optional builder for a footer widget below the sidebar list.
  final WidgetBuilder? sidebarFooterBuilder;

  /// Callback to extract the title from an item.
  final String? Function(T item)? itemTitle;

  /// Callback to extract the subtitle from an item.
  final String? Function(T item)? itemSubTitle;

  /// Callback to extract the image URL from an item.
  final String? Function(T item)? itemImageUrl;

  /// Optional custom builder for items in the list. If null, a default [TListCard] is rendered.
  final ListItemBuilder<T, K>? itemBuilder;

  /// Optional actions to display in the header/AppBar of the detail pane.
  final List<Widget> Function(T item)? actions;

  /// The width of the left side list/sidebar on wide screens. Defaults to 275.0.
  final double sideListWidth;

  /// The minimum width required to show the split master-detail layout.
  /// If constraints are below this value, it collapses to a single pane. Defaults to 700.0.
  final double minSideExpandWidth;

  /// Whether to show the search text field in the sidebar. Defaults to true.
  final bool showSearch;

  /// Placeholder text for the search field. Defaults to 'Search...'.
  final String searchPlaceholder;

  /// The horizontal gap/spacing between the sidebar card and detail card in split layout.
  /// Defaults to 12.0.
  final double gap;

  /// Optional padding around the split layout.
  final EdgeInsetsGeometry? padding;

  /// Default border radius for both cards in split layout.
  /// Defaults to `BorderRadius.circular(16)`.
  final BorderRadius? borderRadius;

  /// Default shadow for both cards in split layout.
  /// Defaults to a modern subtle elevation shadow.
  final List<BoxShadow>? shadow;

  /// Default border color for both cards in split layout.
  /// Defaults to `colors.outlineVariant.o(0.5)`.
  final Color? borderColor;

  /// Custom border radius override for the items sidebar panel in split layout.
  final BorderRadius? sidebarBorderRadius;

  /// Custom shadow override for the items sidebar panel in split layout.
  final List<BoxShadow>? sidebarShadow;

  /// Custom border color override for the items sidebar panel in split layout.
  final Color? sidebarBorderColor;

  /// Custom border radius override for the detail pane in split layout.
  final BorderRadius? detailBorderRadius;

  /// Custom shadow override for the detail pane in split layout.
  final List<BoxShadow>? detailShadow;

  /// Custom border color override for the detail pane in split layout.
  final Color? detailBorderColor;

  /// Optional background color for the floating cards.
  /// Defaults to [ColorScheme.surface] when null.
  final Color? cardBackgroundColor;

  /// Optional background color for the container behind the cards.
  /// Defaults to [ColorScheme.surface] when null.
  final Color? backgroundColor;

  /// Optional custom builder for the empty state when no item is selected.
  final WidgetBuilder? emptyBuilder;

  /// Optional icon to display in the default empty state.
  /// Defaults to [Icons.touch_app_outlined].
  final IconData? emptyIcon;

  /// Optional title text in the default empty state.
  /// Defaults to 'No item selected'.
  final String? emptyTitle;

  /// Optional description text in the default empty state.
  /// Defaults to 'Select an item from the list to view its details'.
  final String? emptyDescription;

  // TListMixin implementation properties
  @override
  final List<T>? items;

  @override
  final int? itemsPerPage;

  @override
  final String? search;

  @override
  final int? searchDelay;

  @override
  final TLoadListener<T>? onLoad;

  @override
  final ItemKeyAccessor<T, K>? itemKey;

  @override
  final TListController<T, K>? controller;

  @override
  final TControllerReadyListener<T, K>? onControllerReady;

  const TListDetail({
    super.key,
    required this.detailBuilder,
    this.createBuilder,
    this.editBuilder,
    this.sidebarHeaderBuilder,
    this.sidebarFooterBuilder,
    this.itemTitle,
    this.itemSubTitle,
    this.itemImageUrl,
    this.itemBuilder,
    this.actions,
    this.sideListWidth = 275.0,
    this.minSideExpandWidth = 700.0,
    this.showSearch = true,
    this.searchPlaceholder = 'Search...',
    this.gap = 0.0,
    this.padding,
    this.borderRadius,
    this.shadow,
    this.borderColor,
    this.sidebarBorderRadius,
    this.sidebarShadow,
    this.sidebarBorderColor,
    this.detailBorderRadius,
    this.detailShadow,
    this.detailBorderColor,
    this.cardBackgroundColor,
    this.backgroundColor,
    this.emptyBuilder,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    // List Config
    this.items,
    this.itemsPerPage,
    this.search,
    this.searchDelay,
    this.onLoad,
    this.itemKey,
    this.controller,
    this.onControllerReady,
  });

  @override
  State<TListDetail<T, K>> createState() => _TListDetailState<T, K>();
}

class _TListDetailState<T, K> extends State<TListDetail<T, K>> with TListStateMixin<T, K, TListDetail<T, K>> {
  @override
  TListController<T, K> buildController() {
    return TListController<T, K>(
      items: widget.items ?? [],
      itemsPerPage: widget.itemsPerPage ?? 0,
      search: widget.search ?? '',
      searchDelay: widget.searchDelay,
      onLoad: widget.onLoad,
      itemKey: widget.itemKey,
      expansionMode: TExpansionMode.single,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveBg = widget.backgroundColor ?? context.getBackgroundColor(colors.surface);
    final effectiveCardBg = widget.cardBackgroundColor ?? effectiveBg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSplitLayout = constraints.maxWidth >= widget.minSideExpandWidth;

        return TListScope(
          controller: listController,
          child: Container(
            color: effectiveBg,
            child: TBackgroundColorScope(
              backgroundColor: effectiveBg,
              child: ListenableBuilder(
                listenable: listController,
                builder: (context, _) {
                  final val = listController.value;
                  final isCreating = val.isCreatingItem;
                  final isEditing = val.isEditingItem;

                  // We check both activeKey and expandedDetailKey for the active selected item
                  final activeKey = val.activeKey ?? val.expandedDetailKey;
                  final TListItem<T, K>? activeItem = activeKey != null ? listController.getItem(activeKey) : null;
                  final activeIndex = activeItem != null ? val.displayItems.indexWhere((x) => x.key == activeItem.key) : -1;

                  final hasDetailTarget = isCreating || isEditing || activeItem != null;

                  Widget layoutWidget;
                  if (showSplitLayout) {
                    layoutWidget = Row(
                      key: const ValueKey('list_detail_split_layout'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: widget.sideListWidth,
                          child: _buildSidebar(context, colors, effectiveCardBg, true),
                        ),
                        SizedBox(width: widget.gap),
                        Expanded(
                          child: _buildDetailPane(
                            context,
                            colors,
                            effectiveCardBg,
                            activeItem,
                            activeIndex,
                            isCreating,
                            isEditing,
                            true,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout: stack/single pane view
                    if (hasDetailTarget) {
                      layoutWidget = _buildDetailPane(
                        context,
                        colors,
                        effectiveCardBg,
                        activeItem,
                        activeIndex,
                        isCreating,
                        isEditing,
                        false,
                      );
                    } else {
                      layoutWidget = _buildSidebar(context, colors, effectiveCardBg, false);
                    }
                  }

                  if (widget.padding != null) {
                    return Padding(
                      padding: widget.padding!,
                      child: layoutWidget,
                    );
                  }

                  return layoutWidget;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, ColorScheme colors, Color effectiveCardBg, bool isSplit) {
    final listWidget = TList<T, K>(
      controller: listController,
      shrinkWrap: false,
      itemBuilder: widget.itemBuilder ??
          (ctx, item, index) {
            final title = widget.itemTitle?.call(item.data) ?? item.data.toString();
            final subTitle = widget.itemSubTitle?.call(item.data);
            final imageUrl = widget.itemImageUrl?.call(item.data);
            final isSelected = listController.isDetailExpanded(item.key);

            return TListCard(
              title: title,
              subTitle: subTitle,
              imageUrl: imageUrl,
              isSelected: isSelected,
              onTap: () {
                listController.expandDetail(item.key);
              },
            );
          },
    );

    final sidebarContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.sidebarHeaderBuilder != null) widget.sidebarHeaderBuilder!(context),
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 12, top: 12),
            child: Row(
              children: [
                Expanded(
                  child: TTextField(
                    value: listController.value.search,
                    theme: context.theme.textFieldTheme.copyWith(
                      size: TInputSize.sm,
                      labelPosition: TLabelPosition.aboveField,
                      decorationType: TInputDecorationType.filled,
                      postWidget: Icon(Icons.search_rounded, size: 18, color: colors.onSurface),
                    ),
                    placeholder: widget.searchPlaceholder,
                    onValueChanged: (String? input) {
                      listController.handleSearchChange(input ?? '');
                    },
                  ),
                ),
                if (widget.createBuilder != null) ...[
                  const SizedBox(width: 8),
                  TButton(
                    type: TButtonType.tonal,
                    size: TButtonSize.sm,
                    icon: Icons.add,
                    onPressed: (_) => listController.beginCreateItem(),
                  ),
                ],
              ],
            ),
          ),
        Expanded(child: listWidget),
        if (widget.sidebarFooterBuilder != null) widget.sidebarFooterBuilder!(context),
      ],
    );

    if (!isSplit) {
      return Container(
        color: effectiveCardBg,
        child: sidebarContent,
      );
    }

    return sidebarContent;
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.o(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.emptyIcon ?? Icons.touch_app_outlined,
                size: 28,
                color: colors.onSurfaceVariant.o(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyTitle ?? 'No item selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.emptyDescription ?? 'Select an item from the list to view its details',
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPane(
    BuildContext context,
    ColorScheme colors,
    Color effectiveCardBg,
    TListItem<T, K>? item,
    int index,
    bool isCreating,
    bool isEditing,
    bool isSplit,
  ) {
    Widget content;
    if (!isCreating && !isEditing && item == null) {
      content = _buildEmptyState(context, colors);
    } else {
      Widget bodyContent;
      if (isCreating) {
        bodyContent = widget.createBuilder?.call(context) ?? const SizedBox.shrink();
      } else if (isEditing && widget.editBuilder != null) {
        bodyContent = widget.editBuilder!(context, item!, index);
      } else {
        bodyContent = widget.detailBuilder(context, item!, index);
      }

      final title = isCreating ? 'Create' : (isEditing ? 'Edit' : (item != null ? widget.itemTitle?.call(item.data) : null));
      final subTitle = (isCreating || item == null) ? null : widget.itemSubTitle?.call(item.data);
      final imageUrl = (isCreating || item == null) ? null : widget.itemImageUrl?.call(item.data);

      final actions = (!isCreating && !isEditing && item != null) ? widget.actions?.call(item.data) : null;

      content = TPageWrapper(
        backgroundColor: effectiveCardBg,
        title: title,
        subTitle: subTitle,
        imageUrl: imageUrl,
        actions: actions,
        onBackPressed: () {
          final tableScope = TTableScope.maybeOf(context);
          if (tableScope != null) {
            tableScope.close(context);
          } else if (isCreating) {
            listController.cancelCreateItem();
          } else if (isEditing) {
            listController.cancelEditItem();
          } else {
            listController.collapseDetail();
            listController.collapseAll();
          }
        },
        child: bodyContent,
      );
    }

    if (!isSplit) {
      return Container(
        color: effectiveCardBg,
        child: content,
      );
    }

    final effectiveRadius = widget.detailBorderRadius ?? widget.borderRadius ?? BorderRadius.circular(16);
    final effectiveBorderColor = widget.detailBorderColor ?? widget.borderColor ?? colors.outlineVariant.o(0.5);

    return Container(
      margin: EdgeInsets.only(right: 6),
      decoration:
          BoxDecoration(color: effectiveCardBg, borderRadius: effectiveRadius, border: Border.all(color: effectiveBorderColor), boxShadow: [
        BoxShadow(
          blurRadius: 6,
          spreadRadius: 0,
          color: colors.shadow,
          offset: Offset(-2, 0),
        ),
      ]),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: content,
      ),
    );
  }
}
