import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String text;

  LoadingScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Image.asset(
              'assets/haesil_loading.gif', // 로딩 GIF 파일의 경로
              width: 200, // GIF의 너비 조절
              height: 200, // GIF의 높이 조절
            ),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
