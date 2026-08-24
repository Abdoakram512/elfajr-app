import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/cache_helper.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CacheHelper _cacheHelper;

  OnboardingCubit({required CacheHelper cacheHelper})
      : _cacheHelper = cacheHelper,
        super(const OnboardingInitial(currentPage: 0));

  void onPageChanged(int index) {
    emit(OnboardingPageChanged(currentPage: index));
  }

  Future<void> completeOnboarding() async {
    await _cacheHelper.saveData(
      key: AppConstants.prefsKeyOnboardingCompleted,
      value: true,
    );
    emit(OnboardingCompleted(currentPage: state.currentPage));
  }
}
