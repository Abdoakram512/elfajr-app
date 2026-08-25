import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../routes/route_names.dart';
import '../../../features/notifications/view_models/notifications_cubit.dart';
import '../../../features/notifications/view_models/notifications_state.dart';

class InAppNotificationBannerOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotificationBannerOverlay({super.key, required this.child});

  @override
  State<InAppNotificationBannerOverlay> createState() =>
      _InAppNotificationBannerOverlayState();
}

class _InAppNotificationBannerOverlayState
    extends State<InAppNotificationBannerOverlay>
    with SingleTickerProviderStateMixin {
  NotificationModel? _currentNotification;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _showNotification(NotificationModel notification) {
    _dismissTimer?.cancel();
    setState(() {
      _currentNotification = notification;
    });

    _animController.forward(from: 0);

    _dismissTimer = Timer(const Duration(seconds: 6), () {
      _hideNotification();
    });
  }

  void _hideNotification() {
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentNotification = null;
        });
        context.read<NotificationsCubit>().dismissLatestIncoming();
      }
    });
  }

  void _handleNotificationTap(NotificationModel notification) {
    _hideNotification();
    context.read<NotificationsCubit>().markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.paymentReceipt:
        try {
          context.push(RouteNames.merchantPaymentReceipts);
        } catch (_) {}
        break;
      case NotificationType.extraDisbursementResponse:
      case NotificationType.budgetAllocated:
        try {
          context.push(RouteNames.merchantDashboard);
        } catch (_) {}
        break;
      case NotificationType.aidDistributed:
      case NotificationType.cardStatusUpdate:
        try {
          context.push(RouteNames.beneficiaryDashboard);
        } catch (_) {}
        break;
      case NotificationType.general:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (prev, curr) =>
          curr.latestIncomingNotification != null &&
          curr.latestIncomingNotification != prev.latestIncomingNotification,
      listener: (context, state) {
        if (state.latestIncomingNotification != null) {
          _showNotification(state.latestIncomingNotification!);
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_currentNotification != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Dismissible(
                        key: ValueKey(_currentNotification!.id),
                        direction: DismissDirection.up,
                        onDismissed: (_) => _hideNotification(),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                _handleNotificationTap(_currentNotification!),
                            borderRadius: BorderRadius.circular(20),
                            splashColor: AppColors.primarySubtle,
                            highlightColor: AppColors.primarySubtle.withValues(
                              alpha: 0.5,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0A734D,
                                    ).withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildIconBadge(_currentNotification!.type),
                                  const Gap(13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _currentNotification!.title,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors
                                                      .textPrimaryLight,
                                                ),
                                              ),
                                            ),
                                            if (_currentNotification!.amount !=
                                                    null &&
                                                _currentNotification!.amount! >
                                                    0)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.primarySubtle,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Text(
                                                  '${currencyFormatter.format(_currentNotification!.amount)} ج.م',
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const Gap(4),
                                        Text(
                                          _currentNotification!.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondaryLight,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: AppColors.textMutedLight,
                                    ),
                                    onPressed: _hideNotification,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconBadge(NotificationType type) {
    IconData icon;
    Color iconColor;
    Color bgColor;
    Color borderColor;

    switch (type) {
      case NotificationType.paymentReceipt:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primarySubtle;
        borderColor = const Color(0xFFC7E6D8);
        break;
      case NotificationType.budgetAllocated:
        icon = Icons.account_balance_wallet_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primarySubtle;
        borderColor = const Color(0xFFC7E6D8);
        break;
      case NotificationType.extraDisbursementResponse:
        icon = Icons.offline_bolt_rounded;
        iconColor = AppColors.accentDark;
        bgColor = AppColors.amber50;
        borderColor = AppColors.amber100;
        break;
      case NotificationType.aidDistributed:
        icon = Icons.inventory_2_rounded;
        iconColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        break;
      case NotificationType.cardStatusUpdate:
        icon = Icons.shield_rounded;
        iconColor = const Color(0xFF7C3AED);
        bgColor = const Color(0xFFF5F3FF);
        borderColor = const Color(0xFFDDD6FE);
        break;
      case NotificationType.general:
        icon = Icons.notifications_active_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primarySubtle;
        borderColor = const Color(0xFFC7E6D8);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 22)),
    );
  }
}
