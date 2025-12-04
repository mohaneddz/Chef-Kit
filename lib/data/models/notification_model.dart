class LocalNotificationModel {
  final String notificationId;
  final String userId;
  final String notificationTitle;
  final String notificationType;
  final String notificationMessage;
  final String notificationData; // Stored as JSON string
  final bool notificationIsRead;
  final String notificationCreatedAt;

  LocalNotificationModel({
    required this.notificationId,
    required this.userId,
    required this.notificationTitle,
    required this.notificationType,
    required this.notificationMessage,
    required this.notificationData,
    required this.notificationIsRead,
    required this.notificationCreatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'notification_title': notificationTitle,
      'notification_type': notificationType,
      'notification_message': notificationMessage,
      'notification_data': notificationData,
      'notification_is_read': notificationIsRead ? 1 : 0,
      'notification_created_at': notificationCreatedAt,
    };
  }

  factory LocalNotificationModel.fromMap(Map<String, dynamic> map) {
    return LocalNotificationModel(
      notificationId: map['notification_id'],
      userId: map['user_id'],
      notificationTitle: map['notification_title'],
      notificationType: map['notification_type'],
      notificationMessage: map['notification_message'],
      notificationData: map['notification_data'],
      notificationIsRead: map['notification_is_read'] == 1,
      notificationCreatedAt: map['notification_created_at'],
    );
  }
}
