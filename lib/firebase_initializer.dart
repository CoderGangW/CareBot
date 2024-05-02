import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
}

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('A background message just showed up: ${message.messageId}');
  // 로컬 알림으로 메시지 푸시
  showLocalNotification(message);
}

// 로컬 알림을 표시하는 함수
void showLocalNotification(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'fcm_channel', // 채널 ID
    'FCM 알림', // 채널 이름
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'fcm_channel', // 채널 ID
    'FCM 알림', // 채널 이름
    importance: Importance.max,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // 알림 ID
    'FCM 알림', // 알림 제목
    message.notification?.body, // 알림 내용
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}


