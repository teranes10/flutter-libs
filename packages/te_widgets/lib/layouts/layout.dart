import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_logo.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_profile.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Layout extends StatelessWidget {
  final List<dynamic> items;
  final SidebarLogo? logo;
  final SidebarProfile? profile;
  final Widget child;
  final String? pageTitle;

  const Layout({
    super.key,
    this.items = const [],
    this.logo,
    this.profile,
    required this.child,
    this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(14.0),
        color: AppColors.grey.shade900,
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Row(
                children: [
                  // Sidebar - hidden on small screens
                  if (!sizingInformation.isMobile)
                    Sidebar(
                      logo: logo,
                      profile: profile,
                      items: items,
                    ),
                  // Main content area
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: sizingInformation.isMobile
                            ? null
                            : Border(
                                left: BorderSide(
                                  color: AppColors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                      ),
                      child: Column(
                        children: [
                          if (pageTitle != null)
                            Container(
                              width: double.infinity,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  pageTitle!,
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          // Main content
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(32.0),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
