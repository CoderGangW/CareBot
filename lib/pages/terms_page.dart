import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  final VoidCallback onAgree;

  TermsPage({required this.onAgree});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("이용 약관"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: '해실이 프로젝트는 한국정보산업연합회에서 주관하는\n'
                                  'ICT멘토링의 프로보노 부문 프로젝트로,\n'
                                  '앱 및 웹사이트의 디자인, 데이터 등의 저작물의 권리는\n'
                                  '본 프로젝트 팀인 [해피실버데이]에게 있습니다.\n\n'
                                  '제공하는 정보는 개발 및 테스트이외에 다른 목적으로 사용되지 않으며,\n'
                                  '반대로 제공되는 정보 또한 다른 목적으로 사용되지 말아야 합니다.\n',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '저작물을 무단으로 사용시 법적책임이 따를 수 있습니다.\n'
                                'COPYRIGHT ⓒ2024. HappySilverDay,YoonWon Kang. All rights reserved.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 155, 101, 255),
                        width: 1.0,
                      ),
                    ),
                    child: Text("동의하지 않습니다"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 155, 101, 255),
                        width: 1.0,
                      ),
                    ),
                    child: Text("동의합니다"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onAgree();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ),
    );
  }
}
