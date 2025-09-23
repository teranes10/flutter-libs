import 'package:flutter/material.dart';

mixin TScrollMixin {
  ScrollController? get controller;
  VoidCallback? get onScrollEnd;
  double get scrollEndThreshold;
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

    _scrollController = _widget.controller ?? ScrollController();
    if (_widget.onScrollEnd != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (_widget.onScrollEnd != null) {
      _scrollController.removeListener(_onScroll);
    }
    if (_widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isScrollEndTriggered = false;

    final oldMixin = oldWidget as TScrollMixin;
    if (oldMixin.controller != _widget.controller) {
      if (oldMixin.onScrollEnd != null) {
        (oldMixin.controller ?? _scrollController).removeListener(_onScroll);
      }

      if (oldMixin.controller == null && _widget.controller != null) {
        _scrollController.dispose();
      }

      _scrollController = _widget.controller ?? ScrollController();
      if (_widget.onScrollEnd != null) {
        _scrollController.addListener(_onScroll);
      }
    }

    if (oldMixin.onScrollEnd != _widget.onScrollEnd) {
      if (oldMixin.onScrollEnd != null) {
        _scrollController.removeListener(_onScroll);
      }
      if (_widget.onScrollEnd != null) {
        _scrollController.addListener(_onScroll);
      }
    }
  }

  void _onScroll() {
    if (_widget.onScrollEnd == null) return;

    final scrollController = _scrollController;
    if (!scrollController.hasClients) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentScrollPosition = scrollController.position.pixels;
    final distanceFromBottom = maxScrollExtent - currentScrollPosition;

    if (distanceFromBottom <= _widget.scrollEndThreshold && !_isScrollEndTriggered) {
      _isScrollEndTriggered = true;
      _widget.onScrollEnd!();
    }

    if (distanceFromBottom > _widget.scrollEndThreshold * 1.5) {
      _isScrollEndTriggered = false;
    }
  }
}
