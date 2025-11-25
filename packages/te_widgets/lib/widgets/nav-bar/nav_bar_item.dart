part of 'nav_bar.dart';

class TNavItem extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;
  final IconData icon;
  final String? label;

  const TNavItem({super.key, this.onTap, this.isActive = false, required this.icon, this.label});

  TNavItem copyWith({VoidCallback? onTap, bool? isActive, IconData? icon, String? label}) {
    return TNavItem(onTap: onTap ?? this.onTap, isActive: isActive ?? this.isActive, icon: icon ?? this.icon, label: label ?? this.label);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isActive ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            spacing: 7.5,
            children: [
              Icon(icon, size: 20, color: isActive ? colors.onPrimaryContainer : colors.onSurface),
              if (isActive)
                Text(label ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onPrimaryContainer)),
              if (isActive) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
