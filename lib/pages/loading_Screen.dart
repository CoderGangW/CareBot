import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/haesil_loading.gif', // 로딩 GIF 파일의 경로
          width: 180, // GIF의 너비 조절
          height: 180, // GIF의 높이 조절
        ),
      ),
    );
  }
}
