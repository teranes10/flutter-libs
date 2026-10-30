import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum _Scope { all, shop, own, none }

class _Role {
  final String name;
  final Color color;

  /// Scope per permission; missing permissions resolve to [_Scope.none]. Ignored when [all] is set.
  final Map<String, _Scope> scopes;

  /// Grants every permission with [_Scope.all].
  final bool all;

  const _Role(this.name, this.color, this.scopes, {this.all = false});
}

class _Module {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> permissions;

  const _Module(this.id, this.name, this.icon, this.color, this.permissions);
}

const _modules = [
  _Module('sales', 'Sales', Icons.shopping_cart_outlined, Colors.blue, ['View Orders', 'Create Orders', 'Cancel Orders']),
  _Module('products', 'Products', Icons.inventory_2_outlined, Colors.orange, ['View Products', 'Create Products', 'Update Products']),
  _Module('customers', 'Customers', Icons.groups_outlined, Colors.green, ['View Customers', 'Create Customers']),
  _Module('reports', 'Reports', Icons.bar_chart_rounded, Colors.purple, ['View Reports', 'Export Reports']),
  _Module('settings', 'Settings', Icons.settings_outlined, Colors.blueGrey, ['Manage Users', 'Manage Settings']),
];

const _roles = [
  _Role('Customer', Colors.pink, {'View Products': _Scope.all}),
  _Role('Picker', Colors.amber, {'View Orders': _Scope.shop, 'View Products': _Scope.shop}),
  _Role('Salesperson', Colors.purple, {
    'View Orders': _Scope.own,
    'Create Orders': _Scope.own,
    'View Products': _Scope.own,
    'View Customers': _Scope.own,
    'View Reports': _Scope.own,
  }),
  _Role('Counter', Colors.teal, {
    'View Orders': _Scope.shop,
    'Create Orders': _Scope.shop,
    'View Products': _Scope.shop,
    'View Customers': _Scope.shop,
    'Create Customers': _Scope.shop,
  }),
  _Role('Packer', Colors.brown, {'View Orders': _Scope.shop, 'View Products': _Scope.shop}),
  _Role('Cashier', Colors.green, {
    'View Orders': _Scope.shop,
    'Create Orders': _Scope.shop,
    'Cancel Orders': _Scope.shop,
    'View Products': _Scope.shop,
    'Update Products': _Scope.shop,
    'View Customers': _Scope.shop,
    'Create Customers': _Scope.shop,
    'View Reports': _Scope.shop,
  }),
  _Role('Receiver', Colors.orange, {'View Products': _Scope.shop, 'Create Products': _Scope.shop, 'Update Products': _Scope.shop}),
  _Role('Admin', Colors.indigo, {}, all: true),
  _Role('Driver', Colors.cyan, {'View Orders': _Scope.own}),
  _Role('Staff', Colors.grey, {'View Orders': _Scope.shop, 'View Products': _Scope.shop, 'View Customers': _Scope.shop}),
  _Role('Manager', Colors.blue, {
    'View Orders': _Scope.all,
    'Create Orders': _Scope.all,
    'Cancel Orders': _Scope.all,
    'View Products': _Scope.all,
    'Create Products': _Scope.all,
    'Update Products': _Scope.all,
    'View Customers': _Scope.all,
    'Create Customers': _Scope.all,
    'View Reports': _Scope.all,
    'Export Reports': _Scope.all,
    'Manage Users': _Scope.shop,
  }),
  _Role('Pharmacist', Colors.lightGreen, {
    'View Orders': _Scope.shop,
    'Create Orders': _Scope.shop,
    'View Products': _Scope.shop,
    'Update Products': _Scope.shop,
    'View Customers': _Scope.shop,
  }),
  _Role('SuperAdmin', Colors.red, {}, all: true),
  _Role('QA Officer', Colors.deepPurple, {
    'View Orders': _Scope.all,
    'View Products': _Scope.all,
    'View Customers': _Scope.all,
    'View Reports': _Scope.all,
    'Export Reports': _Scope.all,
  }),
];

/// Resolves a role's scope for a permission.
_Scope _scopeOf(_Role role, String permission) => role.all ? _Scope.all : role.scopes[permission] ?? _Scope.none;

/// Sample: a grouped permission matrix built with [TTableHeader.stacked].
///
/// Each table row is one module (a single card); its permissions are stacked
/// as fixed-height sub-rows, so no colspan/rowspan is needed.
///
/// With many roles the layout adapts:
/// - wide: a role multi-select picks which role columns are shown;
/// - compact: card view with either a role picker ("what can this role do?")
///   or a grouped-by-scope list ("who can do this?").
class TablesPermissionMatrixPage extends StatefulWidget {
  const TablesPermissionMatrixPage({super.key});

  @override
  State<TablesPermissionMatrixPage> createState() => _TablesPermissionMatrixPageState();
}

