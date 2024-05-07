import 'package:flutter/material.dart';

final List<Map<String, String>> robots = [
  {'name': '로봇 1', 'battery': '40', 'status': '활성'},
  {'name': '로봇 2', 'battery': '50', 'status': '비활성'},
  // 필요한 만큼 로봇 정보를 추가할 수 있습니다.
];

/*=============================================*/
/*================[ Home Page }================*/
/*=============================================*/
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: robots.map((robot) {
              return RobotCard(
                robotName: robot['name']!,
                batteryLevel: robot['battery']!,
                status: robot['status']!,
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addRobot');
        },
        tooltip: "로봇 추가",
        child: Icon(Icons.add),
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

  RobotCard({
    required this.robotName,
    required this.batteryLevel,
    required this.status,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/robot_details', arguments: robotName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/walle-eve.png',
                width: 60,
                height: 60,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 로봇 이름
                    Text(
                      robotName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // 배터리 수준 및 동작 상태
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(children: [
                          Icon(
                            _getBatteryIcon(),
                            color: Colors.grey[600],
                          ),
                          Text(
                            '$batteryLevel%',
                            style: TextStyle(fontSize: 16),
                          ),
                        ]),
                        SizedBox(width: 4),
                        Text(
                          '상태: $status',
                          style: TextStyle(fontSize: 16),
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
