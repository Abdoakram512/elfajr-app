import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
          Text(title ?? 'تأكيد تسجيل الخروج'),
        ],
      ),
      content: Text(
        message ?? 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
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
            context.read<AuthCubit>().signOut();
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
