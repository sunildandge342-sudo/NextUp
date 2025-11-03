import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;
  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "Token #12 Activated",
      "message": "Your token for Passport Office is now active.",
      "type": "success",
      "time": "2 mins ago",
      "read": false,
    },
    {
      "title": "Queue Update",
      "message": "2 people ahead of you for Electric Bill Service.",
      "type": "info",
      "time": "10 mins ago",
      "read": false,
    },
    {
      "title": "Feedback Received",
      "message": "Thanks for your feedback on Aadhaar Service!",
      "type": "success",
      "time": "1 day ago",
      "read": true,
    },
  ];

  void markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n["read"] = true;
      }
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "success":
        return Colors.green;
      case "warning":
        return Colors.orange;
      case "error":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case "success":
        return Icons.check_circle;
      case "warning":
        return Icons.warning;
      case "error":
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.any((n) => !n["read"]))
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                "Mark all as read",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet 📭",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final color = _getTypeColor(item["type"]);
          final icon = _getTypeIcon(item["type"]);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: item["read"]
                ? Colors.white
                : color.withOpacity(0.1), // unread highlight
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              title: Text(
                item["title"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["message"]),
                  const SizedBox(height: 4),
                  Text(
                    item["time"],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: !item["read"]
                  ? IconButton(
                icon: const Icon(Icons.circle, color: Colors.blue, size: 12),
                tooltip: "Mark as read",
                onPressed: () {
                  setState(() => item["read"] = true);
                },
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
