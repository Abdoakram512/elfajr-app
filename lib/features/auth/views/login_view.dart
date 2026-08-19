import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/service_locator.dart';
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
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = sl<SharedPreferences>();
      final savedRememberMe =
          prefs.getBool(AppConstants.prefsKeyRememberMe) ?? true;
      final savedEmail = prefs.getString(AppConstants.prefsKeySavedEmail) ?? '';

      if (mounted) {
        setState(() {
          _rememberMe = savedRememberMe;
          if (savedRememberMe && savedEmail.isNotEmpty) {
            _emailController.text = savedEmail;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleRememberMe() async {
    final newValue = !_rememberMe;
    setState(() {
      _rememberMe = newValue;
    });

    try {
      final prefs = sl<SharedPreferences>();
      await prefs.setBool(AppConstants.prefsKeyRememberMe, newValue);
      if (!newValue) {
        await prefs.remove(AppConstants.prefsKeySavedEmail);
      } else if (_emailController.text.trim().isNotEmpty) {
        await prefs.setString(
          AppConstants.prefsKeySavedEmail,
          _emailController.text.trim(),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        final prefs = sl<SharedPreferences>();
        await prefs.setBool(AppConstants.prefsKeyRememberMe, _rememberMe);
        if (_rememberMe) {
          await prefs.setString(AppConstants.prefsKeySavedEmail, email);
        } else {
          await prefs.remove(AppConstants.prefsKeySavedEmail);
        }
      } catch (_) {}

      if (!mounted) return;
      context.read<AuthCubit>().login(
        email: email,
        password: password,
        rememberMe: _rememberMe,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(20),

                    // Top Bar: Back button + Language Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteNames.roleSelection);
                            }
                          },
                        ),
                        // Language Switcher Button
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
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              isArabic ? 'English' : 'العربية',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(16),

                    // Brand Logo Mark
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 48,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.spa_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const Gap(24),

                    // Title
                    Text(
                          'auth.login_title'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2, end: 0),

                    const Gap(8),

                    // Subtitle
                    Text(
                      'auth.login_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

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

                    const Gap(14),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        InkWell(
                          onTap: _toggleRememberMe,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _rememberMe
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _rememberMe
                                          ? AppColors.primary
                                          : AppColors.borderLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _rememberMe
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const Gap(8),
                                Text(
                                  'تذكرني',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _rememberMe
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _rememberMe
                                        ? AppColors.textPrimaryLight
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Forgot Password
                        TextButton(
                          onPressed: () =>
                              context.push(RouteNames.forgotPassword),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(28),

                    // Login Button
                    PrimaryButton(
                          text: 'auth.login_button'.tr(),
                          isLoading: isLoading,
                          onPressed: _submitLogin,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const Gap(32),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.dont_have_account'.tr(),
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(4),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.register),
                          child: Text(
                            'auth.register'.tr(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

                    const Gap(24),
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
