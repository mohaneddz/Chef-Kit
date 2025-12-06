import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  
  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;

  const NotificationsLoaded(this.notifications, this.unreadCount);

  @override
  List<Object> get props => [notifications, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object> get props => [message];
}
