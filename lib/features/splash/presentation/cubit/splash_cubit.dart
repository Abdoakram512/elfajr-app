import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/cache_helper.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../auth/view_models/auth_cubit.dart';
import '../../../auth/view_models/auth_state.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final CacheHelper _cacheHelper;
  final AuthRepository _authRepository;
  final AuthCubit _authCubit;

  SplashCubit({
    required CacheHelper cacheHelper,
    required AuthRepository authRepository,
    required AuthCubit authCubit,
  })  : _cacheHelper = cacheHelper,
        _authRepository = authRepository,
        _authCubit = authCubit,
        super(SplashInitial());

  Future<void> initApp() async {
    emit(SplashLoading());

    // Allow splash animation to display smoothly
    await Future.delayed(AppConstants.splashDuration);

    final isOnboardingCompleted = _cacheHelper.isOnboardingCompleted();

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
