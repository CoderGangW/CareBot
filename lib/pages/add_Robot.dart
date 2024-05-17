import 'package:flutter/material.dart';

class addRobot extends StatelessWidget {
  const addRobot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "로봇 추가",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "시리얼 넘버입력"),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
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
                    title: Text("API 연결 필요"),
                    content: Text("API서버와의 연결이 되지 않았습니다."),
                  ),
                );
              },
              child: Text("로봇 추가"),
            )
          ],
        )));
  }
}
