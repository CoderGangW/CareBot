import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:myapps/pages/account_page.dart';
import 'package:myapps/pages/add_Robot.dart';
import 'package:myapps/pages/home_page.dart';
import 'package:myapps/pages/notifications_page.dart';
import 'package:myapps/pages/loginPage.dart';
import 'package:myapps/pages/more_page.dart';
import 'package:myapps/pages/Robot_Details.dart';
import 'package:myapps/pages/signup_Page.dart';

import 'package:permission_handler/permission_handler.dart';

int local_notification_id = 0;

String username = "";

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String navigationActionId = 'id_3';

void _permissionWithNotification() async {
  await [Permission.notification].request();
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("BACKGROUND FCM MESSAGE TEST");
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _permissionWithNotification();
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM token : $token");

  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_ic_notification');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('앱이 화면에 있을 때 메시지 수신!');
    print('메시지 데이터: ${message.data}');

    if (message.notification != null) {
      print('메시지에 알림이 포함되어 있음: ${message.notification}');
      _showNotification(message.notification!);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('새로운 onMessageOpenedApp 이벤트가 발생했습니다!');
    print('메시지 데이터: ${message.data}');

    if (message.notification != null) {
      print('메시지에 알림이 포함되어 있음: ${message.notification}');
      navigateToPage(message.data['page']);
    }
  });

  runApp(MyApp());
}

Future<void> _showNotification(RemoteNotification notification) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel',
    'FCM 알림',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  final DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    local_notification_id++,
    notification.title,
    notification.body,
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

Future selectNotification(String? payload) async {
  if (payload != null) {
    print('알림 페이로드: $payload');
    navigateToPage(payload);
  }
}

void navigateToPage(String? page) {
  // TODO: Implement code to navigate to appropriate page based on data in notification
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '로봇 관리 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CareBot(),
      routes: {
        '/home': (context) => HomePage(),
        '/robot_details': (context) => robotdetails(),
        '/more': (context) => MorePage(),
        '/addRobot': (context) => addRobot(),
        '/account': (context) => accountPage(),
        '/login': (context) => loginPage(),
        '/login/signup': (context) => signupPage(),
      },
    );
  }
}

class CareBot extends StatefulWidget {
  const CareBot({Key? key}) : super(key: key);

  @override
  _CareBotState createState() => _CareBotState();
}

class _CareBotState extends State<CareBot> {
  int currentPageIndex = 1;

  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            if (currentPageIndex != index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          },
          indicatorColor: Colors.deepPurpleAccent,
          selectedIndex: currentPageIndex,
          backgroundColor: Colors.black12,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.notifications, color: Colors.white),
              icon: Badge(child: Icon(Icons.notifications)),
              label: '알림',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: Colors.white),
              icon: Icon(Icons.home),
              label: '홈',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.more_horiz, color: Colors.white),
              icon: Icon(Icons.more_horiz),
              label: '더보기',
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          children: const [
            NotificationsPage(),
            HomePage(),
            MorePage(),
          ],
        ),
      ),
    );
  }
}
