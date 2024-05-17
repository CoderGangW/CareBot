import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> APIforLogin(String id, String pass) async {
  final url = 'YOUR_API_ENDPOINT_HERE'; // 여기에 API 서버의 엔드포인트 URL을 입력하세요.

  final headers = {
    'Content-Type': 'application/json',
  };

  final bodyData = jsonEncode({
    'title': id,
    'body': pass,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: bodyData,
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

class loginPage extends StatelessWidget {
  const loginPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "로그인",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "계정ID",
                  labelText: "계정ID",
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "비밀번호",
                  labelText: "비밀번호",
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: "연결이 끊겨있습니다.",
                  text: "API서버와의 연결이 필요합니다",
                  confirmBtnText: "닫기",
                  animType: QuickAlertAnimType.slideInUp,
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "로그인",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login/signup');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  "회원가입",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
