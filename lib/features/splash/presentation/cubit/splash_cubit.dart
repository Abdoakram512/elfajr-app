import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
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
      return;
    }

    try {
      final authRepo = sl<AuthRepository>();
      final cachedUser = await authRepo.getCurrentUser();

      if (cachedUser != null) {
        sl<AuthCubit>().emit(Authenticated(cachedUser));
        emit(SplashNavigateToDashboard(cachedUser.role.name));
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (_) {
      emit(SplashNavigateToLogin());
    }
  }
}
