import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TAvatar extends StatelessWidget {
  final String? name;
  final String? role;
  final double size;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final String? url;
  final String placeholder;

  const TAvatar(
      {super.key,
      this.name,
      this.role,
      this.size = 42,
      this.borderWidth = 5,
      this.borderRadius = const BorderRadius.all(Radius.circular(40)),
      this.url,
      this.placeholder = "package:te_widgets/assets/icons/profile.png"});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      spacing: 7.5,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: colors.surfaceDim, borderRadius: borderRadius),
          child: Center(
            child: Container(
              width: size - borderWidth,
              height: size - borderWidth,
              decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: borderRadius),
              child: TImage(size: size - borderWidth, placeholder: placeholder, url: url),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            if (!name.isNullOrBlank) Text(name!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: colors.onSurface)),
            if (!role.isNullOrBlank)
              Text(role!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
