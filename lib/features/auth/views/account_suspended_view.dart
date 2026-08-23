import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qout/features/auth/models/user_role.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../models/user_model.dart';
import '../view_models/auth_cubit.dart';
import '../view_models/auth_state.dart';

class AccountSuspendedView extends StatelessWidget {
  final UserModel? user;

  const AccountSuspendedView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated || state is AuthInitial) {
            context.go(RouteNames.login);
          } else if (state is Authenticated &&
              state.user.isApproved &&
              state.user.isActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('auth.login_success'.tr(args: [state.user.name])),
                backgroundColor: AppColors.success,
              ),
            );
            switch (state.user.role) {
              case UserRole.admin:
                context.go(RouteNames.adminDashboard);
                break;
              case UserRole.beneficiary:
                context.go(RouteNames.beneficiaryDashboard);
                break;
              case UserRole.merchant:
                context.go(RouteNames.merchantDashboard);
                break;
              case UserRole.volunteer:
              case UserRole.donor:
                context.go(RouteNames.beneficiaryDashboard);
                break;
            }
          }
        },
        builder: (context, state) {
          final currentUser =
              user ?? (state is Authenticated ? state.user : null);
          final isPending = currentUser?.isApproved == false;

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon Header
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.amber.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPending
                              ? Icons.hourglass_top_rounded
                              : Icons.block_flipped,
                          size: 52,
                          color:
                              isPending ? Colors.amber[800] : AppColors.error,
                        ),
                      ),
                      const Gap(24),

                      // Title
                      Text(
                        isPending
                            ? 'account_status.pending_title'.tr()
                            : 'account_status.suspended_title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const Gap(12),

                      // Description
                      Text(
                        isPending
                            ? 'account_status.pending_desc'.tr()
                            : 'account_status.suspended_desc'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const Gap(32),

                      // User Info Card
                      if (currentUser != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              _buildRow(
                                'account_status.registered_name'.tr(),
                                currentUser.name,
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.borderLight,
                              ),
                              _buildRow(
                                'account_status.registered_email'.tr(),
                                currentUser.email,
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.borderLight,
                              ),
                              _buildRow(
                                'account_status.account_type'.tr(),
                                currentUser.role.name == 'merchant'
                                    ? 'account_status.role_merchant'.tr()
                                    : currentUser.role.name == 'beneficiary'
                                    ? 'account_status.role_beneficiary'.tr()
                                    : currentUser.role.name,
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.borderLight,
                              ),
                              _buildRow(
                                'account_status.approval_status'.tr(),
                                isPending
                                    ? 'account_status.status_pending'.tr()
                                    : 'account_status.status_suspended'.tr(),
                                valueColor: isPending
                                    ? Colors.amber[800]
                                    : AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      const Gap(32),

                      // 1. Check & Refresh Status Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            await context.read<AuthCubit>().refreshUser();
                          },
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded, size: 20),
                                Gap(8),
                                Text(
                                  'تحديث حالة الحساب الآن',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),

                      // 2. Contact Support Button (Centered)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push(RouteNames.contactSupport);
                          },
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.support_agent_rounded, size: 18),
                                const Gap(8),
                                Text(
                                  'account_status.contact_support_btn'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),

                      // 3. Logout Button (Centered + Instant Action)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            getIt<AuthCubit>().signOut();
                            context.go(RouteNames.login);
                          },
                          style: TextButton.styleFrom(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            foregroundColor: AppColors.error,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const Gap(8),
                                Text(
                                  'account_status.logout_btn'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
