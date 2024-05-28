import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapps/pages/searchOrganization_Page.dart';
import 'package:http/http.dart' as http;
import 'package:myapps/security/confAPI.dart';
import 'dart:convert';
import 'loading_Screen.dart';
import 'package:myapps/main.dart';
import 'package:quickalert/quickalert.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';

class signupPage extends StatefulWidget {
  const signupPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<signupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  String? _organizationId;
  bool _isLoading = false;
  bool _isEmailValid = true;
  bool _isPasswordMatched = true;
  bool _isPhoneValid = true;

  void signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final phone = _phoneController.text;
    final token = FCM_TOKEN;
    final facility = _organizationId ?? '';

    final String url = getApiUrl('/insert/signup');
    // String url;
    // if (Platform.isAndroid) {
    //   url = 'http://10.0.2.2/insert/signup';
    // } else if (Platform.isIOS) {
    //   url = 'http://127.0.0.1/insert/signup';
    // } else {
    //   throw UnsupportedError('지원되지 않는 환경입니다.');
    // }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'token': token,
        'facility': facility,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      print('User registered successfully');
      Navigator.pushNamed(context, '/login');
    } else if (response.statusCode == 409) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "이미 존재하는 이메일입니다",
        confirmBtnText: "닫기",
        confirmBtnColor: Colors.deepPurple,
        animType: QuickAlertAnimType.slideInUp,
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "문제가 생긴것 같습니다",
        text: "알수없는 오류로 인해 정상적으로 가입되지 않았습니다.",
        confirmBtnText: "닫기",
        confirmBtnColor: Colors.deepPurple,
        animType: QuickAlertAnimType.slideInUp,
      );
      print('Failed to register user: ${response.body}');
    }
  }

  void _validateEmail(String value) {
    String pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    RegExp regex = RegExp(pattern);
    setState(() {
      _isEmailValid = regex.hasMatch(value);
    });
  }

  void _validatePasswordMatch(String value) {
    setState(() {
      _isPasswordMatched = value == _passwordController.text;
    });
  }

  void _validatePhone(String value) {
    String pattern = r'^\d{3}-\d{4}-\d{4}$';
    RegExp regex = RegExp(pattern);
    setState(() {
      _isPhoneValid = regex.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingScreen()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                "회원가입",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "이름",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "이메일",
                        border: OutlineInputBorder(),
                        errorText: _isEmailValid ? null : '유효한 이메일 주소를 입력해주세요.',
                      ),
                      onChanged: _validateEmail,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요.';
                        }
                        if (!_isEmailValid) {
                          return '유효한 이메일 주소를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        }
                        if (value.length < 12) {
                          return '비밀번호는 최소 12자리여야 합니다.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "비밀번호 확인",
                        border: OutlineInputBorder(),
                        errorText:
                            _isPasswordMatched ? null : '비밀번호가 일치하지 않습니다.',
                      ),
                      onChanged: _validatePasswordMatch,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요.';
                        }
                        if (!_isPasswordMatched) {
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      inputFormatters: [
                        MultiMaskedTextInputFormatter(
                            masks: ['xxx-xxxx-xxxx'], separator: '-')
                      ],
                      keyboardType: TextInputType.number,
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "핸드폰 번호",
                        border: OutlineInputBorder(),
                        errorText: _isPhoneValid
                            ? null
                            : '유효한 핸드폰 번호를 입력해주세요. (010-1234-5678)',
                      ),
                      onChanged: _validatePhone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '핸드폰 번호를 입력해주세요.';
                        }
                        if (!_isPhoneValid) {
                          return '유효한 핸드폰 번호를 입력해주세요. (010-1234-5678)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _organizationController,
                      readOnly: true,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchOrganizationPage(),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _organizationController.text = result['name'];
                            _organizationId = result['id'];
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "소속",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '소속을 선택해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: signUp,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          "가입하기",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
