import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/utils.dart';
import 'package:myapps/pages/home_page.dart';
import 'package:myapps/pages/loginPage.dart';
import 'package:myapps/security/confAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'loading_Screen.dart';
import 'package:flutter/services.dart';

class accountPage extends StatelessWidget {
  const accountPage({Key? key}) : super(key: key);

  Future<Map<String, String?>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');
    String? userName = prefs.getString('user_name');
    String? userPhone = prefs.getString('user_phone');
    String? facilityId = prefs.getInt('user_organization')?.toString();
    Map? organization =
        facilityId != null ? await facilityInfo(facilityId) : null;

    print(organization);

    return {
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'userOrganization-name': organization?['facilityName'],
      'userOrganization-phone': organization?['facilityPhone'],
      'userOrganization-Address': organization?['facilityAddress'],
    };
  }

  Future<Map?> facilityInfo(String facilityID) async {
    final String url;

    url = getApiUrl('/select/user-facility');

    // if (Platform.isAndroid) {
    //   url = 'http://10.0.2.2/select/user-facility';
    // } else if (Platform.isIOS) {
    //   url = 'http://127.0.0.1/select/user-facility';
    // } else {
    //   throw UnsupportedError('지원되지 않는 환경입니다.');
    // }

    final headers = {
      'Content-Type': 'application/json',
    };

    final bodyData = jsonEncode({'fa_id': facilityID});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyData,
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, String?>>(
        future: getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingScreen());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          var userInfo = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    "assets/HAESILE_Thumnail.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard_normal(
                        icon: Icons.account_box_rounded,
                        title: '이름',
                        content: userInfo['userName'] ?? '사용자 이름 없음',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      _buildInfoCard_normal(
                        icon: Icons.email,
                        title: '이메일',
                        content: userInfo['userEmail'] ?? '이메일 없음',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard_normal(
                        icon: Icons.contact_phone,
                        title: '전화번호',
                        content: userInfo['userPhone'] ?? '전화번호 없음',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                          icon: Icons.business,
                          title: '소속',
                          content:
                              userInfo['userOrganization-name'] ?? '조직 정보 없음',
                          subContent_phone:
                              userInfo['userOrganization-phone'] ?? '전화번호 없음',
                          subContent_location:
                              userInfo['userOrganization-Address'] ?? '위치정보 없음',
                          context: context),
                      SizedBox(height: 16),
                      _buildAccountConf(),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (Route<dynamic> route) => false,
                            );
                          },
                          icon: Icon(Icons.logout),
                          label: Text(
                            '로그아웃',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountConf() {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.settings,
                size: 28, color: Color.fromARGB(255, 147, 65, 255)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '계정 설정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        children: [
          Column(
            children: [],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String content,
      required String subContent_phone,
      required String subContent_location,
      required context}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, size: 28, color: Color.fromARGB(255, 147, 65, 255)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.phone_enabled_outlined,
                    size: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      // 전화번호를 클립보드에 복사하는 기능
                      Clipboard.setData(ClipboardData(text: subContent_phone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '전화번호가 클립보드에 복사되었습니다',
                            textAlign: TextAlign.center,
                          ),
                          duration: Durations.extralong1,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        subContent_phone,
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(
                                255, 33, 114, 243)), // 클릭할 수 있도록 색상 추가
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      subContent_location,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard_normal(
      {required IconData icon,
      required String title,
      required String content}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Color.fromARGB(255, 147, 65, 255)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
