import 'package:flutter/material.dart';

/*====================================================*/
/*================[ Notification Page }================*/
/*====================================================*/
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('알림 ${index + 1}'),
              subtitle: Text('테스트 알림 ${index + 1}'),
            ),
          );
        },
      ),
    );
  }
}