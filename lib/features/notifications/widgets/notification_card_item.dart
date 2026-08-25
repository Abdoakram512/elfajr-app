import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/utils/app_formatters.dart';

class NotificationCardItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCardItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final config = _NotificationTypeUiConfig.fromType(notification.type);
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            Gap(6),
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnread
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.borderLight,
                width: isUnread ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.025),
                  blurRadius: isUnread ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Bubble
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: config.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: config.borderColor, width: 1),
                  ),
                  child: Center(
                    child: Icon(config.icon, color: config.color, size: 22),
                  ),
                ),
                const Gap(12),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Unread Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: config.bgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: config.borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              config.tag,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: config.color,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: AppColors.primary,
                                  ),
                                  Gap(4),
                                  Text(
                                    'جديد',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Gap(6),

                      // Title
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                              isUnread ? FontWeight.w900 : FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                          height: 1.3,
                        ),
                      ),
                      const Gap(3),

                      // Body
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),

                      // Optional Amount Pill
                      if (notification.amount != null &&
                          notification.amount! > 0) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.payments_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const Gap(5),
                              Text(
                                'المبلغ: ${currencyFormatter.format(notification.amount)} ج.م',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Gap(8),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const Gap(6),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: AppColors.textMutedLight,
                              ),
                              const Gap(4),
                              Text(
                                AppFormatters.formatDateTime(
                                  notification.timestamp,
                                  context: context,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                config.actionLabel,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Gap(3),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 9.5,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
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
  }
}

class _NotificationTypeUiConfig {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final String tag;
  final String actionLabel;

  const _NotificationTypeUiConfig({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.tag,
    required this.actionLabel,
  });

  factory _NotificationTypeUiConfig.fromType(NotificationType type) {
    switch (type) {
      case NotificationType.paymentReceipt:
        return const _NotificationTypeUiConfig(
          icon: Icons.receipt_long_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primarySubtle,
          borderColor: Color(0xFFC7E6D8),
          tag: 'حوالة مالية 💳',
          actionLabel: 'عرض الإيصال',
        );
      case NotificationType.budgetAllocated:
        return const _NotificationTypeUiConfig(
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primarySubtle,
          borderColor: Color(0xFFC7E6D8),
          tag: 'شحن عهدة 💰',
          actionLabel: 'عرض العهدة',
        );
      case NotificationType.extraDisbursementResponse:
        return const _NotificationTypeUiConfig(
          icon: Icons.offline_bolt_rounded,
          color: AppColors.accentDark,
          bgColor: AppColors.amber50,
          borderColor: AppColors.amber100,
          tag: 'صرف استثنائي ⚡',
          actionLabel: 'عرض العهدة',
        );
      case NotificationType.aidDistributed:
        return const _NotificationTypeUiConfig(
          icon: Icons.inventory_2_rounded,
          color: Color(0xFF2563EB),
          bgColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
          tag: 'سلة غذائية 📦',
          actionLabel: 'تفاصيل البطاقة',
        );
      case NotificationType.cardStatusUpdate:
        return const _NotificationTypeUiConfig(
          icon: Icons.shield_rounded,
          color: Color(0xFF7C3AED),
          bgColor: Color(0xFFF5F3FF),
          borderColor: Color(0xFFDDD6FE),
          tag: 'تحديث بطاقة 🛡️',
          actionLabel: 'تفاصيل البطاقة',
        );
      case NotificationType.general:
        return const _NotificationTypeUiConfig(
          icon: Icons.notifications_active_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primarySubtle,
          borderColor: Color(0xFFC7E6D8),
          tag: 'إشعار عام 🔔',
          actionLabel: 'التفاصيل',
        );
    }
  }
}
