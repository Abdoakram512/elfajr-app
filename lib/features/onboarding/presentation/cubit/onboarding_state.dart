import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  final int currentPage;
  const OnboardingState({this.currentPage = 0});

  @override
  List<Object?> get props => [currentPage];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial({super.currentPage = 0});
}

class OnboardingPageChanged extends OnboardingState {
  const OnboardingPageChanged({required super.currentPage});
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted({required super.currentPage});
}
