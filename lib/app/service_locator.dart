import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import '../core/services/notification_service.dart';

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
import '../features/merchant/data_sources/merchant_remote_data_source_impl.dart';
import '../features/merchant/repositories/merchant_repository.dart';
import '../features/merchant/repositories/merchant_repository_impl.dart';
import '../features/merchant/view_models/merchant_dashboard_cubit.dart';
import '../features/merchant/view_models/redemption_cubit.dart';

// Admin Feature
import '../features/admin/data_sources/admin_remote_data_source.dart';
import '../features/admin/repositories/admin_repository.dart';
import '../features/admin/repositories/admin_repository_impl.dart';
import '../features/admin/view_models/admin_merchants_cubit.dart';
import '../features/admin/view_models/admin_overview_cubit.dart';

// Info & Content Feature
import '../features/info_content/data_sources/info_remote_data_source.dart';
import '../features/info_content/repositories/info_repository.dart';
import '../features/info_content/repositories/info_repository_impl.dart';
import '../features/info_content/view_models/info_cubit.dart';

// Splash & Onboarding Feature
import '../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../features/splash/presentation/cubit/splash_cubit.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. Core External Infrastructure & Services Singletons
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService.instance,
  );

  // 2. Auth Feature Singletons
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );

  // 3. Beneficiary Feature Singletons & Factories
  getIt.registerLazySingleton<BeneficiaryRemoteDataSource>(
    () =>
        BeneficiaryRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<BeneficiaryRepository>(
    () => BeneficiaryRepositoryImpl(
      remoteDataSource: getIt<BeneficiaryRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<BeneficiaryCubit>(
    () => BeneficiaryCubit(repository: getIt<BeneficiaryRepository>()),
  );

  // 4. Merchant Feature Singletons & Focused Factories
  getIt.registerLazySingleton<MerchantRemoteDataSource>(
    () => MerchantRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<MerchantRepository>(
    () => MerchantRepositoryImpl(
      remoteDataSource: getIt<MerchantRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<MerchantDashboardCubit>(
    () => MerchantDashboardCubit(repository: getIt<MerchantRepository>()),
  );
  getIt.registerFactory<RedemptionCubit>(
    () => RedemptionCubit(repository: getIt<MerchantRepository>()),
  );

  // 5. Admin Feature Singletons & Focused Factories
  getIt.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: getIt<AdminRemoteDataSource>()),
  );
  getIt.registerFactory<AdminOverviewCubit>(
    () => AdminOverviewCubit(repository: getIt<AdminRepository>()),
  );
  getIt.registerFactory<AdminMerchantsCubit>(
    () => AdminMerchantsCubit(repository: getIt<AdminRepository>()),
  );

  // 6. Info & Content Feature Singletons & Factories
  getIt.registerLazySingleton<InfoRemoteDataSource>(
    () => InfoRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<InfoRepository>(
    () => InfoRepositoryImpl(remoteDataSource: getIt<InfoRemoteDataSource>()),
  );
  getIt.registerFactory<InfoCubit>(
    () => InfoCubit(repository: getIt<InfoRepository>()),
  );

  // 7. Splash & Onboarding Feature Factories
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(
      prefs: getIt<SharedPreferences>(),
      authRepository: getIt<AuthRepository>(),
      authCubit: getIt<AuthCubit>(),
    ),
  );
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(prefs: getIt<SharedPreferences>()),
  );
}
