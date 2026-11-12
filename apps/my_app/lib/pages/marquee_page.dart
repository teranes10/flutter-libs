import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TMarquee] widget.
class MarqueePage extends StatelessWidget {
  const MarqueePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marquee',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Single-line text that scrolls cyclically instead of overflowing, resting at the start so it stays readable.',
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          WidgetDocCard(
            title: 'Basic Marquee',
            description: 'Overflowing text rests, scrolls, and loops. Text that fits stays static.',
            icon: HugeIcons.strokeRoundedTextWrap,
            preview: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 180, child: TMarquee('Ergonomic wireless mechanical keyboard with hot-swappable switches')),
                SizedBox(height: 12),
                SizedBox(width: 180, child: TMarquee('Short text')),
              ],
            ),
            code: '''SizedBox(
  width: 180,
  child: TMarquee('Ergonomic wireless mechanical keyboard'),
)''',
          ),
          const SizedBox(height: 24),
          WidgetDocCard(
            title: 'Speed, Pause & Gap',
            description: 'Tune velocity (px/s), rest time before each cycle, and spacing between repeats',
            icon: HugeIcons.strokeRoundedTimer02,
            preview: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: TMarquee('Slow and relaxed: easy to read at a glance, long pause', velocity: 25, pause: Duration(seconds: 3)),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: TMarquee(
                    'Fast ticker: breaking news scrolling by quickly',
                    velocity: 90,
                    pause: Duration(milliseconds: 500),
                    gap: 64,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            code: '''TMarquee(
  'Slow and relaxed',
  velocity: 25,
  pause: Duration(seconds: 3),
)

TMarquee(
  'Fast ticker',
  velocity: 90,
  pause: Duration(milliseconds: 500),
  gap: 64,
  style: TextStyle(fontWeight: FontWeight.bold),
)''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
