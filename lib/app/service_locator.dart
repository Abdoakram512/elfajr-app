import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Feature
import '../features/auth/data_sources/auth_local_data_source.dart';
import '../features/auth/data_sources/auth_remote_data_source.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/auth_repository_impl.dart';
import '../features/auth/view_models/auth_cubit.dart';

// Beneficiary Feature
import '../features/beneficiary/data_sources/beneficiary_remote_data_source.dart';
import '../features/beneficiary/repositories/beneficiary_repository.dart';
import '../features/beneficiary/repositories/beneficiary_repository_impl.dart';
import '../features/beneficiary/view_models/beneficiary_cubit.dart';

// Merchant Feature
import '../features/merchant/data_sources/merchant_remote_data_source.dart';
import '../features/merchant/repositories/merchant_repository.dart';
import '../features/merchant/repositories/merchant_repository_impl.dart';
import '../features/merchant/view_models/merchant_cubit.dart';

// Admin Feature
import '../features/admin/data_sources/admin_remote_data_source.dart';
import '../features/admin/repositories/admin_repository.dart';
import '../features/admin/repositories/admin_repository_impl.dart';
import '../features/admin/view_models/admin_cubit.dart';

// Info & Content Feature
import '../features/info_content/data_sources/info_remote_data_source.dart';
import '../features/info_content/repositories/info_repository.dart';
import '../features/info_content/repositories/info_repository_impl.dart';
import '../features/info_content/view_models/info_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. External Services
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. Auth Feature Layering
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl()),
  );

  // 3. Beneficiary Feature Layering
  sl.registerLazySingleton<BeneficiaryRemoteDataSource>(
    () => BeneficiaryRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<BeneficiaryRepository>(
    () => BeneficiaryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<BeneficiaryCubit>(
    () => BeneficiaryCubit(repository: sl()),
  );

  // 4. Merchant Feature Layering
  sl.registerLazySingleton<MerchantRemoteDataSource>(
    () => MerchantRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<MerchantRepository>(
    () => MerchantRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<MerchantCubit>(
    () => MerchantCubit(repository: sl()),
  );

  // 5. Admin Feature Layering
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(repository: sl()),
  );

  // 6. Info & Content Feature Layering
  sl.registerLazySingleton<InfoRemoteDataSource>(
    () => InfoRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<InfoRepository>(
    () => InfoRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<InfoCubit>(
    () => InfoCubit(repository: sl()),
  );
}
