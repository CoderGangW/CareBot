import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'dart:convert';
import 'package:myapps/security/confAPI.dart';
import 'package:myapps/main.dart';
import 'package:myapps/pages/searchOrganization_Page.dart';
import 'package:myapps/pages/terms_page.dart'; // 약관 페이지 import
import 'loading_Screen.dart';

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
  bool _isTermsChecked = false;

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

    final String url;
    url = getApiUrl('/insert/signup');

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
    }
  }

  void _validateEmail(String value) {
    final pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    setState(() {
      _isEmailValid = RegExp(pattern).hasMatch(value);
    });
  }

  void _validatePasswordMatch(String value) {
    setState(() {
      _isPasswordMatched = value == _passwordController.text;
    });
  }

  void _validatePhone(String value) {
    final pattern = r'^\d{3}-\d{4}-\d{4}$';
    setState(() {
      _isPhoneValid = RegExp(pattern).hasMatch(value);
    });
  }

  Future<void> _showTermsPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsPage(onAgree: () {
          setState(() {
            _isTermsChecked = true;
          });
        }),
      ),
    );

    if (result != true) {
      setState(() {
        _isTermsChecked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double BtnWidth = MediaQuery.of(context).size.width * 0.2;
    final double BtnHeight = MediaQuery.of(context).size.height * 0.02;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "회원가입",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? LoadingScreen()
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildTextFormField(
                              _nameController, "이름", "이름을 입력해주세요."),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            _emailController,
                            "이메일",
                            "이메일을 입력해주세요.",
                            onChanged: _validateEmail,
                            errorText:
                                _isEmailValid ? null : '유효한 이메일 주소를 입력해주세요.',
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            _passwordController,
                            "비밀번호",
                            "비밀번호를 입력해주세요.",
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return '비밀번호를 입력해주세요.';
                              if (value.length < 8)
                                return '비밀번호는 최소 8자리여야 합니다.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            _confirmPasswordController,
                            "비밀번호 확인",
                            "비밀번호 확인을 입력해주세요.",
                            obscureText: true,
                            onChanged: _validatePasswordMatch,
                            errorText:
                                _isPasswordMatched ? null : '비밀번호가 일치하지 않습니다.',
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            _phoneController,
                            "핸드폰 번호",
                            "핸드폰 번호를 입력해주세요.",
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              MultiMaskedTextInputFormatter(
                                  masks: ['xxx-xxxx-xxxx'], separator: '-')
                            ],
                            onChanged: _validatePhone,
                            errorText: _isPhoneValid
                                ? null
                                : '유효한 핸드폰 번호를 입력해주세요. (010-1234-5678)',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _organizationController,
                            readOnly: true,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchOrganizationPage(),
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
                              if (value == null || value.isEmpty)
                                return '소속을 선택해주세요.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          CheckboxListTile(
                            title: Text("이용 약관에 동의합니다."),
                            value: _isTermsChecked,
                            onChanged: (bool? value) {
                              if (value == true) {
                                _showTermsPage();
                              } else {
                                setState(() {
                                  _isTermsChecked = false;
                                });
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isTermsChecked ? signUp : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 0, 0, 0),
                              backgroundColor:
                                  Color.fromARGB(255, 140, 79, 255),
                              shadowColor: Color.fromARGB(255, 43, 0, 81),
                              elevation: 10.0,
                              padding: EdgeInsets.only(
                                left: BtnWidth,
                                right: BtnWidth,
                                top: BtnHeight,
                                bottom: BtnHeight,
                              ),
                              side: BorderSide(
                                color: Color.fromARGB(255, 155, 101, 255),
                                width: 4.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text("   가입하기   ",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText, String hintText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters,
      Function(String)? onChanged,
      String? errorText,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(),
        errorText: errorText,
      ),
      validator: validator,
    );
  }
}
