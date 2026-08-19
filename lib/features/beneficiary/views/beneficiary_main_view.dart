import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../view_models/beneficiary_cubit.dart';
import '../view_models/beneficiary_state.dart';
import 'tabs/beneficiary_home_tab.dart';
import 'tabs/beneficiary_profile_tab.dart';
import 'tabs/beneficiary_redemptions_tab.dart';

class BeneficiaryMainView extends StatelessWidget {
  const BeneficiaryMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BeneficiaryCubit(),
      child: const _BeneficiaryMainScaffold(),
    );
  }
}

class _BeneficiaryMainScaffold extends StatelessWidget {
  const _BeneficiaryMainScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final cubit = context.read<BeneficiaryCubit>();

        final tabs = [
          const BeneficiaryHomeTab(),
          const BeneficiaryRedemptionsTab(),
          const BeneficiaryProfileTab(),
        ];

        return Scaffold(
          body: IndexedStack(index: state.currentTabIndex, children: tabs),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: state.currentTabIndex,
            onTap: cubit.setTab,
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
        );
      },
    );
  }
}
