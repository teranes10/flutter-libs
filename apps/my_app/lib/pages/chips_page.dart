import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

class ChipsPage extends StatelessWidget {
  const ChipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Solid Chips', [
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Primary', color: AppColors.primary),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Secondary', color: AppColors.secondary),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Success', color: AppColors.success),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Info', color: AppColors.info),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Warning', color: AppColors.warning),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Danger', color: AppColors.danger),
            TChip(type: TVariant.solid, icon: Icons.home, text: 'Grey', color: AppColors.grey),
          ]),
          _buildRow('Tonal Chips', [
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Primary', color: AppColors.primary),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Secondary', color: AppColors.secondary),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Success', color: AppColors.success),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Info', color: AppColors.info),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Warning', color: AppColors.warning),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Danger', color: AppColors.danger),
            TChip(type: TVariant.tonal, icon: Icons.home, text: 'Grey', color: AppColors.grey),
          ]),
          _buildRow('Outline Chips', [
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Primary', color: AppColors.primary),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Success', color: AppColors.success),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Info', color: AppColors.info),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Warning', color: AppColors.warning),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Danger', color: AppColors.danger),
            TChip(type: TVariant.outline, icon: Icons.home, text: 'Grey', color: AppColors.grey),
          ]),
          _buildRow('Text Chips', [
            TChip(type: TVariant.text, icon: Icons.home, text: 'Primary', color: AppColors.primary),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Secondary', color: AppColors.secondary),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Success', color: AppColors.success),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Info', color: AppColors.info),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Warning', color: AppColors.warning),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Danger', color: AppColors.danger),
            TChip(type: TVariant.text, icon: Icons.home, text: 'Grey', color: AppColors.grey),
          ]),
          TLoadingIcon(color: AppColors.warning),
          TLoadingIcon(type: TLoadingType.dots, color: AppColors.secondary),
          TLoadingIcon(
            type: TLoadingType.linear,
            color: AppColors.secondary,
            size: 8,
          ),
          TTabs(
            tabs: [
              TTab(icon: Icons.calendar_today, text: 'Date', value: 0),
              TTab(icon: Icons.access_time, text: 'Time', value: 1),
            ],
          ),
          RoleTest()
        ],
      ),
    );
  }

  Widget _buildRow(String label, List<Widget> buttons) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
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
