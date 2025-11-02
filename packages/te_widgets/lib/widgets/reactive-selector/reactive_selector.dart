import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TReactiveSelector<T, S> extends StatefulWidget {
  final ValueListenable<T> listenable;
  final S Function(T) selector;
  final Widget Function(BuildContext context, S value, S? oldValue) builder;

  const TReactiveSelector({
    required this.listenable,
    required this.selector,
    required this.builder,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TReactiveSelectorState<T, S>();
}

class _TReactiveSelectorState<T, S> extends State<TReactiveSelector<T, S>> {
  late S value;
  S? oldValue;

  @override
  void initState() {
    super.initState();
    value = widget.selector(widget.listenable.value);
    widget.listenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(TReactiveSelector<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      widget.listenable.addListener(_valueChanged);
    }

    final newValue = widget.selector(widget.listenable.value);
    oldValue = value;
    value = newValue;
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    final newValue = widget.selector(widget.listenable.value);
    if (value == newValue) return;

    setState(() {
      oldValue = value;
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, oldValue);
  }
}
