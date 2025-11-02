import 'package:flutter/material.dart';

class THoverable extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovering) builder;
  final MouseCursor cursor;

  const THoverable({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<THoverable> createState() => _THoverableState();
}

class _THoverableState extends State<THoverable> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: widget.builder(context, _isHovering),
    );
  }
}
