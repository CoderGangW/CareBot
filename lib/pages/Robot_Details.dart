import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapps/security/confAPI.dart';

class robotdetails extends StatefulWidget {
  const robotdetails({Key? key}) : super(key: key);

  @override
  _RobotDetailsState createState() => _RobotDetailsState();
}

class _RobotDetailsState extends State<robotdetails> {
  String robotName = '';
  String batteryLevel = '';
  String status = '';
  String serial = '';
  late TextEditingController _nameController;

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

      // 새로운 로봇 정보를 불러오는 메서드 호출
      _fetchRobotDetails();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _nameController.dispose(); // 컨트롤러를 해제하여 메모리 누수 방지
    }
    super.dispose();
  }

  Future<void> _fetchRobotDetails() async {
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
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          '로봇 정보를 불러오는데 실패했습니다',
          textAlign: TextAlign.center,
        )),
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
      body: jsonEncode(<String, String>{
        'name': robotName,
        'serial': serial,
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        // 이 부분에서 mounted 체크 추가
        setState(() {
          robotName = _nameController.text;
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

  @override
  Widget build(BuildContext context) {
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
                Text(
                  textAlign: TextAlign.center,
                  robotName,
                ),
                Icon(Icons.create_rounded)
              ],
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                  '로봇 시리얼 : $serial',
                  textAlign: TextAlign.center,
                )),
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
                minScale: 0.5,
                maxScale: 2.0,
                child: Image.network(
                  'https://kr.mathworks.com/discovery/slam/_jcr_content/mainParsys/band_1231704498_copy/mainParsys/lockedsubnav/mainParsys/columns_39110516/6046ff86-c275-45cd-87bc-214e8abacb7c/columns_463008322/7b029c5b-9826-4f96-b230-9a6ec96cb4ab/columns_1472205090/bd4f8030-3567-47ae-b28f-3d4ac2e33131/image_1721175736_cop.adapt.full.medium.jpg/1715236365556.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  // 활동 추가 버튼 클릭 시 동작할 내용
                },
                child: Text('활동 추가'),
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

    Color _getStatusColor(String status) {
      if (status == '활성화') {
        return Colors.green;
      } else if (status == '비활성화') {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(width: 5), // 아이콘과 텍스트 사이에 간격 추가
                Transform.rotate(
                  angle: 0, // 각도 설정
                  child: Icon(
                    _getStatusIcon(value),
                    color: _getStatusColor(value),
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ],
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

    Color _getBatteryColor() {
      final int level = int.tryParse(value) ?? 0;

      if (level >= 80) {
        return Colors.green;
      } else if (level >= 60) {
        return Colors.lightGreen;
      } else if (level >= 40) {
        return Colors.yellow;
      } else if (level >= 20) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value + "%",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(width: 5), // 아이콘과 텍스트 사이에 간격 추가
                Transform.rotate(
                  angle: 1.5708,
                  child: Icon(
                    _getBatteryIcon(),
                    color: _getBatteryColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
