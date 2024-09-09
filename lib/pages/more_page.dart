import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:myapps/main.dart' as user;
import 'package:shared_preferences/shared_preferences.dart';

const appVersion = "Alpha 2.1.0";

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  String _loggedInUser = "";
  bool _isLoggedIn = false;
  bool _isNotiState = true;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              List<IconData> li_Icon = [
                Icons.add,
                Icons.settings_outlined,
                Icons.article_outlined,
              ];
              const li_btnTitle = ["로봇 추가", "로봇 관리", "로봇 사용법"];
              const li_ctsTitle = ["개발중", "개발중", "요로코롬"];
              const li_ctsSubTitle = [
                "기능이 완성되지 않았습니다!",
                "기능이 완성되지 않았습니다!",
                "이러케 저러케"
              ];
              return _buildButton_myrobot(context, index, li_Icon, li_btnTitle,
                  li_ctsTitle, li_ctsSubTitle);
            },
          ),
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
              onPressed: () {
                setState(() async {
                  _isNotiState = !_isNotiState;
                  if (_isNotiState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color.fromARGB(255, 136, 255, 128),
                        duration: const Duration(milliseconds: 500),
                        content: Text(
                          '알림을 받습니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color.fromARGB(255, 255, 128, 128),
                        duration: const Duration(milliseconds: 500),
                        content: Text(
                          '알림을 받지 않습니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isNotiState', _isNotiState);
                });
              },
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
                  onChanged: (bool value) {
                    setState(() async {
                      _isNotiState = value;
                      if (_isNotiState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color.fromARGB(255, 136, 255, 128),
                            duration: const Duration(milliseconds: 500),
                            content: Text(
                              '알림을 받습니다!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color.fromARGB(255, 255, 128, 128),
                            duration: const Duration(milliseconds: 500),
                            content: Text(
                              '알림을 받지 않습니다!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isNotiState', _isNotiState);
                    });
                  },
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              List<IconData> li_Icon = [
                Icons.campaign_outlined,
                Icons.assignment_ind_outlined,
              ];
              const li_btnTitle = ["우리의 목표", "개발자 소개"];
              const li_ctsTitle = ["해피 실버 데이", "강윤원"];
              const li_ctsSubTitle = ["행복한 노년생활!", "살려줘..."];
              return _buildButton_appinfo(context, index, li_Icon, li_btnTitle,
                  li_ctsTitle, li_ctsSubTitle);
            },
          ),
          SizedBox(
            height: 30,
          ),
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
    ));
  }

  Widget _buildButton_myrobot(BuildContext context, int index,
      List<IconData> iconList, List btnTitle, List ctsTitle, List ctsSubTitle) {
    if (!_isLoggedIn && index == 0) {
      return SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            if (index == 0) {
              Navigator.pushNamed(context, "/addRobot");
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('닫기'),
                    )
                  ],
                  title: Text(ctsTitle[index]),
                  content: Text(ctsSubTitle[index]),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
          ),
          child: ListTile(
              leading: Icon(iconList[index]), title: Text(btnTitle[index])),
        ),
      );
    }
  }

  Widget _buildButton_appinfo(BuildContext context, int index,
      List<IconData> iconList, List btnTitle, List ctsTitle, List ctsSubTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('닫기'),
                )
              ],
              title: Text(ctsTitle[index]),
              content: Text(ctsSubTitle[index]),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
        ),
        child: ListTile(
            leading: Icon(iconList[index]), title: Text(btnTitle[index])),
      ),
    );
  }

  void _showLogoutDialog() {
    showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: Text("로그아웃 하시겠습니까?"),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("취소"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          BasicDialogAction(
            title: Text("로그아웃"),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
