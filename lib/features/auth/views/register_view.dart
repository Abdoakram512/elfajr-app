import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/nationality_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/user_role.dart';
import '../view_models/auth_cubit.dart';
import '../view_models/auth_state.dart';
import '../widgets/nationality_picker_sheet.dart';
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

  String _selectedNationality = 'مصري';
  List<String> _nationalities = [
    'مصري',
    'سوري',
    'سوداني',
    'يمني',
    'فلسطيني',
    'أردني',
    'عراقي',
    'لبناني',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _fetchNationalities();
  }

  void _fetchNationalities() {
    FirebaseFirestore.instance.collection('nationalities').get().then((snap) {
      if (snap.docs.isNotEmpty && mounted) {
        setState(() {
          final list = snap.docs
              .map((d) {
                final raw = (d.data()['name'] ?? d.id).toString().trim();
                return raw.toMasculineNationality();
              })
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();
          if (list.isNotEmpty) {
            _nationalities = list;
            if (!_nationalities.contains(_selectedNationality)) {
              _selectedNationality = _nationalities.first;
            }
          }
        });
      }
    }).catchError((_) {});
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
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(10),
                    // Back button & header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'auth.create_account'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(16),
                    Text(
                      'auth.register_title'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const Gap(6),
                    Text(
                      'auth.register_subtitle'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                    const Gap(20),

                    // Role Selector
                    RoleSelectionPillGroup(
                      selectedRole: _selectedRole,
                      onRoleChanged: (role) {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                    ),

                    const Gap(24),

                    // Name / Store Name
                    CustomTextField(
                      controller: _nameController,
                      label: _selectedRole == UserRole.merchant
                          ? 'auth.store_name_label'.tr()
                          : 'auth.full_name'.tr(),
                      hint: _selectedRole == UserRole.merchant
                          ? 'auth.store_name_hint'.tr()
                          : 'auth.full_name_hint'.tr(),
                      prefixIcon: _selectedRole == UserRole.merchant
                          ? Icons.storefront_rounded
                          : Icons.person_outline_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'auth.validation_name_required'.tr()
                          : null,
                    ),

                    const Gap(16),

                    // Beneficiary: National ID
                    if (_selectedRole == UserRole.beneficiary) ...[
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

                      // Nationality Selector Tile
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
                            onTap: () => NationalityPickerSheet.show(
                              context,
                              nationalities: _nationalities,
                              selectedNationality: _selectedNationality,
                              onSelected: (nat) => setState(() => _selectedNationality = nat),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                      _selectedNationality,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryLight,
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

                    if (_selectedRole == UserRole.merchant) ...[
                      const Gap(16),
                      CustomTextField(
                        controller: _extraDetailsController,
                        label: 'profile.cr_number_label'.tr(),
                        hint: '123456',
                        prefixIcon: Icons.receipt_long_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    // Email (for Merchant and others, optional for Beneficiary)
                    if (_selectedRole != UserRole.beneficiary) ...[
                      const Gap(16),
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
                    ],

                    const Gap(16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: 'auth.password'.tr(),
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'auth.validation_password_required'.tr();
                        }
                        if (val.length < 6) {
                          return 'auth.validation_password_min'.tr();
                        }
                        return null;
                      },
                    ),

                    const Gap(16),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'auth.confirm_password'.tr(),
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'auth.validation_passwords_mismatch'.tr();
                        }
                        return null;
                      },
                    ),

                    const Gap(28),

                    // Submit Button
                    PrimaryButton(
                      text: 'auth.register'.tr(),
                      isLoading: isLoading,
                      onPressed: _submitRegister,
                    ),

                    const Gap(20),

                    // Already have account
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.already_have_account'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(RouteNames.login),
                            child: Text(
                              'auth.login'.tr(),
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
