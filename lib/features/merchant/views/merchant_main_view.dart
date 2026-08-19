import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../view_models/merchant_cubit.dart';
import '../view_models/merchant_state.dart';
import 'tabs/merchant_history_tab.dart';
import 'tabs/merchant_home_tab.dart';

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
          const _MerchantProfileTab(),
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

class _MerchantProfileTab extends StatelessWidget {
  const _MerchantProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('dashboard.tabs.profile'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.store_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            const Text(
              'أسواق النخبة المركزية (منفذ صرف معتمد)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Gap(6),
            const Text(
              'merchant@qout.org • س.ت: 1010293847',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  sl<AuthCubit>().signOut();
                  context.go(RouteNames.login);
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(
                  'common.logout'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
