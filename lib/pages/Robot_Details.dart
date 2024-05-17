import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class robotdetails extends StatelessWidget {
  const robotdetails({Key? key});

  @override
  Widget build(BuildContext context) {
    final String? robotName =
        ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(robotName!),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // 아이콘 버튼 클릭 시 동작할 내용
            },
            tooltip: '로봇 정보', // 툴팁 설정
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            // Example: Displaying a 2D map image loaded from a URL
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 2.0,
                child: Image.network(
                  'https://kr.mathworks.com/discovery/slam/_jcr_content/mainParsys/band_1231704498_copy/mainParsys/lockedsubnav/mainParsys/columns_39110516/6046ff86-c275-45cd-87bc-214e8abacb7c/columns_463008322/7b029c5b-9826-4f96-b230-9a6ec96cb4ab/columns_1472205090/bd4f8030-3567-47ae-b28f-3d4ac2e33131/image_1721175736_cop.adapt.full.medium.jpg/1715236365556.jpg',
                  fit: BoxFit.cover,
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
                    child: _buildStatusCard('배터리 상태', '100%'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildStatusCard('활성화 상태', '활성화됨'),
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
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
