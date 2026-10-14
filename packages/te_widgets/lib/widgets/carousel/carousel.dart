import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A paged carousel for promo banners, dashboard announcements, or image
/// galleries, with dot indicators, autoplay, and swipe/arrow navigation.
///
/// ```dart
/// TCarousel(
///   height: 180,
///   autoplay: true,
///   children: [
///     Container(color: Colors.blue, child: const Center(child: Text('Slide 1'))),
///     Container(color: Colors.green, child: const Center(child: Text('Slide 2'))),
///   ],
/// )
/// ```
class TCarousel extends StatefulWidget {
  /// The slides to display.
  final List<Widget> children;

  /// Height of the carousel viewport.
  final double height;

  /// Automatically advances slides when true.
  final bool autoplay;

  /// Delay between automatic slide advances.
  final Duration autoplayInterval;

  /// Border radius applied to each slide and the viewport.
  final double borderRadius;

  /// Shows left/right arrow navigation controls (desktop/hover affordance).
  final bool showArrows;

  /// Shows the bottom dot page indicator.
  final bool showIndicators;

  /// Loops back to the first slide after the last, continuing to animate
  /// forward (never reversing) when wrapping around.
  final bool loop;

  /// Called with the real (0-based, non-wrapping) slide index when the
  /// active slide changes.
  final ValueChanged<int>? onPageChanged;

  const TCarousel({
    super.key,
    required this.children,
    this.height = 200,
    this.autoplay = false,
    this.autoplayInterval = const Duration(seconds: 4),
    this.borderRadius = 12,
    this.showArrows = true,
    this.showIndicators = true,
    this.loop = true,
    this.onPageChanged,
  });

  @override
  State<TCarousel> createState() => _TCarouselState();
}

class _TCarouselState extends State<TCarousel> {
  // Large base so the infinite PageView can move forward-only in both
  // directions without ever hitting index 0 (which would force a reverse
  // animation when looping past the last real slide).
  static const int _initialPage = 10000;

  late final PageController _controller;
  late int _rawPage;
  Timer? _timer;

  int get _count => widget.children.length;
  int get _realPage => _rawPage % _count;

  @override
  void initState() {
    super.initState();
    _rawPage = _initialPage - (_initialPage % _count);
    _controller = PageController(initialPage: _rawPage);
    if (widget.autoplay) _startAutoplay();
  }

  void _startAutoplay() {
    _timer?.cancel();
    if (_count < 2) return;
    _timer = Timer.periodic(widget.autoplayInterval, (_) {
      if (!mounted) return;
      if (!widget.loop && _realPage == _count - 1) return;
      _controller.nextPage(duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    });
  }

  @override
  void didUpdateWidget(TCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoplay != oldWidget.autoplay || widget.autoplayInterval != oldWidget.autoplayInterval) {
      widget.autoplay ? _startAutoplay() : _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Jumps to [realTarget] by always moving forward on the infinite index
  /// space (never backward), so tapping an earlier dot still animates
  /// forward through the remaining slides instead of reversing.
  void _goTo(int realTarget) {
    final currentReal = _realPage;
    if (realTarget == currentReal) return;

    final forwardSteps = (realTarget - currentReal) % _count;
    final target = _rawPage + (forwardSteps == 0 ? _count : forwardSteps);
    _controller.animateToPage(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void _goBack() {
    _controller.animateToPage(_rawPage - 1, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void _goNext() {
    _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = _count;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.loop ? null : count,
              onPageChanged: (i) {
                setState(() => _rawPage = i);
                widget.onPageChanged?.call(_realPage);
              },
              itemBuilder: (context, i) => widget.children[i % count],
            ),

            if (widget.showArrows && count > 1) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: widget.loop || _realPage > 0 ? _goBack : null,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: widget.loop || _realPage < count - 1 ? _goNext : null,
                  ),
                ),
              ),
            ],

            if (widget.showIndicators && count > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(count, (i) {
                    final active = i == _realPage;
                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? colors.surface : colors.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: onTap == null ? 0.12 : 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
