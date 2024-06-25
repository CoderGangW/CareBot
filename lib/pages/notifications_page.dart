import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapps/pages/loading_Screen.dart';
import 'package:myapps/security/confAPI.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationItem>> _notifications;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus().then((loggedIn) {
      if (loggedIn) {
        _refreshNotifications();
      }
    });
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    return isLoggedIn;
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notifications = fetchNotifications();
    });
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    final String url = getApiUrl('/select/facility-notifications');

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username ?? '',
      }),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => NotificationItem.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 140, 79, 255), // 배경색
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline, // 잠금 아이콘
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  '알림 내역을 보려면 로그인 해야합니다!',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    '로그인',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: FutureBuilder<List<NotificationItem>>(
              future: _notifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: LoadingScreen());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 140, 79, 255), // 배경색
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline, // 에러 아이콘
                            size: 50,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '알림데이터를 받아오는데 실패했습니다!',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('알림이 없습니다.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var notification = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.notifications_sharp),
                          title: Text(notification.title),
                          subtitle: Text(
                              '${notification.subtitle}\n${notification.datetime}'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      );
    }
  }
}

class NotificationItem {
  final String title;
  final String subtitle;
  final String datetime;

  NotificationItem(
      {required this.title, required this.subtitle, required this.datetime});

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['no_title'],
      subtitle: json['no_contents'],
      datetime: json['time_stamp'],
    );
  }
}
