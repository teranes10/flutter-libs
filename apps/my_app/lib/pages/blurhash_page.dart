import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Upload an image, pick the detail level and get its BlurHash with a live preview.
class BlurHashPage extends StatefulWidget {
  const BlurHashPage({super.key});

  @override
  State<BlurHashPage> createState() => _BlurHashPageState();
}

class _BlurHashPageState extends State<BlurHashPage> {
  Uint8List? _bytes;
  String? _name;
  String? _hash;
  int _x = 4;
  int _y = 3;
  bool _busy = false;
  int _run = 0;

  Future<void> _pick() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      final bytes = await files.first.readAsBytes();
      setState(() {
        _bytes = bytes;
        _name = files.first.name;
      });
      await _generate();
    } catch (e) {
      if (mounted) TToastService.error(context, 'Could not read the image: $e');
    }
  }

  Future<void> _generate() async {
    final bytes = _bytes;
    if (bytes == null) return;
    final run = ++_run;
    setState(() => _busy = true);
    final hash = await TBlurHash.fromImageBytes(bytes, componentsX: _x, componentsY: _y);
    if (!mounted || run != _run) return;
    setState(() {
      _hash = hash;
      _busy = false;
    });
    if (hash == null) TToastService.error(context, 'This image could not be decoded.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hash = _hash;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BlurHash Generator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an image to get a short BlurHash string you can store next to it and show instantly as a placeholder '
            'with TBlurHashView while the real image loads. Everything runs locally; the image is not uploaded anywhere.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TCard(
            title: 'Image',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TButton(text: _bytes == null ? 'Choose image' : 'Change image', icon: Icons.image_outlined, onTap: _pick),
                    const SizedBox(width: 12),
                    if (_name != null) Flexible(child: Text(_name!, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Horizontal detail: $_x', style: TextStyle(color: colors.onSurfaceVariant)),
                TSlider(
                  value: _x.toDouble(),
                  min: 1,
                  max: 9,
                  divisions: 8,
                  onValueChanged: (v) {
                    setState(() => _x = v!.round());
                    _generate();
                  },
                ),
                Text('Vertical detail: $_y', style: TextStyle(color: colors.onSurfaceVariant)),
                TSlider(
                  value: _y.toDouble(),
                  min: 1,
                  max: 9,
                  divisions: 8,
                  onValueChanged: (v) {
                    setState(() => _y = v!.round());
                    _generate();
                  },
                ),
                Text(
                  'More components give a sharper preview and a longer hash (4 x 3 is the usual choice).',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (_bytes != null) ...[
            const SizedBox(height: 16),
            TCard(
              title: 'Result',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _preview(
                        'Original (tap for full screen)',
                        TImage(bytes: _bytes, width: 260, height: 180, padding: 0, fullScreenPreview: true),
                        colors,
                      ),
                      _preview('BlurHash', hash == null ? const SizedBox.shrink() : TBlurHashView(hash: hash), colors),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_busy) const LinearProgressIndicator(),
                  if (hash != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(hash, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                        ),
                        TCopyButton(text: hash, label: 'Copy'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${hash.length} characters', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                      child: SelectableText("TBlurHashView(hash: '$hash')", style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _preview(String label, Widget child, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 260, height: 180, child: child),
        ),
      ],
    );
  }
}
