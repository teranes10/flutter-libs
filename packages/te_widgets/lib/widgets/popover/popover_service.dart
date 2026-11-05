import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Factory helpers for anchored (popover based) confirmations.
///
/// Small alternative to the modal confirmations in `TAlertService`: each method
/// returns a widget wrapping [child]; tapping it opens a [TPopConfirm].
class TPopoverService {
  /// Wraps [child] in a small anchored confirmation.
  static Widget confirm({
    required Widget child,
    required FutureOr<void> Function() onConfirm,
    required String confirmText,
    required dynamic icon,
    required Color color,
    String title = 'Are you sure?',
    String? description,
    VoidCallback? onCancel,
    TPopupAlignment alignment = TPopupAlignment.topCenter,
  }) {
    return TPopConfirm(
      title: title,
      description: description,
      icon: icon,
      iconColor: color,
      confirmColor: color,
      confirmText: confirmText,
      alignment: alignment,
      onConfirm: onConfirm,
      onCancel: onCancel,
      child: child,
    );
  }

  /// Anchored variant of `TAlertService.confirmArchive`.
  static Widget confirmArchive(BuildContext context,
      {required Widget child,
      required FutureOr<void> Function() onConfirm,
      String? name,
      TPopupAlignment alignment = TPopupAlignment.topCenter}) {
    return confirm(
      child: child,
      onConfirm: onConfirm,
      alignment: alignment,
      confirmText: 'Archive',
      icon: HugeIcons.strokeRoundedArchive,
      color: context.theme.danger,
      description: name != null ? 'Archive "$name"?' : 'Do you really want to archive this item?',
    );
  }

  /// Anchored variant of `TAlertService.confirmRestore`.
  static Widget confirmRestore(BuildContext context,
      {required Widget child,
      required FutureOr<void> Function() onConfirm,
      String? name,
      TPopupAlignment alignment = TPopupAlignment.topCenter}) {
    return confirm(
      child: child,
      onConfirm: onConfirm,
      alignment: alignment,
      confirmText: 'Restore',
      icon: HugeIcons.strokeRoundedUnarchive03,
      color: context.theme.info,
      description: name != null ? 'Restore "$name"?' : 'Do you really want to restore this item?',
    );
  }

  /// Anchored variant of `TAlertService.confirmDelete`.
  static Widget confirmDelete(BuildContext context,
      {required Widget child,
      required FutureOr<void> Function() onConfirm,
      String? name,
      TPopupAlignment alignment = TPopupAlignment.topCenter}) {
    return confirm(
      child: child,
      onConfirm: onConfirm,
      alignment: alignment,
      confirmText: 'Delete',
      icon: HugeIcons.strokeRoundedDelete02,
      color: context.theme.danger,
      description: name != null ? 'Delete "$name"?' : 'Do you really want to delete this item?',
    );
  }
}
