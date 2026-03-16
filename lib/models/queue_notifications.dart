class QueueNotification {
  final String serviceName;
  final String title;
  final String message;
  final DateTime time;

  QueueNotification({
    required this.serviceName,
    required this.title,
    required this.message,
    required this.time,
  });
}