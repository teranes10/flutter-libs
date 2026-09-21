import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TMobileDeviceFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final List<TBottomBarItem> bottomBarItems;
  final int currentBottomIndex;
  final ValueChanged<int>? onBottomBarTap;
  final VoidCallback? onBackPressed;

  final double? width;
  final double? height;

  const TMobileDeviceFrame({
    super.key,
    required this.title,
    required this.child,
    this.bottomBarItems = const [],
    this.currentBottomIndex = 0,
    this.onBottomBarTap,
    this.onBackPressed,
    this.width = 375,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Bar Mock
        _buildMockStatusBar(),
        // Custom Header
        _buildCustomHeader(context),
        // Content
        if (height != null) Expanded(child: child) else child,
        // TBottomBar navigation
        if (bottomBarItems.isNotEmpty)
          TBottomBar(
            currentIndex: currentBottomIndex,
            onTap: onBottomBarTap,
            items: bottomBarItems,
            variant: TVariant.text,
            textPosition: TBottomBarTextPosition.bottomAlways,
          ),
      ],
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: colors.surfaceContainer, width: 8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(color: colors.surface, child: bodyContent),
      ),
    );
  }

  Widget _buildMockStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: Colors.transparent,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 14),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 14),
              SizedBox(width: 4),
              Icon(Icons.battery_5_bar, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: onBackPressed),
          Expanded(
            child: Center(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 32), // spacer to match back button
        ],
      ),
    );
  }
}
