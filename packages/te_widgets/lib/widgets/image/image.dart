import 'package:flutter/material.dart';

class TImage extends StatelessWidget {
  final String? url;
  final double size;
  final String placeholder;
  final Color? backgroundColor;
  final double padding;

  const TImage({
    super.key,
    this.url,
    this.size = 80,
    this.placeholder = 'package:te_widgets/assets/icons/no_image.png',
    this.backgroundColor,
    this.padding = .0,
  });

  @override
  Widget build(BuildContext context) {
    final isPackageAsset = placeholder.startsWith('package:');
    String assetPath = placeholder;
    String? package;
    if (isPackageAsset) {
      final parts = placeholder.substring(8).split('/');
      package = parts.first;
      assetPath = parts.sublist(1).join('/');
    }

    return Container(
      width: size + padding,
      height: size + padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12.0)),
      child: url == null || url!.isEmpty
          ? Image.asset(assetPath, package: package, width: size, height: size, fit: BoxFit.contain)
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(assetPath, package: package, width: size, height: size, fit: BoxFit.contain);
              },
            ),
    );
  }
}
