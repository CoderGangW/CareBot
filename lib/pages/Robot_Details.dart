import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapps/pages/loading_Screen.dart';
import 'package:myapps/security/confAPI.dart';

class robotdetails extends StatefulWidget {
  const robotdetails({Key? key}) : super(key: key);

  @override
  _RobotDetailsState createState() => _RobotDetailsState();
}

class _RobotDetailsState extends State<robotdetails> {
  bool isLoading = true;

  String robotName = '';
  String batteryLevel = '';
  String status = '';
  String serial = '';
  late TextEditingController _nameController;
  List<Map<String, dynamic>> notifications = [];
  bool isNotificationExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, String>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      setState(() {
        serial = args['serial']!;
      });

      _fetchRobotDetails();
      _fetchNotifications();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _nameController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchRobotDetails() async {
    setState(() {
      isLoading = true; // 로딩 시작
    });
    final String url = getApiUrl('/select/robotinfo');
    // String url;
    // if (Platform.isAndroid) {
    //   url = 'http://10.0.2.2/select/robotinfo';
    // } else if (Platform.isIOS) {
    //   url = 'http://127.0.0.1/select/robotinfo';
    // } else {
    //   throw UnsupportedError('지원되지 않는 환경입니다.');
    // }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'serial': serial,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);
      final Map<String, dynamic> data = dataList.isNotEmpty ? dataList[0] : {};
      if (mounted) {
        // 이 부분에서 mounted 체크 추가
        setState(() {
          robotName = data['ro_name'] ?? '';
          batteryLevel =
              data['ro_battery'] != null ? data['ro_battery'].toString() : '';
          status = data['ro_status'] == "off" ? "비활성화" : "활성화";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false; // 로딩 끝
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          '로봇 정보를 불러오는데 실패했습니다',
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    final String url = getApiUrl('/select/robot-notification');

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'roserial': serial,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          notifications = dataList.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      }
    } else if (jsonDecode(response.body)['code'] == 'NF_NOTI') {
      setState(() {
        notifications = [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false; // 로딩 끝
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('알림을 불러오는데 실패했습니다', textAlign: TextAlign.center)),
      );
    }
  }

  Future<void> _updateRobotDetails() async {
    final String url;

    url = getApiUrl('/update/robotname');

    // if (Platform.isAndroid) {
    //   url = 'http://10.0.2.2/update/robotname';
    // } else if (Platform.isIOS) {
    //   url = 'http://127.0.0.1/update/robotname';
    // } else {
    //   throw UnsupportedError('지원되지 않는 환경입니다.');
    // }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'name': robotName, 'serial': serial}),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        // 이 부분에서 mounted 체크 추가
        setState(() {
          robotName = _nameController.text;
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          '로봇 정보가 업데이트되었습니다!',
          textAlign: TextAlign.center,
        )),
      );
      await _fetchRobotDetails(); // 업데이트 후 새로운 로봇 정보 불러오기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          '로봇 정보 업데이트에 실패했습니다',
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  void _showEditDialog() {
    if (mounted) {
      setState(() {
        _nameController.text = robotName;
        isLoading = false;
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('로봇 이름 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '로봇 이름'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  robotName = _nameController.text;
                });
                _updateRobotDetails();
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: GestureDetector(
            onTap: _showEditDialog,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(robotName, textAlign: TextAlign.center),
                Icon(Icons.create_rounded)
              ],
            )),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info,
              color: Colors.grey,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('로봇 시리얼 : $serial', textAlign: TextAlign.center)),
              );
            },
            tooltip: '로봇 정보',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20),
                scaleEnabled: true,
                panEnabled: true,
                child: Image.network(
                  'https://kr.mathworks.com/discovery/slam/_jcr_content/mainParsys/band_1231704498_copy/mainParsys/lockedsubnav/mainParsys/columns_39110516/6046ff86-c275-45cd-87bc-214e8abacb7c/columns_463008322/7b029c5b-9826-4f96-b230-9a6ec96cb4ab/columns_1472205090/bd4f8030-3567-47ae-b28f-3d4ac2e33131/image_1721175736_cop.adapt.full.medium.jpg/1715236365556.jpg',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Text('이미지를 불러올 수 없습니다'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildBatteryCard('배터리 상태', batteryLevel),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildStatusCard('활성화 상태', status),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  // 활동 추가 버튼 클릭 시 동작할 내용
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 90, 181, 255),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 10),
                    Text('활동 추가', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  // 장소 추가 버튼 클릭 시 동작할 내용
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place_outlined),
                    SizedBox(width: 10),
                    Text('장소 추가', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildNotificationsSection(),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value) {
    IconData _getStatusIcon(String status) {
      if (status == '활성화') {
        return Icons.play_arrow_rounded;
      } else if (status == '비활성화') {
        return Icons.pause_rounded;
      } else {
        return Icons.help;
      }
    }

    LinearGradient _getStatusGradient(String status) {
      if (status == '활성화') {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade300, Colors.green.shade700],
        );
      } else if (status == '비활성화') {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade300, Colors.red.shade700],
        );
      } else {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade300, Colors.grey.shade700],
        );
      }
    }

    return Container(
      width: 160,
      height: 140,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: _getStatusGradient(value),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Icon(
                      _getStatusIcon(value),
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryCard(String title, String value) {
    IconData _getBatteryIcon() {
      final int level = int.tryParse(value) ?? 0;
      if (level >= 100) {
        return Icons.battery_full_rounded;
      } else if (level >= 80) {
        return Icons.battery_6_bar_rounded;
      } else if (level >= 60) {
        return Icons.battery_5_bar_rounded;
      } else if (level >= 40) {
        return Icons.battery_4_bar_rounded;
      } else if (level >= 20) {
        return Icons.battery_2_bar_rounded;
      } else {
        return Icons.battery_alert_rounded;
      }
    }

    LinearGradient _getBatteryGradient() {
      final int level = int.tryParse(value) ?? 0;
      if (level >= 80) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade300, Colors.green.shade700],
        );
      } else if (level >= 60) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.lightGreen.shade300, Colors.lightGreen.shade700],
        );
      } else if (level >= 40) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.yellow.shade300, Colors.yellow.shade700],
        );
      } else if (level >= 20) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade300, Colors.orange.shade700],
        );
      } else {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade300, Colors.red.shade700],
        );
      }
    }

    return Container(
      width: 160,
      height: 140,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: _getBatteryGradient(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$value%",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Transform.rotate(
                      angle: 1.5708, // 90도 회전
                      child: Icon(
                        _getBatteryIcon(),
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Card(
        child: ExpansionTile(
          title: Text('${robotName}의 알림',
              style: TextStyle(fontWeight: FontWeight.bold)),
          children: notifications.isEmpty
              ? [
                  // 알림이 없을 때 표시할 메시지
                  ListTile(
                    title: Text(
                      "최근 1시간 동안의 기록이 없습니다",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                ]
              : notifications.map((notification) {
                  return ListTile(
                    title: Text(notification['no_title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['no_contents']),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(
                              DateTime.parse(notification['time_stamp'])),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    leading: Icon(
                      Icons.notification_important,
                      color: Colors.red,
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}
