import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmabuddy/models/notification_manager.dart';
import 'pages/HomePage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:pharmabuddy/models/drug_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final NotificationManager notificationManager =
    NotificationManager(flutterLocalNotificationsPlugin);

//RunTime Permission request function for alarms
Future<void> requestExactAlarmPermission() async {
  var status = await Permission.scheduleExactAlarm.status;
  if (!status.isGranted) {
    await Permission.scheduleExactAlarm.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Request permision for exact alarms
  await requestExactAlarmPermission();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final NotificationManager notificationManager =
      NotificationManager(flutterLocalNotificationsPlugin);

  runApp(
    //Initialize the provider
    ChangeNotifierProvider(
      create: (context) => DrugProvider(),
      child: MyApp(notificationManager: notificationManager),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationManager notificationManager;

  MyApp({Key? key, required this.notificationManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(notificationManager: notificationManager),
    );
  }
}
