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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
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

Future<void> scheduleNotification(Drug drug) async {
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
        final tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + (j - now.weekday + 7) % 7,
            time.hour,
            time.minute);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          i * 7 + j, // id
          drug.name, // title
          'It\'s time to take ${drug.dosage} of ${drug.name}', // body
          scheduledDate, // scheduledDate
          platformChannelSpecifics, // notificationDetails
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exact,
        );
      }
    }
  }
}
