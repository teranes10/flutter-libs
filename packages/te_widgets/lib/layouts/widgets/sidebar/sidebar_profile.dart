import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class SidebarProfile extends StatelessWidget {
  final String? icon;
  final String? text;

  const SidebarProfile({
    super.key,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null)
          Image.network(
            icon!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        if (text != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              text!,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
