import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentationSection {
  final String id;
  final String title;
  final String? description;
  final Widget? widget;
  final String? code;
  final IconData icon;

  DocumentationSection({
    required this.id,
    required this.title,
    this.description,
    this.widget,
    this.code,
    this.icon = Icons.widgets,
  });
}

class WidgetDocumentationPage extends StatefulWidget {
  final List<DocumentationSection> sections;
  final Color primaryColor;

  const WidgetDocumentationPage({
    super.key,
    required this.sections,
    this.primaryColor = const Color(0xFF667eea),
  });

  @override
  State<WidgetDocumentationPage> createState() => _WidgetDocumentationPageState();
}

class _WidgetDocumentationPageState extends State<WidgetDocumentationPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedSections = {};
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );
    _headerAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                ...widget.sections.map((section) => _buildSection(section)),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildScrollToTopFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(DocumentationSection section) {
    final isExpanded = _expandedSections[section.id] ?? false;

    return Container(
      key: ValueKey(section.id),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    section.icon,
                    color: widget.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (section.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          section.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UI Preview (Always Shown)
                if (section.widget != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.preview,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Preview',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        section.widget!,
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Code Toggle Button
                if (section.code != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Implementation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _expandedSections[section.id] = !isExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isExpanded ? widget.primaryColor.withOpacity(0.1) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isExpanded ? widget.primaryColor.withOpacity(0.3) : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpanded ? Icons.code_off : Icons.code,
                                  size: 16,
                                  color: isExpanded ? widget.primaryColor : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isExpanded ? 'Hide Code' : 'Show Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isExpanded ? widget.primaryColor : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Animated Code Block
                if (section.code != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Container(
                              margin: const EdgeInsets.only(top: 12),
                              child: _buildCodeBlock(section.code!),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            child: Text(
              code.trim(),
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: Color(0xFFE2E8F0),
                height: 1.5,
              ),
            ),
          ),
          // Copy button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code.trim()));
                  _showMessage('Code copied to clipboard!');
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.copy,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToTopFAB() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showFAB = _scrollController.hasClients && _scrollController.offset > 300;
        return AnimatedScale(
          scale: showFAB ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    // Since we're not using Scaffold, we'll need to get the ScaffoldMessenger from context
    // or handle this differently. For now, we'll use the context to find the nearest Scaffold
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
