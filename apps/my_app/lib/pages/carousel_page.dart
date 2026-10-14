import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  int _activeSlide = 0;

  Widget _slide(String text, Color color) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TCarousel Showcase', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Paged carousel for dashboard announcements, promo banners, and image galleries, '
            'with autoplay, swipe/arrow navigation, and dot indicators.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          TCard(
            title: 'Autoplay Promo Carousel',
            child: TCarousel(
              height: 180,
              autoplay: true,
              onPageChanged: (i) => setState(() => _activeSlide = i),
              children: [
                _slide('New Feature: Kanban Board', Colors.indigo),
                _slide('50% Off This Week Only', Colors.teal),
                _slide('System Maintenance Sunday 2AM', Colors.deepOrange),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Active slide index: $_activeSlide', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 24),

          TCard(
            title: 'Manual Image Gallery (no autoplay, no loop)',
            child: TCarousel(
              height: 220,
              autoplay: false,
              loop: false,
              children: [
                _slide('Image 1', Colors.blueGrey),
                _slide('Image 2', Colors.brown),
                _slide('Image 3', Colors.cyan.shade700),
                _slide('Image 4', Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
