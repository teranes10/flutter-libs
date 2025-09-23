import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/scroll_mixin.dart';

class TList<T> extends StatefulWidget with TScrollMixin {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool showAnimation;
  final Duration animationDuration;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Curve animationCurve;
  final double staggerDelay;
  final double maxStaggerTime;

  @override
  final ScrollController? controller;
  @override
  final VoidCallback? onScrollEnd;
  @override
  final double scrollEndThreshold;

  const TList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.animationCurve = Curves.easeOutCubic,
    this.staggerDelay = 0.05,
    this.maxStaggerTime = 0.3,
    this.controller,
    this.onScrollEnd,
    this.scrollEndThreshold = 0.0,
  });

  @override
  State<TList<T>> createState() => _TListState<T>();
}

class _TListState<T> extends State<TList<T>> with SingleTickerProviderStateMixin, TScrollStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.isEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? (widget.shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics()),
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final child = widget.itemBuilder(context, item, index);

        return _buildAnimatedItem(
          index: index,
          child: child,
        );
      },
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    if (!widget.showAnimation) {
      return child;
    }

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        (widget.staggerDelay * index).clamp(0.0, widget.maxStaggerTime),
        (widget.maxStaggerTime + (widget.staggerDelay * index)).clamp(widget.maxStaggerTime, 1.0),
        curve: widget.animationCurve,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * 50, 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    );
  }
}
