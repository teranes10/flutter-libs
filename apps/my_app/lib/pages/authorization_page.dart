import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Showcase for the permission engine: toggle permissions and watch widgets
/// hide or disable. In a real app, put one [TAuthScope] above `MaterialApp`.
class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({super.key});

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  static const _all = ['orders.view', 'orders.edit', 'orders.delete', 'reports.view'];

  final _controller = TAuthController(permissions: const ['orders.view']);
  final _granted = <String>{'orders.view'};
  int _tab = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String p, bool on) {
    setState(() => on ? _granted.add(p) : _granted.remove(p));
    _controller.update(_granted);
  }

  @override
  Widget build(BuildContext context) {
    return TAuthScope(
      controller: _controller,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Granted permissions', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _all) FilterChip(label: Text(p), selected: _granted.contains(p), onSelected: (v) => _toggle(p, v)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Buttons (denied: disabled by default, hide on request)', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            TButton(text: 'Edit', permission: 'orders.edit', onTap: () {}),
            TButton(text: 'Delete (hide)', permission: 'orders.delete', onDenied: TAuthMode.hide, onTap: () {}),
            TButton(text: 'Any of', permission: const TPermission.any(['orders.edit', 'reports.view']), onTap: () {}),
          ]),
          const SizedBox(height: 24),
          Text('Button group', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          TButtonGroup(items: [
            TButtonGroupItem(text: 'View', permission: 'orders.view', onTap: () {}),
            TButtonGroupItem(text: 'Edit', permission: 'orders.edit', onTap: () {}),
            TButtonGroupItem(text: 'Delete', permission: 'orders.delete', onDenied: TAuthMode.hide, onTap: () {}),
          ]),
          const SizedBox(height: 24),
          Text('Tabs (denied: hidden)', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          TTabs<int>(
            selectedValue: _tab,
            onTabChanged: (v) => setState(() => _tab = v),
            tabs: const [
              TTab(value: 1, text: 'Orders', permission: 'orders.view'),
              TTab(value: 2, text: 'Reports', permission: 'reports.view'),
              TTab(value: 3, text: 'Billing (disabled)', permission: 'orders.delete', onDenied: TAuthMode.disable),
            ],
          ),
          const SizedBox(height: 24),
          Text('Tile & generic gate', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          TTile(title: 'Open order (tile: disabled)', permission: 'orders.edit', onTap: () {}),
          const SizedBox(height: 8),
          const TAuthGate(permission: 'reports.view', onDenied: TAuthMode.hide, child: Text('Visible only with reports.view')),
        ],
      ),
    );
  }
}
