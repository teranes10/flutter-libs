part of 'table.dart';

typedef TTableCreateBuilder<T, K> = Widget Function(BuildContext ctx, TListItem<T, K>? item, int? index);

enum TTableExpansionMode { bottom, side, dialog, page }

/// Details and expansion configuration for the table.
class TTableDetails<T, K> {
  /// Defines how the expanded content is presented.
  final TTableExpansionMode mode;

  /// Defines how the expanded content is presented during creation/editing.
  final TTableExpansionMode? createMode;

  /// Function to extract the title from an item (used in dialogs/pages).
  final String? Function(T item)? itemTitle;

  /// Function to extract the sub-title from an item (used in dialogs/pages).
  final String? Function(T item)? itemSubTitle;

  /// Function to extract the description from an item (used in dialogs/pages).
  final String? Function(T item)? itemDescription;

  /// Function to extract the image URL from an item (used in dialogs/pages).
  final String? Function(T item)? itemImageUrl;

  /// Actions to display in the page wrapper for a specific item. Only shown in view mode.
  final List<Widget> Function(T item)? actions;

  /// Callback fired before a row expansion changes.
  /// Return true to allow the expansion change, or false to prevent it.
  final Future<bool> Function(K key)? onWillExpand;

  /// Callback fired before the table's detail view / panel closes.
  /// Return true to allow the close, or false to prevent it.
  final Future<bool> Function(K key)? onWillCollapse;

  /// Whether to dim the rest of the table and scroll to the expanded item.
  final bool focus;

  /// Opacity level to apply to headers and footer when table is dimmed.
  final double? dimmedOpacity;

  /// Builder for expanded content of a row.
  final TListExpandedBuilder<T, K>? builder;

  /// Builder for expanded content of a row when creating or editing.
  final TTableCreateBuilder<T, K>? createBuilder;

  /// Function to extract the title when creating/editing.
  final String? Function(T? item)? createTitle;

  /// Optional layout builder for custom details wrapper.
  final Widget Function(BuildContext context, TTableDetails<T, K> details, T? item, Widget child)? layoutBuilder;

  /// Whether to show the details layout/page wrapper when expansion mode is bottom.
  final bool showLayoutForBottom;

  /// The width of the dialog when expansion mode is dialog. Defaults to 800.
  final double dialogWidth;

  /// The width of the dialog when creating or editing items in dialog mode. Defaults to [dialogWidth] or 800.
  final double? createDialogWidth;

  const TTableDetails({
    this.mode = TTableExpansionMode.bottom,
    this.createMode,
    this.itemTitle,
    this.itemSubTitle,
    this.itemDescription,
    this.itemImageUrl,
    this.actions,
    this.onWillExpand,
    this.onWillCollapse,
    this.focus = false,
    this.dimmedOpacity,
    this.builder,
    this.createBuilder,
    this.createTitle,
    this.layoutBuilder,
    this.showLayoutForBottom = false,
    this.dialogWidth = 800.0,
    this.createDialogWidth,
  });
}

enum _DetailKind { view, edit, create }

/// Represents exactly what detail content should currently be shown,
/// independent of *how* it's presented (bottom/side/dialog/page).
class _ActiveDetailTarget<K> {
  final _DetailKind kind;
  final K? key; // null while creating (no active item yet)
  final TTableExpansionMode mode;

  const _ActiveDetailTarget({required this.kind, required this.key, required this.mode});
}

bool _sameDetailTarget<K>(_ActiveDetailTarget<K>? a, _ActiveDetailTarget<K>? b) {
  if (a == null || b == null) return a == b;
  return a.kind == b.kind && a.key == b.key && a.mode == b.mode;
}

const Object _kTransitionResult = 'table_transition';

bool _isOverlayMode(TTableExpansionMode mode) => mode == TTableExpansionMode.dialog || mode == TTableExpansionMode.page;

extension _TTableDetailsExt<T, K> on _TTableState<T, K> {
  /// Derives what *should* be shown right now from controller state.
  /// This is the single decision point for view vs edit vs create.
  _ActiveDetailTarget<K>? _computeDesiredTarget() {
    final details = widget.details;
    if (details == null) return null;

    final v = listController.value;
    final hasCreateBuilder = details.createBuilder != null;

    if ((v.isCreatingItem || v.isEditingItem) && hasCreateBuilder) {
      return _ActiveDetailTarget<K>(
        kind: v.isCreatingItem ? _DetailKind.create : _DetailKind.edit,
        key: v.activeKey, // null while creating, set while editing
        mode: details.createMode ?? details.mode,
      );
    }
    if (v.activeItem != null) {
      return _ActiveDetailTarget<K>(kind: _DetailKind.view, key: v.activeKey, mode: details.mode);
    }
    return null;
  }

