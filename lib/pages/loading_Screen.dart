import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Image.asset(
              'assets/haesil_loading.gif', // 로딩 GIF 파일의 경로
              width: 200, // GIF의 너비 조절
              height: 200, // GIF의 높이 조절
            ),
          ),
          Text(
            '정보 불러오는중..',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Spacer()
        ],
      ),
    );
  }
}
