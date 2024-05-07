import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:myapps/pages/account_page.dart';
import 'package:myapps/pages/add_Robot.dart';
import 'package:myapps/pages/home_page.dart';
import 'package:myapps/pages/loginPage.dart';
import 'package:myapps/pages/notifications_page.dart';
import 'package:myapps/pages/more_page.dart';
import 'package:myapps/pages/Robot_Details.dart';

import 'firebase_initializer.dart'; // Firebase 초기화 코드를 import

String username = "";

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase(); // Firebase 초기화 함수 호출
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/notifications': (context) => NotificationsPage(),
        '/more': (context) => MorePage(),
        '/addRobot': (context) => addRobot(),
        '/account': (context) => accountPage(),
        '/login': (context) => loginPage(),
        //'/login/signup' : (context) => signupPage(),
      },
    );
  }
}

class CareBot extends StatefulWidget {
  const CareBot({super.key});

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
