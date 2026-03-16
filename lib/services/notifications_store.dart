import '../models/queue_notifications.dart';

class NotificationStore {

  static final List<QueueNotification> notifications = [];

  static void addNotification(
      String serviceName,
      String title,
      String message
      ) {

    notifications.insert(
      0,
      QueueNotification(
        serviceName: serviceName,
        title: title,
        message: message,
        time: DateTime.now(),
      ),
    );
  }
}