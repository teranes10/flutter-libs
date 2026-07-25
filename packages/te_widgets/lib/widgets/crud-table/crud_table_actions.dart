part of 'crud_table.dart';

extension _TCrudTableActionsExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  // Permission methods
  bool canPerformActionSync(T item, Future<bool> Function(T)? permission) {
    if (permission == null) return true;

    final cacheKey = permission.toString();
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
    _listController.beginCreateItem();
  }

  void handleEdit(T item) {
    _listController.beginEditItem(item);
  }

  void handleCreateInline(BuildContext ctx, F form) {
    final scope = TTableScope.of(ctx);
    _performAction(() async {
      final newItem = await widget.onCreate?.call(form);
      if (newItem != null) {
        _listController.addItem(newItem);
      }

      if (mounted && ctx.mounted) {
        scope.close(ctx);
      }

      form.reset();
      form.dispose();
    });
  }

  void handleEditInline(BuildContext ctx, T item, F form) {
    final scope = TTableScope.of(ctx);
    _performAction(() async {
      final updatedItem = await widget.onEdit?.call(item, form);
      if (updatedItem != null) {
        _listController.updateItem(item, updatedItem);
      }

      if (mounted && ctx.mounted) {
        scope.close(ctx);
      }

      form.reset();
      form.dispose();
    });
  }

  void handleArchive(T item) {
    TAlertService.confirmArchive(context, () async {
      await _performAction(() async {
        final success = await widget.onArchive!(item);
        if (success) {
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
        if (success) {
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
        if (success) {
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
    }
  }
}
