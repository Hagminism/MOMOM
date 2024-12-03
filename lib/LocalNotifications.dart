import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FCM 토큰 가져오기
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // 토큰을 Firestore에 저장
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "fcmToken": token,
    });
  }

  // 알림 설정
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "budget_channel",
            "Budget Notifications",
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
