import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/service_locator.dart';
import '../../constants/app_colors.dart';
import '../../routes/route_names.dart';
import '../../../features/auth/view_models/auth_cubit.dart';

class LogoutConfirmDialog extends StatelessWidget {
  final String? title;
  final String? message;

  const LogoutConfirmDialog({
    super.key,
    this.title,
    this.message,
  });

  static Future<void> show(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      builder: (ctx) => LogoutConfirmDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Text(title ?? 'profile.logout_confirm_title'.tr()),
        ],
      ),
      content: Text(
        message ?? 'profile.logout_confirm_desc'.tr(),
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            getIt<AuthCubit>().signOut();
            context.go(RouteNames.login);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'common.logout'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