  (TTableExpansionMode mode, Widget Function(BuildContext context) builder)? getEffectiveConfig() {
    final details = widget.details;
    if (details == null) return null;

    final target = _computeDesiredTarget();
    if (target == null) return null;

    final v = listController.value;
    final activeItem = v.activeItem;
    final activeIndex = v.activeIndex;
    final itemData = activeItem?.data;
    final isCreating = target.kind == _DetailKind.create;
    final isEditing = target.kind == _DetailKind.edit;

    Widget content(BuildContext ctx) => (isCreating || isEditing)
        ? details.createBuilder!.call(ctx, activeItem, activeIndex)
        : details.builder?.call(ctx, activeItem!, activeIndex) ??
            wTheme.buildDefaultExpandedContent(ctx.colors, activeItem!.data, activeIndex);

    return (target.mode, (ctx) => getLayoutWrapper(ctx, details, isCreating, isEditing, itemData, content(ctx)));
  }

  /// Wraps builder output with the scope needed by every presentation mode
  /// (side panel, dialog, page). Extracted so it's written once.
  Widget _buildScopedContent(TTableExpansionMode mode, Widget Function(BuildContext) builder) {
    return TTableScope(
      controller: listController,
      dense: wTheme.dense ?? false,
      expansionMode: mode,
      onWillCollapse: widget.details?.onWillCollapse != null ? (dynamic key) => widget.details!.onWillCollapse!(key as K) : null,
      child: Builder(builder: builder),
    );
  }

