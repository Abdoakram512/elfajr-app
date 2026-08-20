import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
    final isPending = user?.isApproved == false;

    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated || state is AuthInitial) {
            context.go(RouteNames.login);
          }
        },
        child: Scaffold(
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
                        color: isPending ? Colors.amber[800] : AppColors.error,
                      ),
                    ),
                    const Gap(24),

                    // Title
                    Text(
                      isPending
                          ? 'الحساب قيد المراجعة'
                          : 'تم إيقاف الحساب مؤقتاً',
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
                          ? 'تم تسجيل حسابك بنجاح وهو الآن بانتظار موافقة واعتماد إدارة منظومة قُوت.\nسيتم إشعارك فور اكتمال المراجعة والتفعيل.'
                          : 'تم تعطيل أو تعليق هذا الحساب مؤقتاً بواسطة المشرف الإداري.\nيرجى التواصل مع الدعم الفني للاستفسار أو إعادة التنشيط.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const Gap(32),

                    // User Info Card
                    if (user != null)
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
                            _buildRow('الاسم المسجل:', user!.name),
                            const Divider(
                              height: 20,
                              color: AppColors.borderLight,
                            ),
                            _buildRow('البريد الإلكتروني:', user!.email),
                            const Divider(
                              height: 20,
                              color: AppColors.borderLight,
                            ),
                            _buildRow(
                              'نوع الحساب:',
                              user!.role.name == 'merchant'
                                  ? 'صراف / منفذ معتمد'
                                  : user!.role.name == 'beneficiary'
                                  ? 'مستفيد إغاثي'
                                  : user!.role.name,
                            ),
                            const Divider(
                              height: 20,
                              color: AppColors.borderLight,
                            ),
                            _buildRow(
                              'حالة الاعتماد:',
                              isPending ? 'قيد المراجعة ⏳' : 'موقوف مؤقتاً ⚠️',
                              valueColor: isPending
                                  ? Colors.amber[800]
                                  : AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    const Gap(36),

                    // Contact Support Button (Centered)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(RouteNames.contactSupport);
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
                              Icon(Icons.support_agent_rounded, size: 20),
                              Gap(8),
                              Text(
                                'التواصل مع الدعم الفني',
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

                    // Logout Button (Centered + Instant Action)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          getIt<AuthCubit>().signOut();
                          context.go(RouteNames.login);
                        },
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.center,
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.error),
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
                              Icon(
                                Icons.logout_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                              Gap(8),
                              Text(
                                'تسجيل الخروج والعودة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
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
        ),
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
