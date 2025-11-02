import 'package:flutter/material.dart';

mixin TScrollMixin {
  ScrollController? get scrollController;
  VoidCallback? get onScrollEnd;
  double get scrollEndThreshold;
  ValueNotifier<double>? get scrollPositionNotifier;
  ValueChanged<double>? get onScrollPositionChanged;
}

mixin TScrollStateMixin<W extends StatefulWidget> on State<W> {
  TScrollMixin get _widget {
    assert(widget is TScrollMixin, 'Widget must mix in TScrollMixin');
    return widget as TScrollMixin;
  }

  late ScrollController _scrollController;
  bool _isScrollEndTriggered = false;

  ScrollController get scrollController => _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = _widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _widget.scrollPositionNotifier?.addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _widget.scrollPositionNotifier?.removeListener(_updateScrollPosition);

    if (_widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isScrollEndTriggered = false;

    final oldMixin = oldWidget as TScrollMixin;

    if (oldMixin.scrollController != _widget.scrollController) {
      (oldMixin.scrollController ?? _scrollController).removeListener(_onScroll);

      if (oldMixin.scrollController == null && _widget.scrollController != null) {
        _scrollController.dispose();
      }

      _scrollController = _widget.scrollController ?? ScrollController();
      _scrollController.addListener(_onScroll);
    }

    if (oldMixin.scrollPositionNotifier != _widget.scrollPositionNotifier) {
      oldMixin.scrollPositionNotifier?.removeListener(_updateScrollPosition);
      _widget.scrollPositionNotifier?.addListener(_updateScrollPosition);
    }
  }

  void _updateScrollPosition() {
    final notifier = _widget.scrollPositionNotifier;
    if (_scrollController.hasClients && notifier != null) {
      final targetPosition = notifier.value;
      if ((_scrollController.offset - targetPosition).abs() > 1.0) {
        _scrollController.jumpTo(targetPosition);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final currentPosition = _scrollController.position.pixels;

    _widget.onScrollPositionChanged?.call(currentPosition);
    _widget.scrollPositionNotifier?.value = currentPosition;

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final distanceFromBottom = maxScrollExtent - currentPosition;

    if (distanceFromBottom <= _widget.scrollEndThreshold && !_isScrollEndTriggered) {
      _isScrollEndTriggered = true;
      _widget.onScrollEnd?.call();
      onScrollEnd();
    }

    if (distanceFromBottom > _widget.scrollEndThreshold * 1.5) {
      _isScrollEndTriggered = false;
    }
  }

  void onScrollEnd() {}
}
