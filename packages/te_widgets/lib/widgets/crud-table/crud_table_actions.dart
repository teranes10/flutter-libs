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
      _listController.addItem(newItem);
      if (mounted && ctx.mounted) {
        scope.close(ctx);
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
        scope.close(ctx);
      }
      form.reset();
      form.dispose();
      return true;
    }
    return false;
  }

  void handleView(T item, TListController<T, K> controller) {
    if (controller.expandable) controller.expandDetail(controller.itemKey(item));
    if (widget.onView == null) return;
    _performAction(() async {
      await widget.onView!(item);
    });
  }

  void handleArchive(T item) {
    TAlertService.confirmArchive(context, () async {
      await _performAction(() async {
        final success = await widget.onArchive!(item);
        if (success == true) {
          _listController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
    });
  }

  void handleRestore(T item) {
    TAlertService.confirmRestore(context, () async {
      await _performAction(() async {
        final success = await widget.onRestore!(item);
        if (success == true) {
          _archiveListController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
    });
  }

  void handleDelete(T item) {
    TAlertService.confirmDelete(context, () async {
      await _performAction(() async {
        final success = await widget.onDelete!(item);
        if (success == true) {
          _archiveListController.removeItem(item);
          _permissionCache.remove(item);
        }
      });
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
