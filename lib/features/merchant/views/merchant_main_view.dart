import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../view_models/merchant_dashboard_cubit.dart';
import 'tabs/merchant_history_tab.dart';
import 'tabs/merchant_home_tab.dart';
import 'tabs/merchant_profile_tab.dart';

class MerchantMainView extends StatefulWidget {
  const MerchantMainView({super.key});

  @override
  State<MerchantMainView> createState() => _MerchantMainViewState();
}

class _MerchantMainViewState extends State<MerchantMainView> {
  int _currentTabIndex = 0;

  void _onSwitchTab(int index) {
    setState(() => _currentTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      MerchantHomeTab(onSwitchToHistory: () => _onSwitchTab(1)),
      const MerchantHistoryTab(),
      const MerchantProfileTab(),
    ];

    return BlocProvider(
      create: (context) => getIt<MerchantDashboardCubit>(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentTabIndex,
          children: tabs,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentTabIndex,
          onTap: _onSwitchTab,
          items: [
            CustomBottomNavBarItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront_rounded,
              label: 'dashboard.tabs.home'.tr(),
            ),
            CustomBottomNavBarItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'dashboard.tabs.history'.tr(),
            ),
            CustomBottomNavBarItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'dashboard.tabs.profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
