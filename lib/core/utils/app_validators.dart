import 'package:easy_localization/easy_localization.dart';
import '../errors/failure.dart';
import 'arabic_normalizer.dart';

/// Centralized validator utility for forms, UI inputs, and data-layer guards.
class AppValidators {
  AppValidators._();

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Data Layer & Business Rule Guards (Throws [AppException] if invalid)
  // ───────────────────────────────────────────────────────────────────────────

  /// Validates all parameters for a redemption transaction before hitting Firestore.
  static void guardRedemptionInput({
    required String cardId,
    required String merchantId,
    required double amount,
    required int foodBaskets,
  }) {
    final cleanCardId = ArabicNormalizer.convertDigits(cardId);
    final cleanMerchantId = merchantId.trim();

    if (cleanCardId.isEmpty) {
      throw const AppException('merchant.invalid_card');
    }

    if (cleanMerchantId.isEmpty) {
      throw const AppException('merchant.invalid_merchant');
    }

    if (amount < 0 || foodBaskets < 0) {
      throw const AppException('merchant.enter_deduction_amount');
    }

    if (amount == 0 && foodBaskets == 0) {
      throw const AppException('merchant.enter_deduction_amount');
    }
  }

  /// Guards beneficiary security PIN (last 4 digits of National ID).
  static void guardSecurityPin({
    required String enteredPin,
    required String actualNationalId,
  }) {
    final cleanPin = ArabicNormalizer.convertDigits(enteredPin).trim();
    final cleanNatId = ArabicNormalizer.convertDigits(actualNationalId).trim();

    if (cleanPin.isEmpty) {
      throw const AppException('merchant.security_pin_error_empty');
    }

    final expectedPin = cleanNatId.length >= 4
        ? cleanNatId.substring(cleanNatId.length - 4)
        : cleanNatId;

    if (cleanPin != expectedPin) {
      throw const AppException('merchant.security_pin_error_mismatch');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. UI Form Field Validators (Returns String? error message for TextFields)
  // ───────────────────────────────────────────────────────────────────────────

  /// Required field validator
  static String? requiredField(String? value, [String? customMessage]) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? 'auth.field_required'.tr();
    }
    return null;
  }

  /// Email format validator
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.email_required'.tr();
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'auth.invalid_email'.tr();
    }
    return null;
  }

  /// Egyptian phone number validator (010, 011, 012, 015)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.phone_required'.tr();
    }
    final cleanPhone = ArabicNormalizer.convertDigits(value).replaceAll(RegExp(r'\D'), '');
    final phoneRegExp = RegExp(r'^(01[0125]\d{8}|(201|00201|\+201)[0125]\d{8})$');
    if (!phoneRegExp.hasMatch(cleanPhone)) {
      return 'auth.invalid_phone'.tr();
    }
    return null;
  }

  /// Egyptian National ID validator (14 numeric digits)
  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.national_id_required'.tr();
    }
    final cleanId = ArabicNormalizer.convertDigits(value).replaceAll(RegExp(r'\D'), '');
    if (cleanId.length != 14) {
      return 'auth.invalid_national_id'.tr();
    }
    return null;
  }

  /// Password length and strength validator
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'auth.password_required'.tr();
    }
    if (value.length < minLength) {
      return 'auth.password_too_short'.tr(namedArgs: {'count': '$minLength'});
    }
    return null;
  }

  /// Confirm password match validator
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'auth.confirm_password_required'.tr();
    }
    if (value != originalPassword) {
      return 'auth.passwords_do_not_match'.tr();
    }
    return null;
  }

  /// Positive numeric amount validator
  static String? positiveAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'merchant.enter_deduction_amount'.tr();
    }
    final clean = ArabicNormalizer.convertDigits(value);
    final parsed = double.tryParse(clean);
    if (parsed == null || parsed <= 0) {
      return 'merchant.enter_deduction_amount'.tr();
    }
    return null;
  }

  /// Security PIN validator for modal inputs (4 digits)
  static String? securityPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'merchant.security_pin_error_empty'.tr();
    }
    final clean = ArabicNormalizer.convertDigits(value);
    if (clean.length != 4) {
      return 'merchant.security_pin_error_empty'.tr();
    }
    return null;
  }
}
