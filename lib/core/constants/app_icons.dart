import 'package:flutter/material.dart';

/// Centralized Design System Icons for Qout Application.
abstract class AppIcons {
  // Navigation & Core App
  static const IconData home = Icons.home_rounded;
  static const IconData history = Icons.receipt_long_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData qrScan = Icons.qr_code_scanner_rounded;
  static const IconData card = Icons.credit_card_rounded;
  static const IconData basket = Icons.shopping_basket_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData settings = Icons.settings_rounded;

  // Actions & Navigation Directions
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData checkCircleOutline = Icons.check_circle_outline_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData print = Icons.print_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;

  // Alerts & Status
  static const IconData info = Icons.info_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData success = Icons.check_circle_rounded;
  static const IconData schedule = Icons.schedule_rounded;
  static const IconData pending = Icons.hourglass_top_rounded;

  // Payment Methods & Financials
  static const IconData payment = Icons.payment_rounded;
  static const IconData instapay = Icons.bolt_rounded;
  static const IconData vodafoneCash = Icons.phone_android_rounded;
  static const IconData bankTransfer = Icons.account_balance_rounded;
  static const IconData cash = Icons.money_rounded;
  static const IconData receipt = Icons.receipt_rounded;

  // Profile & Contact
  static const IconData email = Icons.email_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData location = Icons.location_on_outlined;
  static const IconData family = Icons.family_restroom_rounded;
  static const IconData nationalId = Icons.badge_outlined;
  static const IconData logout = Icons.logout_rounded;
  static const IconData language = Icons.language_rounded;
}
