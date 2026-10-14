import 'package:flutter/material.dart';

/// Pins [child] to the top of a [CustomScrollView] once scrolling reaches
/// it, for sticky toolbars/summary bars inside a scrollable page
/// (Ant Design's `Affix` equivalent). [height] must match the child's
/// rendered height, since sliver headers require a fixed extent upfront.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     TAffix(height: 56, child: TAlignedRow(children: [...])),
///     SliverList(...),
///   ],
/// )
/// ```
class TAffix extends StatelessWidget {
  /// The content to pin once it reaches the top of the viewport.
  final Widget child;

  /// Fixed height reserved for [child] in the sliver layout.
  final double height;

  const TAffix({super.key, required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AffixDelegate(child: child, extent: height),
    );
  }
}

class _AffixDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  _AffixDelegate({required this.child, required this.extent});

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _AffixDelegate oldDelegate) => oldDelegate.child != child || oldDelegate.extent != extent;
}
