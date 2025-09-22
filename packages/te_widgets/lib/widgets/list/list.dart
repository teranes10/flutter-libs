import 'package:flutter/material.dart';

class TList<T> extends StatefulWidget {
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
  final ScrollController? controller;
  final VoidCallback? onScrollEnd;
  final double scrollEndThreshold;

  const TList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.padding,
    this.animationCurve = Curves.easeOutCubic,
    this.staggerDelay = 0.05,
    this.maxStaggerTime = 0.3,
    this.controller,
    this.onScrollEnd,
    this.scrollEndThreshold = 0.0, // Pixels from bottom to trigger onScrollEnd
  });

  @override
  State<TList<T>> createState() => _TListState<T>();
}

class _TListState<T> extends State<TList<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _isScrollEndTriggered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    _animationController.forward();

    _scrollController = widget.controller ?? ScrollController();
    if (widget.onScrollEnd != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (widget.onScrollEnd != null) {
      _scrollController.removeListener(_onScroll);
    }
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(TList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isScrollEndTriggered = false;

    if (oldWidget.items.isEmpty) {
      _animationController.reset();
      _animationController.forward();
    }

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.onScrollEnd != null) {
        (oldWidget.controller ?? _scrollController).removeListener(_onScroll);
      }

      if (oldWidget.controller == null && widget.controller != null) {
        _scrollController.dispose();
      }

      _scrollController = widget.controller ?? ScrollController();
      if (widget.onScrollEnd != null) {
        _scrollController.addListener(_onScroll);
      }
    }

    if (oldWidget.onScrollEnd != widget.onScrollEnd) {
      if (oldWidget.onScrollEnd != null) {
        _scrollController.removeListener(_onScroll);
      }
      if (widget.onScrollEnd != null) {
        _scrollController.addListener(_onScroll);
      }
    }
  }

  void _onScroll() {
    if (widget.onScrollEnd == null) return;

    final scrollController = _scrollController;
    if (!scrollController.hasClients) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentScrollPosition = scrollController.position.pixels;
    final distanceFromBottom = maxScrollExtent - currentScrollPosition;

    if (distanceFromBottom <= widget.scrollEndThreshold && !_isScrollEndTriggered) {
      _isScrollEndTriggered = true;
      widget.onScrollEnd!();
    }

    if (distanceFromBottom > widget.scrollEndThreshold * 1.5) {
      _isScrollEndTriggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
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
