import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/user_role.dart';
import '../view_models/auth_cubit.dart';
import '../view_models/auth_state.dart';
import '../widgets/dynamic_nationality_picker_sheet.dart';
import '../widgets/role_selection_pill_group.dart';

class RegisterView extends StatelessWidget {
  final UserRole initialRole;

  const RegisterView({super.key, this.initialRole = UserRole.beneficiary});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: _RegisterViewBody(initialRole: initialRole),
    );
  }
}

class _RegisterViewBody extends StatefulWidget {
  final UserRole initialRole;

  const _RegisterViewBody({required this.initialRole});

  @override
  State<_RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<_RegisterViewBody> {
  final _formKey = GlobalKey<FormState>();
  late UserRole _selectedRole;

  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _extraDetailsController = TextEditingController();

  String? _selectedNationality;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _extraDetailsController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final isMerchant = _selectedRole == UserRole.merchant;
      final isBeneficiary = _selectedRole == UserRole.beneficiary;

      if (isBeneficiary && (_selectedNationality == null || _selectedNationality!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.validation_nationality_required'.tr()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        email: isBeneficiary ? '' : _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        storeName: isMerchant ? _nameController.text.trim() : null,
        commercialReg: isMerchant ? _extraDetailsController.text.trim() : null,
        nationality: isBeneficiary ? _selectedNationality : null,
        nationalId: isBeneficiary ? _nationalIdController.text.trim() : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is Authenticated) {
          if (state.user.role == UserRole.beneficiary) {
            context.go(RouteNames.beneficiaryDashboard);
          } else if (state.user.role == UserRole.merchant) {
            context.go(RouteNames.merchantDashboard);
          } else if (state.user.role == UserRole.admin) {
            context.go(RouteNames.adminDashboard);
          }
        }
      },
      builder: (context, state) {
        final isMerchant = _selectedRole == UserRole.merchant;
        final isBeneficiary = _selectedRole == UserRole.beneficiary;
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo & Branding
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: AppColors.primary,
                                child: const Icon(
                                  Icons.spa_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).scale(),

                      const Gap(16),

                      Text(
                        'auth.register_title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'auth.register_subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),

                      const Gap(24),

                      // Role Selection Tabs (Modular Widget)
                      RoleSelectionPillGroup(
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) => setState(() => _selectedRole = role),
                      ),

                      const Gap(24),

                      // Dynamic Fields by Role
                      CustomTextField(
                        controller: _nameController,
                        label: isMerchant
                            ? 'auth.store_name'.tr()
                            : 'auth.full_name'.tr(),
                        hint: isMerchant
                            ? 'auth.store_name_hint'.tr()
                            : 'auth.full_name_hint'.tr(),
                        prefixIcon: isMerchant
                            ? Icons.store_rounded
                            : Icons.person_outline,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'auth.validation_name_required'.tr()
                            : null,
                      ),

                      const Gap(16),

                      // Beneficiary: National ID & Dynamic Live Nationality Picker
                      if (isBeneficiary) ...[
                        CustomTextField(
                          controller: _nationalIdController,
                          label: 'auth.national_id'.tr(),
                          hint: 'auth.national_id_hint'.tr(),
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'auth.validation_national_id_required'.tr()
                              : null,
                        ),
                        const Gap(16),

                        // Dynamic Nationality Selector Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'auth.nationality'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Gap(6),
                            InkWell(
                              onTap: () => DynamicNationalityPickerSheet.show(
                                context,
                                selectedNationality: _selectedNationality,
                                onSelected: (nat) =>
                                    setState(() => _selectedNationality = nat),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedNationality != null
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySubtle,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.public_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        _selectedNationality ??
                                            'auth.select_nationality'.tr(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: _selectedNationality != null
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedNationality != null
                                              ? AppColors.textPrimaryLight
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                      ],

                      // Phone
                      CustomTextField(
                        controller: _phoneController,
                        label: 'auth.phone'.tr(),
                        hint: '010XXXXXXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'auth.validation_phone_required'.tr()
                            : null,
                      ),

                      const Gap(16),

                      // City
                      CustomTextField(
                        controller: _cityController,
                        label: 'auth.city'.tr(),
                        hint: 'auth.city_hint'.tr(),
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'auth.validation_city_required'.tr()
                            : null,
                      ),

                      const Gap(16),

                      // Merchant-only: Commercial Reg
                      if (isMerchant) ...[
                        CustomTextField(
                          controller: _extraDetailsController,
                          label: 'auth.commercial_registration'.tr(),
                          hint: 'auth.commercial_registration_hint'.tr(),
                          prefixIcon: Icons.business_outlined,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'auth.validation_cr_required'.tr()
                              : null,
                        ),
                        const Gap(16),
                      ],

                      // Email (Required for Merchants, Optional for Beneficiaries)
                      if (!isBeneficiary) ...[
                        CustomTextField(
                          controller: _emailController,
                          label: 'auth.email'.tr(),
                          hint: 'example@domain.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'auth.validation_email_required'.tr();
                            }
                            if (!val.contains('@')) {
                              return 'auth.validation_email_invalid'.tr();
                            }
                            return null;
                          },
                        ),
                        const Gap(16),
                      ],

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        label: 'auth.password'.tr(),
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (val) => val == null || val.length < 6
                            ? 'auth.validation_password_length'.tr()
                            : null,
                      ),

                      const Gap(16),

                      // Confirm Password
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'auth.confirm_password'.tr(),
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'auth.validation_password_mismatch'.tr();
                          }
                          return null;
                        },
                      ),

                      const Gap(24),

                      // Submit Button
                      PrimaryButton(
                        text: 'auth.register_button'.tr(),
                        isLoading: isLoading,
                        onPressed: _submitRegister,
                      ),

                      const Gap(20),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.already_have_account'.tr(),
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(RouteNames.login),
                            child: Text(
                              'auth.login_now'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
