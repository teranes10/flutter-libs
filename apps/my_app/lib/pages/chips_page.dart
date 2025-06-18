import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/chip/chip.dart';
import 'package:te_widgets/widgets/loading-icon/loading_icon.dart';
import 'package:te_widgets/widgets/tabs/tabs.dart';

class ChipsPage extends StatelessWidget {
  const ChipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Text only chip
          TChip(
            text: 'Primary',
            color: AppColors.primary,
          ),
          TChip(
            text: 'Secondary',
            color: AppColors.secondary,
          ),
          TChip(
            text: 'Success',
            color: AppColors.success,
          ),
          TChip(
            text: 'Info',
            color: AppColors.info,
          ),
          TChip(
            text: 'Warning',
            icon: Icons.warning,
            color: AppColors.warning,
          ),
          TChip(
            icon: Icons.dangerous,
            color: AppColors.danger,
          ),

          // Tappable chip
          TChip(
            text: 'Clickable',
            icon: Icons.touch_app,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chip tapped!')),
              );
            },
          ),

          // Custom styling
          TChip(
            text: 'Custom Style',
            background: Colors.amber,
            textColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(16),
          ),

          TLoadingIcon(color: AppColors.warning),
          TLoadingIcon(type: TLoadingType.dots, color: AppColors.secondary),
          TLoadingIcon(
            type: TLoadingType.linear,
            color: AppColors.secondary,
            size: 8,
          ),
          TTabs(
            tabs: [
              TTab(icon: Icons.calendar_today, label: 'Date'),
              TTab(icon: Icons.access_time, label: 'Time'),
            ],
          ),
        ],
      ),
    );
  }
}
