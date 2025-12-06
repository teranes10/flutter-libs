part of 'nav_bar.dart';

/// An individual item in a [TNavbar].
///
/// `TNavItem` displays an icon and optional label. When active, it
/// highlights itself with a background color and shows the label
/// (if provided) using an animated style transition logic implied by the layout.
///
/// ## Usage
///
/// ```dart
/// TNavItem(
///   icon: Icons.settings,
///   label: 'Settings',
///   isActive: true,
///   onTap: () => print('Settings tapped'),
/// )
/// ```
class TNavItem extends StatelessWidget {
  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  /// Whether the item is currently active/selected.
  final bool isActive;

  /// The icon to display.
  final IconData icon;

  /// The optional label text to display when active.
  final String? label;

  /// Creates a navigation item.
  const TNavItem({super.key, this.onTap, this.isActive = false, required this.icon, this.label});

  /// Creates a copy of this item with optional new values.
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
