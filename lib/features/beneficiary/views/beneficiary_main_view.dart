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
import '../../auth/view_models/auth_state.dart';
import '../view_models/beneficiary_cubit.dart';
import '../view_models/beneficiary_state.dart';
import 'tabs/beneficiary_home_tab.dart';
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
          const _BeneficiaryProfileTab(),
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

class _BeneficiaryProfileTab extends StatelessWidget {
  const _BeneficiaryProfileTab();

  @override
  Widget build(BuildContext context) {
    final authUser = sl<AuthCubit>().state is Authenticated
        ? (sl<AuthCubit>().state as Authenticated).user
        : null;

    final displayName = authUser?.name ?? 'أحمد سعيد الغامدي';
    final displayEmail = authUser?.email ?? 'ahmed.alghamdi@qout.org';
    final displayCity = authUser?.city ?? 'الرياض';

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
                Icons.person_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Gap(4),
            Text(
              '$displayEmail • $displayCity',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '💳 مستفيد معتمد في منظومة قوت',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
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