class _TablesPermissionMatrixPageState extends State<TablesPermissionMatrixPage> {
  static const _rowHeight = 36.0;
  static const _compactWidth = 720.0;

  List<String> _visible = [for (final r in _roles.skip(5).take(5)) r.name];
  String _activeRole = _roles.first.name;
  bool _byScope = false;

  List<_Role> get _visibleRoles {
    final roles = _roles.where((r) => _visible.contains(r.name)).toList();
    return roles.isEmpty ? _roles : roles;
  }

  List<TTableHeader<_Module, String>> _headers() => [
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
    for (final role in _visibleRoles)
      TTableHeader<_Module, String>.stacked(
        role.name,
        (m) => [for (final p in m.permissions) _ScopeChip(_scopeOf(role, p))],
        flex: 2,
        rowHeight: _rowHeight,
        alignment: Alignment.center,
        widthEstimator: (_) => math.max(80, TTableTheme.measureTextWidth(role.name) + 24),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).width < _compactWidth;
    final activeRole = _roles.firstWhere((r) => r.name == _activeRole);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grouped Rows: Permission Matrix',
              style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'One card per module, with permissions stacked as sub-rows via TTableHeader.stacked. '
              'Pick which roles to compare on wide screens, or browse by role / by scope on compact ones.',
              style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (compact) ..._compactControls(activeRole) else _wideControls(),
            const SizedBox(height: 16),
            TTable<_Module, String>(
              key: ValueKey('$compact|${_visible.join(',')}|$_byScope|$_activeRole'),
              theme: context.theme.tableTheme.copyWith(shrinkWrap: true, forceCardStyle: compact),
              headers: _headers(),
              items: _modules,
              itemKey: (m) => m.id,
              mobileCardBuilder: (ctx, item, index, onTap) => _byScope ? _ScopeCard(item.data) : _RoleCard(item.data, activeRole),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideControls() => TMultiSelect<String, String, String>(
    label: 'Roles shown',
    placeholder: 'Select roles',
    items: [for (final r in _roles) r.name],
    value: _visible,
    onValueChanged: (v) => setState(() => _visible = v ?? const []),
  );

  List<Widget> _compactControls(_Role activeRole) => [
    TButtonGroup(
      items: [
        TButtonGroupItem(text: 'By role', active: !_byScope, onTap: () => setState(() => _byScope = false)),
        TButtonGroupItem(text: 'By scope', active: _byScope, onTap: () => setState(() => _byScope = true)),
      ],
    ),
    if (!_byScope) ...[
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final r in _roles)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TChip(
                  text: r.name,
                  color: r.color,
                  type: r.name == _activeRole ? TVariant.solid : TVariant.outline,
                  onTap: () => setState(() => _activeRole = r.name),
                ),
              ),
          ],
        ),
      ),
    ],
  ];
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
          child: Icon(module.icon, size: 18, color: module.color),
        ),
        const SizedBox(width: 10),
        Text(module.name),
      ],
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final _Scope scope;

  const _ScopeChip(this.scope);

  @override
  Widget build(BuildContext context) {
    final (label, color) = _scopeStyle(scope, context);
    return TChip.tonal(text: label, color: color, size: TChipSize.sm);
  }
}

(String, Color) _scopeStyle(_Scope scope, BuildContext context) => switch (scope) {
  _Scope.all => ('All', context.theme.success),
  _Scope.shop => ('Shop', context.theme.info),
  _Scope.own => ('Own', Colors.purple),
  _Scope.none => ('None', context.colors.onSurfaceVariant),
};

/// Shared card shell: module title, then one block per permission.
class _CardShell extends StatelessWidget {
  final _Module module;
  final Widget Function(String permission) permissionBuilder;

  const _CardShell({required this.module, required this.permissionBuilder});

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
          for (final p in module.permissions)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(border: Border(top: divider)),
              child: permissionBuilder(p),
            ),
        ],
      ),
    );
  }
}

/// Compact "by role" card: one line per permission with the selected role's scope.
class _RoleCard extends StatelessWidget {
  final _Module module;
  final _Role role;

  const _RoleCard(this.module, this.role);

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      module: module,
      permissionBuilder: (p) => Row(
        children: [
          Expanded(child: Text(p)),
          _ScopeChip(_scopeOf(role, p)),
        ],
      ),
    );
  }
}

/// Compact "by scope" card: each permission lists its roles grouped under All / Shop / Own.
class _ScopeCard extends StatelessWidget {
  final _Module module;

  const _ScopeCard(this.module);

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant);

    return _CardShell(
      module: module,
      permissionBuilder: (p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p),
          for (final scope in const [_Scope.all, _Scope.shop, _Scope.own])
            if (_roles.any((r) => _scopeOf(r, p) == scope))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Align(alignment: Alignment.centerLeft, child: _ScopeChip(scope)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          for (final r in _roles)
                            if (_scopeOf(r, p) == scope)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(r.name, style: muted),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
