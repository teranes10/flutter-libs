import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

class TAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isWideScreen;
  final VoidCallback onMenuPressed;
  final VoidCallback onCartPressed;
  final List<TNavItem> navItems;

  const TAppBar({super.key, required this.isWideScreen, required this.onMenuPressed, required this.onCartPressed, required this.navItems});

  @override
  Size get preferredSize => Size.fromHeight(isWideScreen ? 66 : 112);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final inputSize = TInputSize.md;
    final buttonSize = TButtonSize.fromInputSize(inputSize);

    final searchBar = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400, maxHeight: inputSize.height),
      child: TTextField(
        placeholder: 'Search Products...',
        theme: context.theme.textFieldTheme.copyWith(size: inputSize),
      ),
    );

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: BoxBorder.fromLTRB(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 25 : 10, vertical: 2.5),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  TLogo(text: "myPOS"),
                  if (isWideScreen)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 7.5,
                        children: [
                          searchBar,
                          TButton(size: buttonSize, color: colors.secondary, icon: Icons.qr_code_scanner, onTap: () {}),
                        ],
                      ),
                    ),
                  if (isWideScreen) TNavbar(items: navItems, spacing: 8, alignment: MainAxisAlignment.spaceBetween),
                  if (isWideScreen) TImage.profile(name: "Teranes", role: "Admin", url: 'https://imgur.com/qNOjJje'),
                  if (isWideScreen)
                    TButton(
                      size: TButtonSize.md.copyWith(icon: 16),
                      type: TButtonType.icon,
                      icon: Icons.wb_sunny,
                      color: Colors.yellow.shade700,
                      activeIcon: Icons.nights_stay,
                      activeColor: Colors.cyan.shade600,
                      active: context.isDarkMode,
                      onChanged: (_) => themeNotifier.toggleTheme(),
                    ),
                  if (isWideScreen)
                    TButton(
                      type: TButtonType.icon,
                      icon: Icons.logout_rounded,
                      size: TButtonSize.xs.copyWith(icon: 16),
                      color: AppColors.grey,
                      onPressed: (_) {},
                    ),
                  if (!isWideScreen)
                    TButton(
                      type: TButtonType.icon,
                      size: TButtonSize.sm.copyWith(icon: 20),
                      icon: Icons.shopping_cart,
                      color: colors.onSurface,
                      onTap: onCartPressed,
                    ),
                ],
              ),
              if (!isWideScreen) ...[
                const SizedBox(height: 10),
                Row(
                  spacing: 7.5,
                  children: [
                    Expanded(child: searchBar),
                    TButton(size: buttonSize, color: colors.secondary, icon: Icons.qr_code_scanner, onTap: () {}),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
