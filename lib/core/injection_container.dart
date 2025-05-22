import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/auth/data/datasources/auth_remote_data_sources.dart';
import 'package:station_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:station_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:station_manager/features/auth/domain/usecase/login_usecase.dart';
import 'package:station_manager/features/auth/domain/usecase/logout_usecase.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/station/data/datasources/station_remote_data_sources.dart';
import 'package:station_manager/features/station/data/repositories/station_repository_impl.dart';
import 'package:station_manager/features/station/domain/repositories/station_repository.dart';
import 'package:station_manager/features/station/domain/usecases/get_station_by_id_usecase.dart';
import 'package:station_manager/features/station/presentation/bloc/station_bloc.dart';
import 'package:station_manager/features/user/data/datasources/user_remote_data_source.dart';
import 'package:station_manager/features/user/data/repositories/user_repository_impl.dart';
import 'package:station_manager/features/user/domain/repositories/user_repository.dart';
import 'package:station_manager/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:station_manager/features/user/presentation/bloc/user_bloc.dart';

final GetIt sl = GetIt.instance;

void setUpDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => TokenService(sl()));

  sl.registerLazySingleton(
    () => AuthRemoteDataSources(tokenService: sl<TokenService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(authRemoteDataSources: sl<AuthRemoteDataSources>()),
  );
  sl.registerLazySingleton(
    () => LoginUsecase(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => LogoutUsecase(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUsecase: sl<LoginUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
      tokenService: sl<TokenService>(),
    ),
  );

  sl.registerLazySingleton(
    () => UserRemoteDataSource(tokenService: sl<TokenService>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userRemoteDataSource: sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => GetUserByIdUsecase(userRepository: sl<UserRepository>()),
  );
  sl.registerLazySingleton(
    () => UserBloc(getUserByIdUsecase: sl<GetUserByIdUsecase>()),
  );

  sl.registerLazySingleton(
    () => StationRemoteDataSources(tokenService: sl<TokenService>()),
  );
  sl.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(
      stationRemoteDataSources: sl<StationRemoteDataSources>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetStationByIdUsecase(stationRepository: sl<StationRepository>()),
  );
  sl.registerLazySingleton(
    () => StationBloc(getStationByIdUsecase: sl<GetStationByIdUsecase>()),
  );
}
