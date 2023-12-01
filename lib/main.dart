import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/HomePage.dart';
import 'pages/DashboardPage.dart';
import 'package:pharmabuddy/pages/SchedulePage.dart';
import 'package:pharmabuddy/pages/LocatePage.dart';
import 'package:pharmabuddy/pages/SearchPage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pharmabuddy/models/drug.dart';
import 'package:provider/provider.dart';
import 'package:pharmabuddy/models/drug_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
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

  runApp(
    //Initialize the provider
    ChangeNotifierProvider(
      create: (context) => DrugProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

//Main code for the scheduling of notifications
Future<void> scheduleWeeklyNotification(Drug drug) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'drug_id',
    'drug_notifications',
    channelDescription: 'Notifications about drug schedules',
    importance: Importance.max,
    priority: Priority.high,
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  for (int i = 0; i < drug.times.length; i++) {
    TimeOfDay time = drug.times[i];
    for (int j = 0; j < drug.days.length; j++) {
      if (drug.days[j]) {
        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, time.hour, time.minute);
        scheduledDate =
            scheduledDate.add(Duration(days: (j - now.weekday + 7) % 7));

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
        print("Scheduling notification for ${drug.name} at $scheduledDate");
        print("Now: $now, Scheduled Date: $scheduledDate, Weekday Index: $j");

        // Schedule the first notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          i * 7 + j, // Unique ID for each notification
          drug.name, // Title
          'It\'s time to take ${drug.dosage} of ${drug.name}', // Body
          scheduledDate, // First scheduled date
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents
              .dayOfWeekAndTime, // This will match the day of the week and time
        );
      }
    }
  }
}
