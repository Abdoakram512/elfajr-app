import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/view_models/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Auth Feature (Service & ViewModel)
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerFactory<AuthCubit>(() => AuthCubit(authService: sl()));
}
