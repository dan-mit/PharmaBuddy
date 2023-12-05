import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/HomePage.dart';
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

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  for (int i = 0; i < drug.times.length; i++) {
    TimeOfDay time = drug.times[i];
    for (int j = 0; j < drug.days.length; j++) {
      if (drug.days[j]) {
        int dayDifference = j + 1 - now.weekday;
        int notificationID = i * 7 + j;
        tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, time.hour, time.minute);

        // Adjust for same day notification if the time is later than current time
        if (dayDifference < 0 ||
            (dayDifference == 0 &&
                (now.hour > time.hour ||
                    (now.hour == time.hour && now.minute >= time.minute)))) {
          // Schedule for the next week if the time has passed today or if the day is earlier in the week
          scheduledDate = scheduledDate.add(Duration(days: dayDifference));
        } else if (dayDifference > 0) {
          // Schedule for later in the current week
          scheduledDate = scheduledDate.add(Duration(days: 7 + dayDifference));
        }

        // Schedule the notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationID, // Unique ID for each notification
          drug.name, // Title
          'It\'s time to take ${drug.dosage} of ${drug.name}', // Body
          scheduledDate, // Scheduled date
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          matchDateTimeComponents: DateTimeComponents
              .dayOfWeekAndTime, // Recurring weekly on the same day and time
        );

        print("Notification scheduled for ${drug.name} at $scheduledDate");
      }
    }
  }
}

Future<void> showImmediateNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'immediate_channel_id', // Unique ID for the notification channel
    'Immediate Notifications', // Name for the notification channel
    channelDescription: 'Immediate notifications for drug reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title, // Notification title
    body, // Notification body
    notificationDetails,
    payload: 'Custom Payload', // Optional payload
  );
}
