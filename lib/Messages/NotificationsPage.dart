import 'package:CampusConnect/HomePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  static const route = '/notification-page';

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _updateNotifications();
  }

  void _updateNotifications() {
    // Clear existing notifications list and add new notifications
    setState(() {
      notifications.clear();
      notifications.addAll(NotificationData.notifications);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("notification".tr),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text('No notifications available'),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(notifications[index]),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                // Remove dismissed notification
                NotificationData.notifications.removeAt(index);
              });
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.notifications),
              ),
              title: Text(notifications[index]),
              subtitle: Text(
                  'Notification Description ${index + 1}'), // Modify as needed
              onTap: () {
                // Implement notification click functionality
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationData {
  static List<String> notifications = [];
}




// body: ListView.builder(
//   itemCount: notifications.length,
//   itemBuilder: (context, index) {
//     return Dismissible(
//       key: Key(notifications[index]),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: EdgeInsets.only(right: 20.0),
//         child: Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       onDismissed: (direction) {
//         setState(() {
//           notifications.removeAt(index);
//         });
//       },
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.blue,
//           child: Icon(Icons.notifications),
//         ),
//         title: Text(notifications[index]),
//         subtitle: Text('Notification Description ${index + 1}'),
//         onTap: () {
//           // Implement notification click functionality
//         },
//       ),
//     );
//   },
// ),

