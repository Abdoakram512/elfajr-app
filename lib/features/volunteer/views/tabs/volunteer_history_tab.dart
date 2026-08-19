import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../view_models/volunteer_cubit.dart';
import '../../view_models/volunteer_state.dart';
import '../../widgets/field_task_card.dart';

class VolunteerHistoryTab extends StatelessWidget {
  const VolunteerHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VolunteerCubit, VolunteerState>(
      builder: (context, state) {
        final completedList = state.completedTasksList;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('dashboard.tabs.history'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: completedList.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد مهام منجزة في السجل بعد',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: completedList.length,
                  separatorBuilder: (context, index) => const Gap(14),
                  itemBuilder: (context, index) {
                    return FieldTaskCard(
                      task: completedList[index],
                      onComplete: () {},
                    );
                  },
                ),
        );
      },
    );
  }
}
