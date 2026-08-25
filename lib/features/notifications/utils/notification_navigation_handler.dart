import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qout/core/routes/route_names.dart';
import '../../../core/models/notification_model.dart';

abstract class NotificationNavigationHandler {
  static void navigate(BuildContext context, NotificationModel notification) {
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
}
