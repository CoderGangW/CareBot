import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapps/security/confAPI.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class addRobot extends StatefulWidget {
  const addRobot({Key? key}) : super(key: key);

  @override
  _AddRobotState createState() => _AddRobotState();
}

Future<Map<String, dynamic>> getLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? '';
  return {'isLoggedIn': isLoggedIn, 'username': username};
}

class _AddRobotState extends State<addRobot> {
  final TextEditingController _serialController = TextEditingController();
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final loginState = await getLoginState();
    setState(() {
      username = loginState['username'];
    });
  }

  Future<void> _robotEnroll(BuildContext context) async {
    final String serial = _serialController.text;
    final String url;

    if (Platform.isAndroid) {
      url = 'http://10.0.2.2/update/addRobot';
    } else if (Platform.isIOS) {
      url = 'http://127.0.0.1/update/addRobot';
    } else {
      throw UnsupportedError('지원되지 않는 환경입니다.');
    }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'serial': serial,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '로봇 등록에 성공하였습니다!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '로봇 정보를 불러오는데 실패했습니다',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "로봇 추가",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  controller: _serialController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "시리얼 넘버 입력",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _robotEnroll(context);
                Navigator.pushNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 0, 0, 0),
                backgroundColor: Color.fromARGB(255, 140, 79, 255),
                shadowColor: Color.fromARGB(0, 43, 0, 81),
                elevation: 5.0,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                " 로봇 추가 ",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          ],
        ),
      ),
    );
  }
}
