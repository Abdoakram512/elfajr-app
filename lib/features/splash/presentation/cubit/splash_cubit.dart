import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences _prefs;

  SplashCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(SplashInitial());

  Future<void> initApp() async {
    emit(SplashLoading());

    // Allow splash animation to display smoothly
    await Future.delayed(AppConstants.splashDuration);

    final isOnboardingCompleted =
        _prefs.getBool(AppConstants.prefsKeyOnboardingCompleted) ?? false;

    if (!isOnboardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else {
      // Future: Check firebase auth user session & role
      emit(SplashNavigateToLogin());
    }
  }
}
