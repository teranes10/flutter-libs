import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class DropdownSamplePage extends StatelessWidget {
  const DropdownSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown Sample')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simple Dropdown:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TDropdown(
              items: [
                TDropdownItem(text: 'Edit', icon: Icons.edit, onTap: () => debugPrint('Edit tapped')),
                TDropdownItem(text: 'Delete', icon: Icons.delete, onTap: () => debugPrint('Delete tapped')),
              ],
              child: TButton(text: 'Actions'),
            ),
            const SizedBox(height: 40),
            const Text('Multi-Level Dropdown:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TDropdown(
              items: [
                TDropdownItem(text: 'Account', icon: Icons.person),
                TDropdownItem(
                  text: 'Appearance',
                  icon: Icons.palette,
                  children: [
                    TDropdownItem(text: 'Light Mode', onTap: () => debugPrint('Light')),
                    TDropdownItem(text: 'Dark Mode', onTap: () => debugPrint('Dark')),
                  ],
                ),
              ],
              child: TButton(text: 'Settings Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
