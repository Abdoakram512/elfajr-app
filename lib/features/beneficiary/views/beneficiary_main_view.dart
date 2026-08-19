import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../view_models/beneficiary_cubit.dart';
import 'tabs/beneficiary_home_tab.dart';
import 'tabs/beneficiary_profile_tab.dart';
import 'tabs/beneficiary_redemptions_tab.dart';

class BeneficiaryMainView extends StatefulWidget {
  const BeneficiaryMainView({super.key});

  @override
  State<BeneficiaryMainView> createState() => _BeneficiaryMainViewState();
}

class _BeneficiaryMainViewState extends State<BeneficiaryMainView> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      BeneficiaryHomeTab(
        onSwitchToHistory: () => setState(() => _currentTabIndex = 1),
      ),
      const BeneficiaryRedemptionsTab(),
      const BeneficiaryProfileTab(),
    ];

    return BlocProvider(
      create: (context) => getIt<BeneficiaryCubit>(),
      child: Scaffold(
        body: IndexedStack(index: _currentTabIndex, children: tabs),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          items: [
            CustomBottomNavBarItem(
              icon: Icons.qr_code_2_outlined,
              activeIcon: Icons.qr_code_2_rounded,
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
