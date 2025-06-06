import 'package:flutter/material.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_items.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_logo.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_profile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Sidebar extends StatelessWidget {
  final SidebarLogo? logo;
  final SidebarProfile? profile;
  final List<dynamic>? items;
  final double width;

  const Sidebar({
    super.key,
    this.logo,
    this.profile,
    this.items,
    this.width = 275,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // Hide sidebar on small screens
        if (sizingInformation.isMobile) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: width,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (logo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 36.0),
                      child: logo!,
                    ),
                  if (profile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 36.0),
                      child: profile!,
                    ),
                  if (items != null && items!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 10.0, right: 10.0),
                      child: SidebarItems(
                        items: items!,
                        heightOffset: 255,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
