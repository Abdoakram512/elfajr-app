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
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/user_role.dart';
import '../view_models/auth_cubit.dart';
import '../view_models/auth_state.dart';

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
                var name = (d.data()['name'] ?? d.id).toString().trim();
                // Normalize feminine to masculine
                if (name == 'مصرية') name = 'مصري';
                if (name == 'سورية') name = 'سوري';
                if (name == 'سودانية') name = 'سوداني';
                if (name == 'يمنية') name = 'يمني';
                if (name == 'فلسطينية') name = 'فلسطيني';
                if (name == 'أردنية') name = 'أردني';
                if (name == 'عراقية') name = 'عراقي';
                if (name == 'لبنانية') name = 'لبناني';
                return name;
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
        if (state is Authenticated) {
          if (!state.user.isActive || !state.user.isApproved) {
            context.go(RouteNames.accountSuspended, extra: state.user);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'auth.register_success'.tr(args: [state.user.name]),
              ),
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
          appBar: AppBar(
            title: Text('auth.register'.tr()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.roleSelection);
                }
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Badge Pill with Change Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedRole == UserRole.donor
                                ? Icons.favorite_rounded
                                : _selectedRole == UserRole.beneficiary
                                ? Icons.shield_rounded
                                : _selectedRole == UserRole.merchant
                                ? Icons.storefront_rounded
                                : Icons.groups_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const Gap(8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${'auth.registering_as'.tr()} ${'auth.role_${_selectedRole.name}'.tr()}',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          TextButton(
                            onPressed: () => context.go(RouteNames.roleSelection),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'auth.change_role'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const Gap(24),

                    // Full Name Field
                    CustomTextField(
                      controller: _nameController,
                      label: 'auth.full_name'.tr(),
                      hint: 'auth.full_name_hint'.tr(),
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'auth.validation_name_required'.tr();
                        }
                        return null;
                      },
                    ),

                    const Gap(18),

                    // National ID Field for Beneficiary OR Email Field for Other Roles
                    if (_selectedRole == UserRole.beneficiary) ...[
                      CustomTextField(
                        controller: _nationalIdController,
                        label: 'auth.national_id'.tr(),
                        hint: 'auth.national_id_hint'.tr(),
                        prefixIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'auth.validation_national_id_required'.tr();
                          }
                          if (value.trim().length < 6) {
                            return 'auth_errors.invalid_national_id'.tr();
                          }
                          return null;
                        },
                      ),
                      const Gap(18),
                    ] else ...[
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
                      ),
                      const Gap(18),
                    ],

                    // Phone Number Field (Strictly Unique)
                    CustomTextField(
                      controller: _phoneController,
                      label: 'auth.phone'.tr(),
                      hint: '01xxxxxxxxx',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'auth.validation_phone_required'.tr();
                        }
                        return null;
                      },
                    ),

                    const Gap(18),

                    // Role-Specific Fields (City, Nationality, Skills, Store Info)
                    if (_selectedRole == UserRole.volunteer ||
                        _selectedRole == UserRole.beneficiary ||
                        _selectedRole == UserRole.merchant) ...[
                      CustomTextField(
                        controller: _cityController,
                        label: 'auth.city'.tr(),
                        hint: 'auth.city_hint'.tr(),
                        prefixIcon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'auth.validation_city_required'.tr();
                          }
                          return null;
                        },
                      ),
                      const Gap(18),

                      // Nationality Selector for Beneficiary
                      if (_selectedRole == UserRole.beneficiary) ...[
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
                              onTap: () => _openNationalityBottomSheet(context),
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
                        const Gap(18),
                      ],

                      // Volunteer Skills Field
                      if (_selectedRole == UserRole.volunteer) ...[
                        CustomTextField(
                          controller: _extraDetailsController,
                          label: 'auth.skills_label'.tr(),
                          hint: 'auth.skills_hint'.tr(),
                          prefixIcon: Icons.handyman_outlined,
                          maxLines: 1,
                        ),
                        const Gap(18),
                      ],

                      // Merchant Commercial Reg Field
                      if (_selectedRole == UserRole.merchant) ...[
                        CustomTextField(
                          controller: _extraDetailsController,
                          label: 'auth.store_name_label'.tr(),
                          hint: 'auth.store_name_hint'.tr(),
                          prefixIcon: Icons.storefront_rounded,
                          maxLines: 1,
                        ),
                        const Gap(18),
                      ],
                    ],

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
                    ),

                    const Gap(18),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'auth.confirm_password'.tr(),
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'auth.validation_passwords_mismatch'.tr();
                        }
                        return null;
                      },
                    ),

                    const Gap(28),

                    // Submit Registration Button
                    PrimaryButton(
                      text: 'auth.register'.tr(),
                      isLoading: isLoading,
                      onPressed: _submitRegister,
                    ),

                    const Gap(24),

                    // Already have an account?
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

  void _openNationalityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = _nationalities.where((n) {
              if (searchQuery.trim().isEmpty) return true;
              return ArabicNormalizer.matches(n, searchQuery);
            }).toList();

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Gap(16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.public_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            'auth.select_nationality'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),

                  // Search Field
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'auth.search_nationalities'.tr(),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const Gap(14),

                  // Nationalities List
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const Gap(8),
                      itemBuilder: (context, idx) {
                        final nat = filtered[idx];
                        final isSelected = nat == _selectedNationality;

                        return InkWell(
                          onTap: () {
                            setState(() => _selectedNationality = nat);
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondaryLight,
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Text(
                                    nat,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
