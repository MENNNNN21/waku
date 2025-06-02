import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif != null) {
        showLocalNotification(notif.title ?? "", notif.body ?? "");
      }
    });
  }

  static void showLocalNotification(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'waku_channel',
      'Notifikasi Waku',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    _localPlugin.show(0, title, body, notifDetails);
  }
}
