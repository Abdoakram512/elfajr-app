import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../routes/route_names.dart';
import '../../../features/notifications/view_models/notifications_cubit.dart';
import '../../../features/notifications/view_models/notifications_state.dart';

class NotificationBellButton extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;

  const NotificationBellButton({
    super.key,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final unread = state.unreadCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  unread > 0
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  size: 21,
                  color: iconColor ??
                      (unread > 0
                          ? AppColors.primary
                          : AppColors.textPrimaryLight),
                ),
                padding: EdgeInsets.zero,
                onPressed: () => context.push(RouteNames.notifications),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
