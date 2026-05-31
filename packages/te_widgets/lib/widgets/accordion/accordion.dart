import 'package:flutter/material.dart';
import 'accordion_theme.dart';

class TAccordion extends StatefulWidget {
  final Widget title;
  final Widget content;
  final TAccordionTheme? theme;
  final bool initiallyExpanded;

  const TAccordion({
    super.key,
    required this.title,
    required this.content,
    this.theme,
    this.initiallyExpanded = false,
  });

  @override
  State<TAccordion> createState() => _TAccordionState();
}

class _TAccordionState extends State<TAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Theme logic would go here
    return ExpansionTile(
      title: widget.title,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.content,
        ),
      ],
    );
  }
}
