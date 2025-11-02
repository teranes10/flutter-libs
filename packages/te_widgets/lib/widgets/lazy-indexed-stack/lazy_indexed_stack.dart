import 'package:flutter/material.dart';

class TLazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> children;

  const TLazyIndexedStack({required this.index, required this.children, super.key});

  @override
  State<TLazyIndexedStack> createState() => _TLazyIndexedStackState();
}

class _TLazyIndexedStackState extends State<TLazyIndexedStack> {
  late List<Widget?> _builtChildren;

  @override
  void initState() {
    super.initState();
    _builtChildren = List<Widget?>.filled(widget.children.length, null);
    _buildChild(widget.index);
  }

  void _buildChild(int index) {
    if (_builtChildren[index] == null) {
      _builtChildren[index] = widget.children[index](context);
    }
  }

  @override
  void didUpdateWidget(TLazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildChild(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: _builtChildren.map((child) => child ?? SizedBox()).toList(),
    );
  }
}
