import 'package:flutter/material.dart';
import 'package:myapps/main.dart';
import 'package:myapps/pages/loading_Screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:myapps/security/confAPI.dart';
import 'package:myapps/main.dart' as getFCMtoken;

import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login(String id, String pass, String fcm) async {
    final String url;

    url = getApiUrl('/select/login');

    // if (Platform.isAndroid) {
    //   url = 'http://10.0.2.2/select/login';
    // } else if (Platform.isIOS) {
    //   url = 'http://127.0.0.1/select/login';
    // } else {
    //   throw UnsupportedError('지원되지 않는 환경입니다.');
    // }

    final headers = {
      'Content-Type': 'application/json',
    };

    final bodyData = jsonEncode({
      'id': id,
      'password': pass,
      'fcm_token': fcm,
    });

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyData,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        await saveLoginState(
            true,
            responseData['userEmail'],
            responseData['userName'],
            responseData['userPhone'],
            responseData['userOrganization']);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (Route<dynamic> route) => false,
        );
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: '로그인 실패',
            text: response.body,
            confirmBtnText: "닫기");
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoading = false;
      });
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: '이런..',
          text: '로그인을 하는 도중 오류가 생겼습니다. 다시 시도해주세요.',
          confirmBtnText: '닫기');
    }
  }

  Future<void> saveLoginState(bool isLoggedIn, String U_email, String U_name,
      String U_phone, int U_organization) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('user_email', U_email);
    await prefs.setString('user_name', U_name);
    await prefs.setString('user_phone', U_phone);
    await prefs.setInt('user_organization', U_organization);
    await prefs.setBool('isNotiState', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(""),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: LoadingScreen(
                  text: '로그인 하는중',
                ))
              : Center(
                  child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "로그인",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "이메일",
                            prefixIcon: Icon(Icons.email),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "비밀번호",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final email = _emailController.text;
                          final password = _passwordController.text;
                          login(email, password, getFCMtoken.FCM_TOKEN);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: Color.fromARGB(255, 140, 79, 255),
                          shadowColor: Color.fromARGB(0, 43, 0, 81),
                          elevation: 5.0,
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.35,
                              right: MediaQuery.of(context).size.width * 0.35,
                              top: 20,
                              bottom: 20),
                          side: BorderSide(
                            color: Color.fromARGB(255, 168, 121, 255),
                            width: 4.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          "    로그인    ",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login/signup');
                        },
                        child: Text(
                          "계정이 없나요?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.underline, // 밑줄 추가
                          ),
                        ),
                      )
                    ],
                  ),
                )),
        ));
  }
}
