import 'package:equatable/equatable.dart';

class FieldMissionTask extends Equatable {
  final String id;
  final String beneficiaryName;
  final String phone;
  final String address;
  final String aidPackage;
  final bool isCompleted;

  const FieldMissionTask({
    required this.id,
    required this.beneficiaryName,
    required this.phone,
    required this.address,
    required this.aidPackage,
    this.isCompleted = false,
  });

  FieldMissionTask copyWith({bool? isCompleted}) {
    return FieldMissionTask(
      id: id,
      beneficiaryName: beneficiaryName,
      phone: phone,
      address: address,
      aidPackage: aidPackage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        beneficiaryName,
        phone,
        address,
        aidPackage,
        isCompleted,
      ];
}

class VolunteerState extends Equatable {
  final int currentTabIndex;
  final bool isApproved;
  final int completedMissions;
  final int volunteerHours;
  final List<FieldMissionTask> tasks;
  final bool isLoading;
  final String? successMessage;

  const VolunteerState({
    this.currentTabIndex = 0,
    this.isApproved = true,
    this.completedMissions = 24,
    this.volunteerHours = 48,
    this.tasks = const [],
    this.isLoading = false,
    this.successMessage,
  });

  VolunteerState copyWith({
    int? currentTabIndex,
    bool? isApproved,
    int? completedMissions,
    int? volunteerHours,
    List<FieldMissionTask>? tasks,
    bool? isLoading,
    String? successMessage,
  }) {
    return VolunteerState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isApproved: isApproved ?? this.isApproved,
      completedMissions: completedMissions ?? this.completedMissions,
      volunteerHours: volunteerHours ?? this.volunteerHours,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
    );
  }

  List<FieldMissionTask> get pendingTasks =>
      tasks.where((t) => !t.isCompleted).toList();
  List<FieldMissionTask> get completedTasksList =>
      tasks.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [
        currentTabIndex,
        isApproved,
        completedMissions,
        volunteerHours,
        tasks,
        isLoading,
        successMessage,
      ];
}
