import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class SidebarLogo extends StatelessWidget {
  final String? icon;
  final String? text;
  final VoidCallback? onTap;

  const SidebarLogo({
    super.key,
    this.icon,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Image.network(
              icon!,
              height: 36,
              fit: BoxFit.cover,
            ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
