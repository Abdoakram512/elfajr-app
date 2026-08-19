import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../view_models/merchant_cubit.dart';
import '../view_models/merchant_state.dart';
import 'tabs/merchant_history_tab.dart';
import 'tabs/merchant_home_tab.dart';
import 'tabs/merchant_profile_tab.dart';

class MerchantMainView extends StatelessWidget {
  const MerchantMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MerchantCubit(),
      child: const _MerchantMainScaffold(),
    );
  }
}

class _MerchantMainScaffold extends StatelessWidget {
  const _MerchantMainScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        final cubit = context.read<MerchantCubit>();

        final tabs = [
          const MerchantHomeTab(),
          const MerchantHistoryTab(),
          const MerchantProfileTab(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: state.currentTabIndex,
            children: tabs,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: state.currentTabIndex,
            onTap: cubit.setTab,
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
        );
      },
    );
  }
}
