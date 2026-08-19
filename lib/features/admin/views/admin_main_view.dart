import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import 'tabs/admin_merchants_tab.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_profile_tab.dart';

class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AdminOverviewTab(),
      const AdminMerchantsTab(),
      const AdminProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabs,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: [
          CustomBottomNavBarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'dashboard.tabs.home'.tr(),
          ),
          CustomBottomNavBarItem(
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
            label: 'منافذ الصرف',
          ),
          CustomBottomNavBarItem(
            icon: Icons.admin_panel_settings_outlined,
            activeIcon: Icons.admin_panel_settings_rounded,
            label: 'dashboard.tabs.profile'.tr(),
          ),
        ],
      ),
    );
  }
}
