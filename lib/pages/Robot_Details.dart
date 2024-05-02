import 'package:flutter/material.dart';

class robotdetails extends StatelessWidget {
  const robotdetails({super.key});

  @override
  Widget build(BuildContext context) {
    // 여기에 로봇의 세부 정보를 보여주는 UI를 작성해주세요.
    final String? robotName = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text("$robotName"),
      ),
      body: Center(
        child: Text('로봇 세부 정보 페이지'),
      ),
    );
  }
}
