import 'dart:async';
import 'dart:io';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

int local_notification_id = 0;
String FCM_TOKEN = "";

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String navigationActionId = 'id_3';

void _permissionWithNotification() async {
  await [Permission.notification].request();
}

Future<bool> _localNotificationState() async {
  final prefs = await SharedPreferences.getInstance();
  var _isNotiState = prefs.getBool('isNotiState');
  return _isNotiState ?? true;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("BACKGROUND FCM MESSAGE TEST");
  print(
      'notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("백그라운드에서 메시지를 처리중: ${message.messageId}");
  // 여기에서 로컬 알림을 표시하거나 다른 백그라운드 작업을 수행할 수 있습니다.
  await _showNotification(message.notification);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('D - Firebase initialized successfully');
  } catch (e) {
    print('E - Error initializing Firebase: $e');
    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  _permissionWithNotification();

  try {
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('I - APNS Token: $apnsToken');
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print("I - FCM token : $token");
    FCM_TOKEN = token!;
  } catch (e) {
    print('E - Error getting FCM token: $e');
  }

  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_ic_notification');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  try {
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
    print('D - Local notifications initialized successfully');
  } catch (e) {
    print('E - Error initializing local notifications: $e');
  }

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

Future<void> _showNotification(RemoteNotification? notification) async {
  if (await _localNotificationState()) {
    if (notification == null) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'haesil_notification_channel',
      '해실이 알림',
      channelDescription: '해실이가 알림을 보내줘요!',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('알림 페이로드: $payload');
      navigateToPage(payload);
    }
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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SOYO',
        dividerColor: Colors.transparent,
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
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: PageView(
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 30,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // 그림자 투명도 감소
              blurRadius: 30,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          height: 30, // 네비게이션 바의 높이 감소
          onDestinationSelected: (int index) {
            if (currentPageIndex != index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
              );
            }
          },
          indicatorShape: CircleBorder(),
          indicatorColor: Color.fromARGB(255, 131, 59, 255),
          selectedIndex: currentPageIndex,
          backgroundColor: Color.fromARGB(0, 255, 0, 0),
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.notifications_rounded,
                  color: Colors.white, size: 28),
              icon: Badge(
                child: Icon(Icons.notifications_rounded, size: 28),
              ),
              label: "",
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.home_rounded, color: Colors.white, size: 28),
              icon: Icon(Icons.home_rounded, size: 28),
              label: "",
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.more_horiz_rounded, color: Colors.white, size: 28),
              icon: Icon(Icons.more_horiz_rounded, size: 28),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
