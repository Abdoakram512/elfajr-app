import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/user_role.dart';
import '../view_models/auth_cubit.dart';
import '../view_models/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.login_success'.tr(args: [state.user.name])),
              backgroundColor: AppColors.success,
            ),
          );
          // Route to role specific dashboard
          switch (state.user.role) {
            case UserRole.admin:
              context.go(RouteNames.adminDashboard);
              break;
            case UserRole.volunteer:
              context.go(RouteNames.volunteerDashboard);
              break;
            case UserRole.donor:
              context.go(RouteNames.donorDashboard);
              break;
            case UserRole.beneficiary:
              context.go(RouteNames.beneficiaryDashboard);
              break;
            case UserRole.merchant:
              context.go(RouteNames.merchantDashboard);
              break;
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar with Brand & Language Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              'app_name'.tr(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        // Language Switcher
                        InkWell(
                          onTap: () {
                            final newLocale = isArabic
                                ? AppConstants.englishLocale
                                : AppConstants.arabicLocale;
                            context.setLocale(newLocale);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.language_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const Gap(6),
                                Text(
                                  isArabic ? 'English' : 'العربية',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(36),

                    // Greeting Header
                    Text(
                          'auth.welcome_back'.tr(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),

                    const Gap(8),

                    Text(
                          'auth.login_subtitle'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms),

                    const Gap(32),

                    // Email Field
                    CustomTextField(
                          controller: _emailController,
                          label: 'auth.email'.tr(),
                          hint: 'example@domain.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'auth.validation_email_required'.tr();
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'auth.validation_email_invalid'.tr();
                            }
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0),

                    const Gap(20),

                    // Password Field
                    CustomTextField(
                          controller: _passwordController,
                          label: 'auth.password'.tr(),
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth.validation_password_required'.tr();
                            }
                            if (value.length < 6) {
                              return 'auth.validation_password_min'.tr();
                            }
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0),

                    const Gap(12),

                    // Forgot Password
                    Align(
                      alignment: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.push(RouteNames.forgotPassword),
                        child: Text(
                          'auth.forgot_password'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const Gap(24),

                    // Login Button
                    PrimaryButton(
                          text: 'auth.login'.tr(),
                          isLoading: isLoading,
                          onPressed: _submitLogin,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const Gap(32),

                    // Don't have an account? Sign up
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.dont_have_account'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(RouteNames.roleSelection),
                            child: Text(
                              'auth.register'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
