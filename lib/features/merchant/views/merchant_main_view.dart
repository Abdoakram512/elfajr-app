import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../view_models/merchant_dashboard_cubit.dart';
import 'tabs/merchant_history_tab.dart';
import 'tabs/merchant_home_tab.dart';
import 'tabs/merchant_profile_tab.dart';
import 'merchant_payment_receipts_view.dart';

class MerchantMainView extends StatelessWidget {
  const MerchantMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MerchantDashboardCubit>(),
      child: const _MerchantMainViewBody(),
    );
  }
}

class _MerchantMainViewBody extends StatefulWidget {
  const _MerchantMainViewBody();

  @override
  State<_MerchantMainViewBody> createState() => _MerchantMainViewBodyState();
}

class _MerchantMainViewBodyState extends State<_MerchantMainViewBody> {
  int _currentTabIndex = 0;

  void _onSwitchTab(int index) {
    setState(() => _currentTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      MerchantHomeTab(onSwitchToHistory: () => _onSwitchTab(1)),
      const MerchantHistoryTab(),
      const MerchantPaymentReceiptsView(),
      const MerchantProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentTabIndex, children: tabs),
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
            icon: Icons.payments_outlined,
            activeIcon: Icons.payments_rounded,
            label: 'dashboard.tabs.receipts'.tr(),
          ),
          CustomBottomNavBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'dashboard.tabs.profile'.tr(),
          ),
        ],
      ),
    );
  }
}
