import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Demonstrates `group: true` — shadcn-style text-label groups inline in a
/// menu — mixed with regular items that open a nested popup.
class MenuGroupsPage extends StatelessWidget {
  const MenuGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Dropdown: groups + popup submenu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('"Account" and "Workspace" are groups (inline). "Appearance" has no group flag, so it opens a popup.'),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TDropdown(
            triggerMode: TDropdownTriggerMode.tap,
            items: [
              TDropdownItem(
                text: 'Account',
                group: true,
                children: [
                  TDropdownItem(text: 'Profile', icon: HugeIcons.strokeRoundedUser, onTap: () => debugPrint('Profile')),
                  TDropdownItem(text: 'Billing', icon: HugeIcons.strokeRoundedCreditCard, onTap: () => debugPrint('Billing')),
                ],
              ),
              TDropdownItem(
                text: 'Workspace',
                group: true,
                showDivider: true,
                children: [
                  TDropdownItem(text: 'Team', icon: HugeIcons.strokeRoundedUserGroup, onTap: () => debugPrint('Team')),
                  TDropdownItem(
                    text: 'Appearance',
                    icon: HugeIcons.strokeRoundedPaintBoard,
                    children: [
                      TDropdownItem(text: 'Light', onTap: () => debugPrint('Light')),
                      TDropdownItem(text: 'Dark', onTap: () => debugPrint('Dark')),
                    ],
                  ),
                ],
              ),
            ],
            child: TButton(text: 'Open menu'),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Sidebar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('The "Menus" heading in the sidebar is a group item; minimize the sidebar to see it become a divider.'),
      ],
    );
  }
}
