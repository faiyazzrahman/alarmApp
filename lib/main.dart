import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/alarms/presentation/bloc/alarm_bloc.dart';
import 'features/alarms/presentation/bloc/alarm_event.dart';
import 'features/location/presentation/bloc/location_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(create: (context) => sl<LocationBloc>()),
        BlocProvider<AlarmBloc>(
          create: (context) => sl<AlarmBloc>()..add(const LoadAlarms()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Travel Alarm',
        debugShowCheckedModeBanner: false,

        routerConfig: appRouter,
      ),
    );
  }
}
