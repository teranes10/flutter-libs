import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPage();
}

class _BottomBarPage extends State<BottomBarPage> {
  int _currentIndex = 0;
  TBottomBarTextPosition _textPosition = TBottomBarTextPosition.bottomAlways;
  TVariant _variant = TVariant.tonal;

  final List<TBottomBarItem> _items = const [
    TBottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    TBottomBarItem(icon: Icons.search, label: 'Search'),
    TBottomBarItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notifications'),
    TBottomBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bottom Bar Variants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text('Text Position'),
            Wrap(
              spacing: 10,
              children: TBottomBarTextPosition.values.map((pos) {
                return ChoiceChip(
                  label: Text(pos.name),
                  selected: _textPosition == pos,
                  onSelected: (selected) {
                    if (selected) setState(() => _textPosition = pos);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('Variant (Highlight Style)'),
            Wrap(
              spacing: 10,
              children: TVariant.values.map((v) {
                return ChoiceChip(
                  label: Text(v.name),
                  selected: _variant == v,
                  onSelected: (selected) {
                    if (selected) setState(() => _variant = v);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _items,
              textPosition: _textPosition,
              variant: _variant,
            ),

            const SizedBox(height: 40),
            const Text('Example with Custom Color (Danger)'),
            const SizedBox(height: 10),
            TBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _items,
              textPosition: TBottomBarTextPosition.rightActive,
              variant: TVariant.softOutline,
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}
