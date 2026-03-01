import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/location/data/datasources/location_local_datasource.dart';
import '../../features/location/data/datasources/location_remote_datasource.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/business/repositories/location_repository.dart';
import '../../features/location/business/usecases/check_permission_status_usecase.dart';
import '../../features/location/business/usecases/get_current_location_usecase.dart';
import '../../features/location/business/usecases/request_location_permission_usecase.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/alarms/business/repositories/alarm_repository.dart';
import '../../features/alarms/business/usecases/get_alarms_usecase.dart';
import '../../features/alarms/business/usecases/add_alarm_usecase.dart';
import '../../features/alarms/business/usecases/delete_alarm_usecase.dart';
import '../../features/alarms/business/usecases/toggle_alarm_usecase.dart';
import '../../features/alarms/business/usecases/update_alarm_usecase.dart';
import '../../features/alarms/data/repositories/alarm_repository_impl.dart';
import '../../features/alarms/presentation/bloc/alarm_bloc.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Services
  sl.registerLazySingleton(() => NotificationService());

  // Data Sources
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Location Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Alarm Repository
  sl.registerLazySingleton<AlarmRepository>(
    () => AlarmRepositoryImpl(sharedPreferences: sl()),
  );

  // Location Use Cases
  sl.registerLazySingleton(
    () => CheckPermissionStatusUseCase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => RequestLocationPermissionUseCase(repository: sl()),
  );
  sl.registerLazySingleton(() => GetCurrentLocationUseCase(repository: sl()));

  // Alarm Use Cases
  sl.registerLazySingleton(() => GetAlarmsUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddAlarmUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteAlarmUseCase(repository: sl()));
  sl.registerLazySingleton(() => ToggleAlarmUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateAlarmUseCase(repository: sl()));

  // BLoCs
  sl.registerFactory(
    () => LocationBloc(
      checkPermissionStatus: sl(),
      requestPermission: sl(),
      getCurrentLocation: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => AlarmBloc(
      repository: sl(),
      notificationService: sl(),
      getAlarmsUseCase: sl(),
      addAlarmUseCase: sl(),
      deleteAlarmUseCase: sl(),
      toggleAlarmUseCase: sl(),
      updateAlarmUseCase: sl(),
    ),
  );
}
