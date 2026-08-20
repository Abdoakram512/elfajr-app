import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;
  final AuthCubit _authCubit;

  SplashCubit({
    required SharedPreferences prefs,
    required AuthRepository authRepository,
    required AuthCubit authCubit,
  })  : _prefs = prefs,
        _authRepository = authRepository,
        _authCubit = authCubit,
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
      final cachedUser = await _authRepository.getCurrentUser();

      if (cachedUser != null) {
        _authCubit.emit(Authenticated(cachedUser));
        if (!cachedUser.isActive || !cachedUser.isApproved) {
          emit(const SplashNavigateToDashboard('suspended'));
        } else {
          emit(SplashNavigateToDashboard(cachedUser.role.name));
        }
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (_) {
      emit(SplashNavigateToLogin());
    }
  }
}

