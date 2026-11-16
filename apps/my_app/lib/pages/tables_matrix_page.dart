import 'package:flutter/material.dart';
import 'package:my_app/models/permission_scope.dart';
import 'package:te_widgets/te_widgets.dart';

class _Role {
  final String name;
  final String shortName;
  final Color color;

  /// Scope per permission; missing permissions resolve to [PermissionScope.none]. Ignored when [all] is set.
  final Map<String, PermissionScope> scopes;
  final bool all;

  const _Role(this.name, this.shortName, this.color, this.scopes, {this.all = false});

  PermissionScope scopeOf(String permission) => all ? PermissionScope.all : scopes[permission] ?? PermissionScope.none;
}

class _Module {
  final String id;
  final String name;
  final dynamic icon;
  final Color color;
  final List<String> permissions;

  const _Module(this.id, this.name, this.icon, this.color, this.permissions);
}

const _modules = [
  _Module('sales', 'Sales', HugeIcons.strokeRoundedShoppingCart01, Colors.blue, ['View Orders', 'Create Orders', 'Cancel Orders']),
  _Module('products', 'Products', HugeIcons.strokeRoundedPackage, Colors.orange, ['View Products', 'Create Products', 'Update Products']),
  _Module('customers', 'Customers', HugeIcons.strokeRoundedGroup, Colors.green, ['View Customers', 'Create Customers']),
  _Module('reports', 'Reports', HugeIcons.strokeRoundedChartBarLine, Colors.purple, ['View Reports', 'Export Reports']),
  _Module('settings', 'Settings', HugeIcons.strokeRoundedSettings01, Colors.blueGrey, ['Manage Users', 'Manage Settings']),
];

const _roles = [
  _Role('Shop Manager', 'Manager', Colors.blue, {}, all: true),
  _Role('Cashier', 'Cashier', Colors.green, {
    'View Orders': PermissionScope.shop,
    'Create Orders': PermissionScope.shop,
    'Cancel Orders': PermissionScope.shop,
    'View Products': PermissionScope.shop,
    'Update Products': PermissionScope.shop,
    'View Customers': PermissionScope.shop,
    'Create Customers': PermissionScope.shop,
    'View Reports': PermissionScope.shop,
  }),
  _Role('Salesperson', 'Sales', Colors.purple, {
    'View Orders': PermissionScope.own,
    'Create Orders': PermissionScope.own,
    'View Products': PermissionScope.own,
    'View Customers': PermissionScope.own,
    'View Reports': PermissionScope.own,
  }),
  _Role('Warehouse Operator', 'Warehouse', Colors.orange, {
    'View Products': PermissionScope.shop,
    'Create Products': PermissionScope.shop,
    'Update Products': PermissionScope.shop,
    'View Customers': PermissionScope.shop,
    'Create Customers': PermissionScope.shop,
  }),
];

/// Sample: a grouped permission matrix with a few roles, built with [TTableHeader.stacked].
///
/// Each table row is one module (a single card); its permissions are stacked
/// as fixed-height sub-rows, so no colspan/rowspan is needed. On small screens
/// the table switches to [TTable.mobileCardBuilder] cards.
///
/// For many roles see the "Permission Matrix" sample.
class TablesMatrixPage extends StatelessWidget {
  const TablesMatrixPage({super.key});

  static const _rowHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headers = [
      TTableHeader<_Module, String>(
        'Module',
        flex: 2,
        alignment: Alignment.centerLeft,
        builder: (ctx, item, _) => _ModuleTitle(item.data),
        widthEstimator: (m) => 60.0 + TTableTheme.measureTextWidth(m.name),
      ),
      TTableHeader<_Module, String>.stacked(
        'Permission',
        (m) => [for (final p in m.permissions) Text(p)],
        flex: 3,
        rowHeight: _rowHeight,
        widthEstimator: (m) => m.permissions.map(TTableTheme.measureTextWidth).reduce((a, b) => a > b ? a : b),
      ),
      for (final role in _roles)
        TTableHeader<_Module, String>.stacked(
          role.name,
          (m) => [for (final p in m.permissions) role.scopeOf(p).toChip(context)],
          flex: 2,
          rowHeight: _rowHeight,
          alignment: Alignment.center,
          widthEstimator: (_) => 80,
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grouped Rows: Matrix',
            style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'One card per module, with permissions stacked as sub-rows via TTableHeader.stacked. '
            'Role columns are generated from data.',
            style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TTable<_Module, String>(
            shrinkWrap: true,
            headers: headers,
            items: _modules,
            itemKey: (m) => m.id,
            mobileCardBuilder: (ctx, item, index, onTap) => _MatrixCard(item.data),
          ),
        ],
      ),
    );
  }
}

class _ModuleTitle extends StatelessWidget {
  final _Module module;

  const _ModuleTitle(this.module);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: module.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: TIcon.raw(module.icon, size: 18, color: module.color),
        ),
        const SizedBox(width: 10),
        Text(module.name),
      ],
    );
  }
}

/// Mobile card: a role legend once per card, then one line per permission with
/// its scope chips in equal-width columns under the legend.
class _MatrixCard extends StatelessWidget {
  final _Module module;

  const _MatrixCard(this.module);

  @override
  Widget build(BuildContext context) {
    final divider = BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.25), width: 0.5);

    return TCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModuleTitle(module),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final role in _roles)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: role.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          role.shortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          for (final p in module.permissions)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(border: Border(top: divider)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p),
                  const SizedBox(height: 6),
                  Row(
                    children: [for (final role in _roles) Expanded(child: Center(child: role.scopeOf(p).toChip(context)))],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
