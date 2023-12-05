import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmabuddy/models/drug.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _notificationIdCounter = 0;
  List<int> scheduledNotificationIds = [];

  NotificationManager(this.flutterLocalNotificationsPlugin);

  int get _nextNotificationId => ++_notificationIdCounter;

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
          int notificationID = _nextNotificationId;
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
            scheduledDate =
                scheduledDate.add(Duration(days: 7 + dayDifference));
          }

          // Schedule the notification
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationID,
            drug.name,
            'It\'s time to take ${drug.dosage} of ${drug.name}',
            scheduledDate,
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );

          scheduledNotificationIds.add(notificationID);
          print(
              "Notification scheduled for ${drug.name} at $scheduledDate with ID $notificationID");
        }
      }
    }
  }

  Future<void> showImmediateNotification(String title, String body) async {
    int id = _nextNotificationId;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'immediate_channel_id',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications for drug reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'Custom Payload',
    );

    print("Immediate notification shown with ID $id");
  }
}
