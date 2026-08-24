import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../models/register_params.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  Stream<List<String>> streamNationalities() {
    return _authRepository.streamNationalities();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        getIt<NotificationService>().syncFCMToken(user.uid);
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.refreshCurrentUser();
      if (user != null) {
        getIt<NotificationService>().syncFCMToken(user.uid);
        emit(Authenticated(user));
      }
    } catch (_) {}
  }

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      getIt<NotificationService>().syncFCMToken(user.uid);
      emit(Authenticated(user));
    } catch (e) {
      final messageKey = _normalizeError(e);
      emit(AuthError(messageKey));
    }
  }

  Future<void> register(RegisterParams params) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(params);
      getIt<NotificationService>().syncFCMToken(user.uid);
      emit(Authenticated(user));
    } catch (e) {
      final messageKey = _normalizeError(e);
      emit(AuthError(messageKey));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordReset(email);
      emit(PasswordResetSent(email));
    } catch (e) {
      final messageKey = _normalizeError(e);
      emit(AuthError(messageKey));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      final messageKey = _normalizeError(e);
      emit(AuthError(messageKey));
    }
  }

  String? getSavedEmail() => _authRepository.getSavedEmail();
  bool getRememberMe() => _authRepository.getRememberMe();

  String _normalizeError(dynamic error) {
    var str = error.toString();
    str = str.replaceAll('Exception: ', '').replaceAll('AppException: ', '').trim();
    if (str.isEmpty) return 'auth_errors.user_not_found';
    return str;
  }
}
