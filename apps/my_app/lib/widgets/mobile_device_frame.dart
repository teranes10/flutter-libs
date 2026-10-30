import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TMobileDeviceFrame extends StatelessWidget {
  /// Header title. When null the header is omitted (e.g. the child supplies its own).
  final String? title;
  final Widget child;
  final List<TBottomBarItem> bottomBarItems;
  final int currentBottomIndex;
  final ValueChanged<int>? onBottomBarTap;
  final VoidCallback? onBackPressed;

  final double? width;
  final double? height;

  const TMobileDeviceFrame({
    super.key,
    this.title,
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
        _buildMockStatusBar(context),
        // Custom Header
        if (title != null) _buildCustomHeader(context),
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
        // Fake a phone-sized viewport so descendants' context.isMobile is true.
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width ?? 375, height ?? MediaQuery.sizeOf(context).height)),
          child: Theme(
            data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
            child: Material(color: colors.surface, child: bodyContent),
          ),
        ),
      ),
    );
  }

  Widget _buildMockStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: context.colors.onSurface),
          ),
          Row(
            children: [
              TIcon.raw(HugeIcons.strokeRoundedSignalHigh, size: 14),
              SizedBox(width: 5),
              TIcon.raw(HugeIcons.strokeRoundedWifi01, size: 14),
              SizedBox(width: 5),
              TIcon.raw(HugeIcons.strokeRoundedBatteryMedium02, size: 14),
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
          IconButton(
            icon: TIcon.raw(HugeIcons.strokeRoundedArrowLeft01, size: 16),
            onPressed: onBackPressed,
          ),
          Expanded(
            child: Center(
              child: Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 32), // spacer to match back button
        ],
      ),
    );
  }
}
