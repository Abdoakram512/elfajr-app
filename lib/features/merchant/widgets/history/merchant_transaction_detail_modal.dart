import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/card_printer_service.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/common/info_key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';
import '../../../beneficiary/models/aid_card_model.dart';
import '../../models/redemption_transaction_model.dart';

class MerchantTransactionDetailModal {
  MerchantTransactionDetailModal._();

  static void show(BuildContext context, RedemptionTransactionModel tx) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AppSheetScaffold(
          title: 'merchant.history_detail_title'.tr(),
          subtitle: tx.cardId,
          icon: AppIcons.payment,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primarySubtle,
          heightFactor: 0.72,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              // Summary Amount Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald50, Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'merchant.cash_amount_disbursed'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${currencyFormatter.format(tx.amountDeducted)} ${'common.currency'.tr()}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Detail Rows Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    InfoKeyValueRow(
                      label: 'merchant.beneficiary_name_label'.tr(),
                      value: tx.beneficiaryName,
                      isBold: true,
                    ),
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'merchant.card_id_label'.tr(),
                      value: tx.cardId,
                      isBold: true,
                    ),
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'merchant.txn_time_label'.tr(),
                      value: AppFormatters.formatDateTime(
                        tx.timestamp,
                        context: context,
                      ),
                    ),
                    if (tx.merchantStoreName.isNotEmpty) ...[
                      const Gap(10),
                      InfoKeyValueRow(
                        label: 'merchant.outlet_name_label'.tr(),
                        value: tx.merchantStoreName,
                      ),
                    ],
                    const Gap(10),
                    InfoKeyValueRow(
                      label: 'merchant.ref_number_label'.tr(),
                      value: tx.transactionId,
                    ),
                    if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                      const Gap(10),
                      InfoKeyValueRow(
                        label: 'merchant.notes_label'.tr(),
                        value: tx.notes!,
                      ),
                    ],
                  ],
                ),
              ),

              const Gap(20),

              // Print / Export Button
              PrimaryButton(
                text: 'merchant.redemption_receipt.print_receipt_btn'.tr(),
                leadingIcon: AppIcons.print,
                onPressed: () {
                  Navigator.pop(ctx);
                  CardPrinterService.printAidCard(
                    card: AidCardModel(
                      cardId: tx.cardId,
                      beneficiaryId: '',
                      beneficiaryName: tx.beneficiaryName,
                      nationalId: '1089283746',
                      familyCount: 5,
                      totalBalance: tx.amountDeducted,
                      foodBasketsQuota: 0,
                      status: AidCardStatus.active,
                      expiresAt: DateTime.now().add(const Duration(days: 180)),
                      securityHash: '',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
