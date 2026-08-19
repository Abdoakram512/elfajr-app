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
import '../view_models/donor_cubit.dart';
import '../view_models/donor_state.dart';
import 'tabs/donor_explore_tab.dart';
import 'tabs/donor_history_tab.dart';
import 'tabs/donor_home_tab.dart';

class DonorMainView extends StatelessWidget {
  const DonorMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonorCubit(),
      child: const _DonorMainScaffold(),
    );
  }
}

class _DonorMainScaffold extends StatelessWidget {
  const _DonorMainScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonorCubit, DonorState>(
      builder: (context, state) {
        final cubit = context.read<DonorCubit>();

        final tabs = [
          const DonorHomeTab(),
          const DonorExploreTab(),
          const DonorHistoryTab(),
          const _DonorProfileTab(),
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
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'dashboard.tabs.home'.tr(),
              ),
              CustomBottomNavBarItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'dashboard.tabs.explore'.tr(),
              ),
              CustomBottomNavBarItem(
                icon: Icons.favorite_outline_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'dashboard.tabs.my_donations'.tr(),
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

class _DonorProfileTab extends StatelessWidget {
  const _DonorProfileTab();

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
                Icons.person_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            const Text(
              'صانع الأثر (متبرع)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Gap(6),
            const Text(
              'donor@qout.org',
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
