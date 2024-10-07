import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myapps/pages/loading_Screen.dart';
import 'package:myapps/security/confAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final useremail = prefs.getString('user_email') ?? '';
  return {'isLoggedIn': isLoggedIn, 'user_email': useremail};
}

String errorMessage = "";

Future<List<Map<String, String>>> getRobots(String username) async {
  final String url;
  url = getApiUrl('/select/robots');
  // if (Platform.isAndroid) {
  //   url = 'http://10.0.2.2/select/robots';
  // } else if (Platform.isIOS) {
  //   url = 'http://127.0.0.1/select/robots';
  // } else {
  //   throw UnsupportedError('지원되지 않는 환경입니다.');
  // }

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, String>> robots = data
          .map<Map<String, String>>((item) => {
                'name': item['ro_name'] as String,
                'serial': item['ro_serial'] as String,
                'status': item['ro_status'] as String,
                'battery': item['ro_battery'].toString(),
              })
          .toList();
      return robots;
    } else {
      final dynamic jsonData = jsonDecode(response.body);
      errorMessage = jsonData['message'] ?? '로봇을 불러오는데 실패했습니다.';
      throw Exception(errorMessage);
    }
  } catch (e) {
    throw Exception("Error : $e");
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> robots = [];
  bool isLoggedIn = false;
  String username = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final loginState = await getLoginState();
    setState(() {
      isLoggedIn = loginState['isLoggedIn'];
      username = loginState['user_email'];
      if (isLoggedIn) {
        _fetchRobots();
      } else {
        isLoading = false;
      }
    });
  }

  Future<void> _fetchRobots() async {
    setState(() {
      isLoading = true;
    });

    try {
      final robotsData = await getRobots(username);
      setState(() {
        robots = robotsData;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'API서버와 연결할 수 없습니다';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchRobots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      body: isLoggedIn
          ? isLoading
              ? Center(
                  child: LoadingScreen(
                  text: '로봇 불러오는중',
                ))
              : robots.isEmpty
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 140, 79, 255), // 배경색
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 6), // 그림자 위치 조정
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded, // 네트워크 연결 실패 아이콘
                              size: 50,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              errorMessage,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: Center(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // 로봇 카드들을 리스트로 보여줌
                                ...robots.map((robot) {
                                  return RobotCard(
                                    robotName: robot['name']!,
                                    batteryLevel: robot['battery']!,
                                    status: robot['status']!,
                                    serial: robot['serial']!,
                                  );
                                }).toList(),
                                // 마지막에 추가 카드
                                build_add_card(context), // context 제거
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
          : Center(
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
  }
}

/*=============================================*/
/*================[ RobotCard }================*/
/*=============================================*/
class RobotCard extends StatelessWidget {
  final String robotName;
  final String batteryLevel;
  final String status;
  final String serial;

  RobotCard({
    required this.robotName,
    required this.batteryLevel,
    required this.status,
    required this.serial,
  });

  // 배터리 수준에 따른 아이콘 반환
  IconData _getBatteryIcon() {
    final int level = int.tryParse(batteryLevel) ?? 0;

    if (level >= 100) {
      return Icons.battery_full_rounded;
    } else if (level >= 80) {
      return Icons.battery_6_bar_rounded;
    } else if (level >= 60) {
      return Icons.battery_5_bar_rounded;
    } else if (level >= 50) {
      return Icons.battery_4_bar_rounded;
    } else if (level >= 30) {
      return Icons.battery_3_bar_rounded;
    } else if (level >= 20) {
      return Icons.battery_2_bar_rounded;
    } else if (level >= 10) {
      return Icons.battery_1_bar_rounded;
    } else if (level >= 0) {
      return Icons.battery_0_bar_rounded;
    } else {
      return Icons.battery_alert;
    }
  }

  Color _getBatteryColor() {
    final int level = int.tryParse(batteryLevel) ?? 0;
    if (level >= 80) {
      return Colors.green;
    } else if (level >= 60) {
      final double factor = (level - 60) / 20;
      return Color.lerp(Colors.yellow, Colors.green, factor)!;
    } else if (level >= 30) {
      final double factor = (level - 30) / 30;
      return Color.lerp(Colors.orange, Colors.yellow, factor)!;
    } else {
      final double factor = level / 30;
      return Color.lerp(Colors.red, Colors.orange, factor)!;
    }
  }

  String _ChangeStringOfStatus(String status) {
    String displayStatus = status == "off" ? "비활성화" : "활성화";
    return displayStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      elevation: 5.0,
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/robot_details',
            arguments: {
              'serial': serial,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/icon.png',
                width: 80,
                height: 80,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      robotName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(children: [
                          Text(
                            '$batteryLevel%',
                            style: TextStyle(fontSize: 13),
                          ),
                          Transform.rotate(
                            angle: 1.5708,
                            child: Icon(
                              _getBatteryIcon(),
                              color: _getBatteryColor(),
                            ),
                          ),
                        ]),
                        SizedBox(width: 4),
                        Text(
                          '상태 : ' + _ChangeStringOfStatus(status),
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget build_add_card(context) {
  return Card(
    color: Color.fromARGB(255, 255, 255, 255),
    elevation: 5.0,
    shadowColor: Colors.black,
    margin: const EdgeInsets.all(8.0),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/addRobot');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 80,
            height: 40,
            child: Center(
              child: Icon(
                Icons.add_rounded, // + 모양의 아이콘
                size: 35, // 아이콘 크기 조정
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
