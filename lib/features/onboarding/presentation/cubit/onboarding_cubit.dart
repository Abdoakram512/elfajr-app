import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences _prefs;

  OnboardingCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const OnboardingInitial(currentPage: 0));

  void onPageChanged(int index) {
    emit(OnboardingPageChanged(currentPage: index));
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.prefsKeyOnboardingCompleted, true);
    emit(OnboardingCompleted(currentPage: state.currentPage));
  }
}
