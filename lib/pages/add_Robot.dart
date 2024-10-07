import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapps/security/confAPI.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddRobot extends StatefulWidget {
  const AddRobot({Key? key}) : super(key: key);

  @override
  _AddRobotState createState() => _AddRobotState();
}

Future<Map<String, dynamic>> getLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? '';
  return {'isLoggedIn': isLoggedIn, 'username': username};
}

class _AddRobotState extends State<AddRobot> with TickerProviderStateMixin {
  final TextEditingController _serialController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  String username = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoginState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    // 스케일 애니메이션 (크기 변화)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 회전 애니메이션 (약간의 3D 회전 효과)
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 위치 애니메이션 (작은 이동 효과)
    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, 0.02),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadLoginState() async {
    final loginState = await getLoginState();
    setState(() {
      username = loginState['username'];
    });
  }

  Future<void> _robotEnroll(BuildContext context) async {
    setState(() => _isLoading = true);
    final String serial = _serialController.text;
    final String url = getApiUrl('/update/addRobot');

    try {
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
            content: Text('로봇 등록에 성공하였습니다!', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushNamed(context, '/');
      } else {
        throw Exception('Failed to load robot information');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로봇 정보를 불러오는데 실패했습니다', textAlign: TextAlign.center),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "로봇 추가",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 입체적 효과를 주기 위한 ScaleTransition + RotationTransition + SlideTransition
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: _positionAnimation,
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Icon(
                          Icons.smart_toy,
                          size: 150,
                          color: Color.fromARGB(255, 140, 79, 255),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '새로운 로봇을 추가해보세요!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 140, 79, 255),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _serialController,
                    decoration: InputDecoration(
                      labelText: '시리얼 넘버',
                      hintText: "시리얼 넘버를 입력하세요",
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 140, 79, 255), width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _robotEnroll(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 140, 79, 255),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "로봇 추가",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
