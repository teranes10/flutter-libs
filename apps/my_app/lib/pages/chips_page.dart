import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

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
              TTab(icon: Icons.calendar_today, text: 'Date'),
              TTab(icon: Icons.access_time, text: 'Time'),
            ],
          ),

          RoleTest()
        ],
      ),
    );
  }
}

final rolesProvider = StateProvider<List<String>>((ref) => ['guest']);

class RoleTest extends ConsumerWidget {
  const RoleTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    return Column(
      children: [
        ...roles.map((x) => Text(x)),
        TButton(
          text: 'Add admin role',
          onPressed: (_) {
            ref.read(rolesProvider.notifier).update((roles) {
              return roles.contains('admin') ? roles : [...roles, 'admin'];
            });
          },
        ),
        TButton(text: 'Need Admin Access', onPressed: (_) => _showSnackBar(context, 'Clicked by Admin')).role('admin')
      ],
    );
  }
}

extension RoleGuardExtension on Widget {
  Widget role(String role) {
    return Consumer(
      builder: (context, ref, _) {
        final roles = ref.watch(rolesProvider);

        return TGuard(
          condition: roles.contains(role),
          action: TGuardAction.disable,
          child: this,
        );
      },
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ),
  );
}
