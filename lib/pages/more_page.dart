import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:myapps/main.dart' as user;
import 'package:shared_preferences/shared_preferences.dart';

const appVersion = "Alpha 2.2.0";

class ButtonData {
  final IconData icon;
  final String title;
  final String contentTitle;
  final String contentSubtitle;
  final Function(BuildContext) onPressed;

  ButtonData({
    required this.icon,
    required this.title,
    required this.contentTitle,
    required this.contentSubtitle,
    required this.onPressed,
  });
}

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  String _loggedInUser = "";
  bool _isLoggedIn = false;
  bool _isNotiState = true;

  late List<ButtonData> _myRobotButtons;
  late List<ButtonData> _appInfoButtons;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
    _initializeButtons();
  }

  void _initializeButtons() {
    _myRobotButtons = [
      ButtonData(
        icon: Icons.add,
        title: "로봇 추가",
        contentTitle: "개발중",
        contentSubtitle: "기능이 완성되지 않았습니다!",
        onPressed: (context) => Navigator.pushNamed(context, "/addRobot"),
      ),
      ButtonData(
        icon: Icons.settings_outlined,
        title: "로봇 관리",
        contentTitle: "개발중",
        contentSubtitle: "기능이 완성되지 않았습니다!",
        onPressed: _showDefaultDialog,
      ),
      ButtonData(
        icon: Icons.article_outlined,
        title: "로봇 사용법",
        contentTitle: "요로코롬",
        contentSubtitle: "이러케 저러케",
        onPressed: _showDefaultDialog,
      ),
    ];

    _appInfoButtons = [
      ButtonData(
        icon: Icons.campaign_outlined,
        title: "우리의 목표",
        contentTitle: "해피 실버 데이",
        contentSubtitle: "행복한 노년생활!",
        onPressed: (context) => Navigator.pushNamed(context, "/goal"),
      ),
      ButtonData(
        icon: Icons.assignment_ind_outlined,
        title: "개발자 소개",
        contentTitle: "강윤원",
        contentSubtitle: "살려줘...",
        onPressed: (context) => Navigator.pushNamed(context, "/intro-dev"),
      ),
    ];
  }

  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUser = prefs.getString('user_name') ?? "";
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _isNotiState = prefs.getBool('isNotiState') ?? true;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('username', "");
    setState(() {
      _loggedInUser = "";
      _isLoggedIn = false;
    });
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showDefaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("알림"),
        content: Text("이 기능은 아직 개발 중입니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _toggleNotification() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotiState = !_isNotiState;
      _showNotificationSnackBar();
    });
    await prefs.setBool('isNotiState', _isNotiState);
  }

  void _showNotificationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isNotiState
            ? Color.fromARGB(255, 136, 255, 128)
            : Color.fromARGB(255, 255, 128, 128),
        duration: const Duration(milliseconds: 500),
        content: Text(
          _isNotiState ? '알림을 받습니다!' : '알림을 받지 않습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildButton(ButtonData data) {
    if (!_isLoggedIn && data.title == "로봇 추가") {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => data.onPressed(context),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        ),
        child: ListTile(
          leading: Icon(data.icon),
          title: Text(data.title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 50),
            InkWell(
              onTap: () {
                if (!_isLoggedIn) {
                  Navigator.pushNamed(context, '/login');
                } else {
                  Navigator.pushNamed(context, '/account');
                }
              },
              customBorder: CircleBorder(),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurpleAccent,
                child: CircleAvatar(
                  radius: 47,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/usericon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _loggedInUser.isEmpty ? "로그인" : _loggedInUser,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '내 로봇',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
            ..._myRobotButtons.map(_buildButton),
            SizedBox(height: 20),
            Text(
              '앱 정보',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: _toggleNotification,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text("알림설정"),
                  trailing: Switch.adaptive(
                    activeColor: Colors.deepPurple,
                    value: _isNotiState,
                    onChanged: (bool value) => _toggleNotification(),
                  ),
                ),
              ),
            ),
            ..._appInfoButtons.map(_buildButton),
            SizedBox(height: 30),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("앱 버전"),
                  Text(appVersion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
