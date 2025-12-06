import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
  
  @override
  List<Object> get props => [];
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;
  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();

  @override
  List<Object> get props => [];
}
