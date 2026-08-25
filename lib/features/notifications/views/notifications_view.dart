import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../auth/view_models/auth_cubit.dart';
import '../../auth/view_models/auth_state.dart';
import '../utils/notification_navigation_handler.dart';
import '../view_models/notifications_cubit.dart';
import '../view_models/notifications_state.dart';
import '../widgets/notification_card_item.dart';
import '../widgets/notifications_empty_state.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<NotificationsCubit>().startListening(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'notifications.title'.tr(),
          style: const TextStyle(
            fontSize: 19.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: InkWell(
                  onTap: () => cubit.markAllAsRead(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const Gap(6),
                        Text(
                          'notifications.mark_all_read'.tr(),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.notifications.isEmpty) {
            return const NotificationsEmptyState();
          }

          return AlfajrRefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is Authenticated) {
                cubit.startListening(authState.user.uid);
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final item = state.notifications[index];
                return NotificationCardItem(
                  notification: item,
                  onTap: () {
                    cubit.markAsRead(item.id);
                    NotificationNavigationHandler.navigate(context, item);
                  },
                  onDelete: () => cubit.deleteNotification(item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
