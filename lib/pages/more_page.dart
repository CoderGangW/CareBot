import 'package:flutter/material.dart';

import 'package:myapps/main.dart' as user;

/*=============================================*/
/*================[ More Page }================*/
/*=============================================*/

var loginState = true;

var appVersion = "Alpha 1.0.0";

String _LoggedInUser = user.username;

final String name = _LoggedInUser == "" ? "로그인을 해주세요" : _LoggedInUser;

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 50),
          InkWell(
            onTap: () {
              print(name);
              _LoggedInUser == ""
                  ? Navigator.pushNamed(context, '/login')
                  : Navigator.pushNamed(context, '/account');
            },
            customBorder: CircleBorder(),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurpleAccent,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/walle-eve.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
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
              return _buildButton(context, index, li_Icon, li_btnTitle,
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              List<IconData> li_Icon = [
                Icons.notifications_outlined,
                Icons.campaign_outlined,
                Icons.assignment_ind_outlined,
              ];
              const li_btnTitle = ["알림 설정", "우리의 목표", "개발자 소개"];
              const li_ctsTitle = ["FireBase 연동", "해피 실버 데이", "강윤원"];
              const li_ctsSubTitle = ["FCM토큰 받아 연동하기", "행복한 노년생활!", "살려줘..."];
              return _buildButton(context, index, li_Icon, li_btnTitle,
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
    );
  }

  Widget _buildButton(BuildContext context, int index, List<IconData> iconList,
      List btnTitle, List ctsTitle, List ctsSubTitle) {
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
          shadowColor: Colors.white,
        ),
        child: ListTile(
            leading: Icon(iconList[index]), title: Text(btnTitle[index])),
      ),
    );
  }
}
