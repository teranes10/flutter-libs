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

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSplitLayout = constraints.maxWidth >= widget.minSideExpandWidth;

        return TListScope(
          controller: listController,
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

              if (showSplitLayout) {
                return Row(
                  key: const ValueKey('list_detail_split_layout'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: widget.sideListWidth,
                      child: _buildSidebar(context, colors),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: colors.outlineVariant),
                    Expanded(
                      child: _buildDetailPane(context, colors, activeItem, activeIndex, isCreating, isEditing, true),
                    ),
                  ],
                );
              } else {
                // Mobile layout: stack/single pane view
                if (hasDetailTarget) {
                  return _buildDetailPane(context, colors, activeItem, activeIndex, isCreating, isEditing, false);
                } else {
                  return _buildSidebar(context, colors);
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, ColorScheme colors) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.sidebarHeaderBuilder != null) widget.sidebarHeaderBuilder!(context),
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 12, left: 12, top: 8),
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
  }

  Widget _buildDetailPane(
    BuildContext context,
    ColorScheme colors,
    TListItem<T, K>? item,
    int index,
    bool isCreating,
    bool isEditing,
    bool isSplit,
  ) {
    if (!isCreating && !isEditing && item == null) {
      return Container(
        color: colors.surface,
        child: Center(
          child: Text(
            'Select an item to view details',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      );
    }

    Widget content;
    if (isCreating) {
      content = widget.createBuilder?.call(context) ?? const SizedBox.shrink();
    } else if (isEditing && widget.editBuilder != null) {
      content = widget.editBuilder!(context, item!, index);
    } else {
      content = widget.detailBuilder(context, item!, index);
    }

    final title = isCreating
        ? 'Create'
        : (isEditing ? 'Edit' : (item != null ? widget.itemTitle?.call(item.data) : null));
    final subTitle = (isCreating || item == null) ? null : widget.itemSubTitle?.call(item.data);
    final imageUrl = (isCreating || item == null) ? null : widget.itemImageUrl?.call(item.data);

    final actions = (!isCreating && !isEditing && item != null) ? widget.actions?.call(item.data) : null;

    final background = context.getBackgroundColor(colors.surface);
    final wrapperBackground = isSplit ? background.adaptiveContrast(context, 0.01) : background;

    return Container(
      color: wrapperBackground,
      child: TBackgroundColorScope(
        backgroundColor: wrapperBackground,
        child: TPageWrapper(
          title: title,
          subTitle: subTitle,
          imageUrl: imageUrl,
          actions: actions,
          onBackPressed: () {
            if (isCreating) {
              listController.cancelCreateItem();
            } else if (isEditing) {
              listController.cancelEditItem();
            } else {
              listController.collapseAll();
            }
          },
          child: content,
        ),
      ),
    );
  }
}
