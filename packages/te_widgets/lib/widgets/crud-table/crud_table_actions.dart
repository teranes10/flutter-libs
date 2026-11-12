part of 'crud_table.dart';

extension _TCrudTableActionsExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  // Permission methods
  bool canPerformActionSync(T item, Future<bool> Function(T)? permission, {String? key}) {
    if (permission == null) return true;

    // Closure toString() is not unique per permission; callers pass a stable action key.
    final cacheKey = key ?? permission.toString();
    final itemCache = _permissionCache[item] ??= <String, bool>{};

    if (itemCache.containsKey(cacheKey)) {
      return itemCache[cacheKey]!;
    }

    itemCache[cacheKey] = true;
    _updatePermissionAsync(item, cacheKey, permission);

    return true;
  }

  void _updatePermissionAsync(T item, String cacheKey, Future<bool> Function(T) permission) {
    permission(item).then((result) {
      final itemCache = _permissionCache[item];
      if (itemCache != null && itemCache[cacheKey] != result) {
        itemCache[cacheKey] = result;
        // ignore: invalid_use_of_protected_member
        if (mounted) setState(() {});
      }
    }).catchError((e) {
      final itemCache = _permissionCache[item];
      if (itemCache != null) {
        itemCache[cacheKey] = false;
        // ignore: invalid_use_of_protected_member
        if (mounted) setState(() {});
      }
    });
  }

  // Action handlers
  void handleCreate() {
    if (!_crudAuth(_perms?.create).isAllowed) return;
    _listController.beginCreateItem();
  }

  void handleEdit(T item) {
    if (!_crudAuth(_perms?.edit).isAllowed) return;
    _listController.beginEditItem(item);
  }

  Future<bool> handleCreateInline(BuildContext ctx, F form) async {
    if (!_crudAuth(_perms?.create).isAllowed) return false;
    final scope = TTableScope.of(ctx);
    final newItem = await widget.onCreate?.call(form);
    if (newItem != null) {
      // A list bound to a data stream may already hold the new item by the time onCreate returns; update it instead of adding a duplicate
      final existing = _listController.getItem(_listController.itemKey(newItem));
      if (existing != null) {
        _listController.updateItem(existing.data, newItem);
      } else {
        _listController.addItem(newItem);
      }
      if (mounted && ctx.mounted) {
        unawaited(scope.close(ctx));
      }
      form.reset();
      form.dispose();
      return true;
    }
    return false;
  }

  Future<bool> handleEditInline(BuildContext ctx, T item, F form) async {
    final scope = TTableScope.of(ctx);
    final updatedItem = await widget.onEdit?.call(item, form);
    if (updatedItem != null) {
      _listController.updateItem(item, updatedItem);
      if (mounted && ctx.mounted) {
        unawaited(scope.close(ctx));
      }
      form.reset();
      form.dispose();
      return true;
    }
    return false;
  }

  void handleView(T item, TListController<T, K> controller) {
    if (controller.expandable) {
      final key = controller.itemKey(item);
      final v = controller.value;
      // Inline (bottom) expansion: pressing View again on an open row closes it.
      if (effectiveExpansionMode == TTableExpansionMode.bottom && v.expandedDetailKey == key && !v.isEditingItem) {
        controller.collapseDetail();
        return;
      }
      controller.expandDetail(key);
    }
    if (widget.onView == null) return;
    _performAction(() async {
      await widget.onView!(item);
    });
  }

  /// Runs the archive action; confirmation is shown by a popover around the row button.
  Future<void> handleArchive(T item) {
    return _performAction(() async {
      final success = await widget.onArchive!(item);
      if (success == true) {
        _listController.removeItem(item);
        _permissionCache.remove(item);
      }
    });
  }

  /// Runs the restore action; confirmation is shown by a popover around the row button.
  Future<void> handleRestore(T item) {
    return _performAction(() async {
      final success = await widget.onRestore!(item);
      if (success == true) {
        _archiveListController.removeItem(item);
        _permissionCache.remove(item);
      }
    });
  }

  /// Runs the delete action; confirmation is shown by a popover around the row button.
  Future<void> handleDelete(T item) {
    return _performAction(() async {
      final success = await widget.onDelete!(item);
      if (success == true) {
        _archiveListController.removeItem(item);
        _permissionCache.remove(item);
      }
    });
  }

  Future<void> performAction(Future<void> Function() action) => _performAction(action);

  Future<void> _performAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('__ TCrudTable action error: $e');
      if (mounted) {
        TToastService.error(context, null, null, TError.from(e));
      }
    }
  }
}
