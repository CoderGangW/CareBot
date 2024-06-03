import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapps/pages/loading_Screen.dart';
import 'package:myapps/security/confAPI.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/*====================================================*/
/*================[ Notification Page }================*/
/*====================================================*/
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationItem>> _notifications;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notifications = fetchNotifications();
    });
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    print(prefs.getString('username'));

    final String url;

    // url = getApiUrl('/select/facility-notifications');
    if (Platform.isAndroid) {
      url = 'http://10.0.2.2/select/facility-notifications';
    } else if (Platform.isIOS) {
      url = 'http://127.0.0.1/select/facility-notifications';
    } else {
      throw UnsupportedError('지원되지 않는 환경입니다.');
    }

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
      print(jsonResponse);
      return jsonResponse
          .map((data) => NotificationItem.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                return Center(child: Text('알림데이터를 받아오는데 실패했습니다.'));
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