  Widget getCardWrapper(Widget child) {
    final background = context.getBackgroundColor(context.colors.surface);
    final newBackground = background.adaptiveContrast(context, 0.01);
    final newBorder = newBackground.adaptiveContrast(context, 0.015);

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: newBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: newBorder),
      ),
      child: TBackgroundColorScope(
        backgroundColor: newBackground,
        child: child,
      ),
    );
  }

  Widget getLayoutWrapper(
    BuildContext context,
    TTableDetails<T, K> details,
    bool isCreating,
    bool isEditing,
    T? itemData,
    Widget child,
  ) {
    final showLayout = details.mode != TTableExpansionMode.bottom || details.showLayoutForBottom;
    if (!showLayout) {
      return getCardWrapper(child);
    }

    if (details.layoutBuilder != null) return details.layoutBuilder!(context, details, itemData, child);

    final title =
        isCreating ? (details.createTitle?.call(itemData) ?? 'Create') : (itemData != null ? details.itemTitle?.call(itemData) : null);

    final subTitle = (isCreating || itemData == null) ? null : details.itemSubTitle?.call(itemData);
    final description = (isCreating || itemData == null) ? null : details.itemDescription?.call(itemData);
    final imageUrl = (isCreating || itemData == null) ? null : details.itemImageUrl?.call(itemData);
    final actions = (!isCreating && !isEditing && itemData != null) ? details.actions?.call(itemData) : null;

    final pageWrapper = TPageWrapper(
      title: title,
      subTitle: subTitle,
      description: description,
      imageUrl: imageUrl,
      actions: actions,
      onBackPressed: () => TTableScope.of(context).close(context),
      shrinkWrap: details.mode == TTableExpansionMode.dialog,
      child: child,
    );

    return details.mode == TTableExpansionMode.side ? getCardWrapper(pageWrapper) : pageWrapper;
  }

  /// Single reconciliation point, called whenever controller state changes.
  /// Diffs desired vs current target and performs the minimal transition:
  ///  - no-op if nothing changed
  ///  - closes a stale overlay (dialog/page) before opening/leaving it
  ///  - just rebuilds for inline modes (bottom/side)
  void _syncDetailFlow() {
    final desired = _computeDesiredTarget();
    final current = _currentTarget;

    if (_sameDetailTarget(desired, current)) return;

    final wasOverlay = current != null && _isOverlayMode(current.mode);
    _currentTarget = desired;

    // Any existing dialog/page must be popped before we move on — whether
    // we're closing entirely, switching to a different overlay target,
    // or dropping down to an inline mode. The sentinel result tells the
    // pop handler this was a controlled transition, not a user dismissal.
    if (wasOverlay) {
      _dismissOverlay(current.mode, result: _kTransitionResult);
    }

    if (desired == null) {
      refresh();
      return;
    }

    if (_isOverlayMode(desired.mode)) {
      _presentOverlay(desired);
    } else {
      refresh(); // bottom / side just re-render inline
    }
  }

  void _dismissOverlay(TTableExpansionMode mode, {Object? result}) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: mode == TTableExpansionMode.dialog).maybePop(result);
  }

  /// Presents a target as a dialog or page. Used for both view and
  /// create/edit flows — no more duplicated push/showDialog logic.
  void _presentOverlay(_ActiveDetailTarget<K> target) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_sameDetailTarget(_currentTarget, target)) return;

      final config = getEffectiveConfig();
      if (config == null) return;

      final details = widget.details;
      final navigator = Navigator.of(context);

      final Object? result;
      if (target.mode == TTableExpansionMode.page) {
        final route = MaterialPageRoute<Object?>(
          builder: (_) => _buildScopedContent(config.$1, config.$2),
        );
        result = await navigator.push<Object?>(route);
      } else {
        // dialog mode — adaptive: TModal on desktop, page-push on mobile.
        final modalWidth = (target.kind == _DetailKind.create || target.kind == _DetailKind.edit)
            ? (details?.createDialogWidth ?? details?.dialogWidth ?? 800.0)
            : (details?.dialogWidth ?? 800.0);

        result = await TModalService.showAdaptive<Object?>(
          context,
          (_) => _buildScopedContent(config.$1, config.$2),
          layoutBuilder: (ctx, child) => child,
          width: modalWidth,
        );
      }

      if (!mounted || result == _kTransitionResult) return;
      // If another transition already superseded this target, don't
      // stomp on newer state.
      if (!_sameDetailTarget(_currentTarget, target)) return;

      // User dismissed manually (back button / barrier tap) — sync
      // controller state back to collapsed.
      _currentTarget = null;
      switch (target.kind) {
        case _DetailKind.create:
          listController.cancelCreateItem();
          break;
        case _DetailKind.edit:
          listController.cancelEditItem();
          break;
        case _DetailKind.view:
          listController.collapseAll();
          break;
      }
    });
  }

  TTableExpansionMode get effectiveExpansionMode => _computeDesiredTarget()?.mode ?? widget.details?.mode ?? TTableExpansionMode.bottom;

  bool get useExpansionFocus => (widget.details?.focus ?? false) && effectiveExpansionMode == TTableExpansionMode.bottom;

  void _validateExpansionMode() {
    assert(
      widget.details == null || widget.details!.mode != TTableExpansionMode.side || widget.details!.itemTitle != null,
      'itemTitle is required for TTableExpansionMode.side',
    );
    assert(
      effectiveExpansionMode == TTableExpansionMode.bottom || listController.expansionMode != TExpansionMode.multiple,
      'Only TTableExpansionMode.bottom supports multiple expansion. Other modes require TExpansionMode.single',
    );
  }

  void _handleDidUpdateWidget(TTable<T, K> oldWidget) {
    final oldMode = oldWidget.details?.mode ?? TTableExpansionMode.bottom;
    final newMode = widget.details?.mode ?? TTableExpansionMode.bottom;
    if (oldMode == newMode && oldWidget.controller == widget.controller) return;

    _validateExpansionMode();

    final current = _currentTarget;
    if (current != null && _isOverlayMode(current.mode) && !_isOverlayMode(newMode)) {
      final closingMode = current.mode;
      _currentTarget = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dismissOverlay(closingMode, result: _kTransitionResult);
      });
    }
  }

  Widget _buildSideLayout(ColorScheme colors, BoxConstraints constraints) {
    final config = getEffectiveConfig();
    if (config == null) return const SizedBox.shrink();

    return Row(
      key: const ValueKey('table_side_expand_layout'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: wTheme.expandSideListWidth ?? 275.0, child: _buildSideList(colors)),
        Expanded(child: _buildScopedContent(config.$1, config.$2)),
      ],
    );
  }

  Widget _buildSideList(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.search != null || widget.beforeItemsBuilder != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 14),
            child: widget.beforeItemsBuilder?.call(context) ?? const SizedBox.shrink(),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 14),
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
                  placeholder: 'Search...',
                  onValueChanged: (String? input) {
                    listController.handleSearchChange(input ?? '');
                  },
                ),
              ),
              if (widget.details?.createBuilder != null) ...[
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
        Expanded(
          child: TList<T, K>(
            controller: listController,
            itemBuilder: (ctx, item, index) => _buildSideListItem(ctx, item, index),
          ),
        ),
      ],
    );
  }

  Widget _buildSideListItem(BuildContext ctx, TListItem<T, K> item, int index) {
    final title = widget.details?.itemTitle?.call(item.data);
    final subTitle = widget.details?.itemSubTitle?.call(item.data);
    final imageUrl = widget.details?.itemImageUrl?.call(item.data);
    final isSelected = listController.isItemKeyExpanded(item.key);

    return TTableRowCard<T, K>(
      index: index,
      item: item,
      onTap: () => _handleExpansionTap(item.key, !isSelected),
      theme: wTheme.rowCardTheme.copyWith(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      isSelected: isSelected,
      headers: [
        TTableHeader<T, K>(
          '',
          builder: (context, item, index) => IgnorePointer(
            child: TImage(
              url: imageUrl,
              size: 45,
              color: context.colors.surfaceContainerLow,
              disabled: true,
              border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              title: title,
              subTitle: subTitle,
            ),
          ),
        ),
      ],
    );
  }
}
