import 'package:flutter_bloc/flutter_bloc.dart';
import 'volunteer_state.dart';

class VolunteerCubit extends Cubit<VolunteerState> {
  VolunteerCubit() : super(const VolunteerState()) {
    loadInitialData();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void setApprovalStatus(bool approved) {
    emit(state.copyWith(isApproved: approved));
  }

  void loadInitialData() {
    final mockTasks = [
      const FieldMissionTask(
        id: 'TSK-101',
        beneficiaryName: 'أسرة أم خالد',
        phone: '+966 50 123 4567',
        address: 'حي طويق، شارع الذهبي، مبنى 14',
        aidPackage: 'سلة غذائية تموينية + كرتون حليب أطفال',
        isCompleted: false,
      ),
      const FieldMissionTask(
        id: 'TSK-102',
        beneficiaryName: 'أسرة أبو ياسر',
        phone: '+966 55 987 6543',
        address: 'حي السويدي، قرب حديقة الأندلس',
        aidPackage: 'طرد مستلزمات طبية وأدوية مزمنة',
        isCompleted: false,
      ),
      const FieldMissionTask(
        id: 'TSK-098',
        beneficiaryName: 'أسرة أبو سلمان',
        phone: '+966 54 321 0987',
        address: 'حي الشفا، شارع الستين',
        aidPackage: 'سلة تموين شهرية',
        isCompleted: true,
      ),
    ];

    emit(state.copyWith(tasks: mockTasks));
  }

  void completeTask(String taskId) {
    final updatedTasks = state.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isCompleted: true);
      }
      return t;
    }).toList();

    emit(state.copyWith(
      tasks: updatedTasks,
      completedMissions: state.completedMissions + 1,
      volunteerHours: state.volunteerHours + 2,
      successMessage: 'dashboard.volunteer.delivery_success',
    ));
  }

  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: null));
  }
}
