import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// How far a permission reaches. Shared by the permission-matrix demo pages; design tokens live here
/// (`.label`, `.color`, `.toChip()`), never in per-page switches.
enum PermissionScope { all, shop, own, none }

extension PermissionScopeX on PermissionScope {
  String get label => switch (this) {
    PermissionScope.all => 'All',
    PermissionScope.shop => 'Shop',
    PermissionScope.own => 'Own',
    PermissionScope.none => 'None',
  };

  Color color(BuildContext context) => switch (this) {
    PermissionScope.all => context.theme.success,
    PermissionScope.shop => context.theme.info,
    PermissionScope.own => context.theme.secondary,
    PermissionScope.none => context.colors.onSurfaceVariant,
  };

  TChip toChip(BuildContext context) => TChip.tonal(text: label, color: color(context), size: TChipSize.sm);
}
