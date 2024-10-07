import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    String? useremail = prefs.getString('user_email');

    final String url = getApiUrl('/select/facility-notifications');

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': useremail ?? '',
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
                  '로그인이 필요한 기능입니다',
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
        body: RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: FutureBuilder<List<NotificationItem>>(
            future: _notifications,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingScreen(
                  text: '알림정보 불러오는중',
                );
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
                      elevation: 3.0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: Color.fromARGB(255, 206, 183, 37),
                                  size: 24.0,
                                ),
                                SizedBox(width: 8.0),
                                Row(
                                  children: [
                                    Text(
                                      '${notification.roName} - ',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${notification.title}',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color:
                                              Color.fromARGB(255, 59, 59, 59)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),

                            // 내용 부분
                            Text(
                              notification.subtitle,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8.0),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey,
                                  size: 16.0,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  notification.getRelativeTime(),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      );
    }
  }
}

class NotificationItem {
  final int noId;
  final String roName;
  final int faId;
  final int noLevel;
  final String title;
  final String subtitle;
  final DateTime datetime;

  NotificationItem({
    required this.noId,
    required this.roName,
    required this.faId,
    required this.noLevel,
    required this.title,
    required this.subtitle,
    required this.datetime,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // 서버 시간에서 'Z' 제거 후 파싱
    String timeStamp = json['time_stamp'] as String;
    if (timeStamp.endsWith('Z')) {
      timeStamp = timeStamp.substring(0, timeStamp.length - 1);
    }

    return NotificationItem(
      noId: json['no_id'],
      roName: json['ro_name'],
      faId: json['fa_id'],
      noLevel: json['no_level'],
      title: json['no_title'],
      subtitle: json['no_contents'],
      datetime: DateTime.parse(timeStamp),
    );
  }

  String getFormattedDate() {
    final DateFormat formatter = DateFormat('yyyy년MM월dd일 HH시mm분ss초');
    return formatter.format(datetime);
  }

  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(datetime);

    final seconds = difference.inSeconds;
    if (seconds < 60) {
      return '방금 전';
    } else if (seconds < 3600) {
      return '${(seconds / 60).floor()}분 전';
    } else if (seconds < 86400) {
      return '${(seconds / 3600).floor()}시간 전';
    } else if (seconds < 2592000) {
      return '${(seconds / 86400).floor()}일 전';
    } else if (seconds < 31536000) {
      return '${(seconds / 2592000).floor()}개월 전';
    } else {
      return '${(seconds / 31536000).floor()}년 전';
    }
  }
}
