import 'dart:convert';
// unused import removed
// unused foundation import removed
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../common/token_storage.dart';
import '../../common/config.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final TokenStorage _tokenStorage = TokenStorage();
  late final String baseUrl;

  NotificationsBloc() : super(NotificationsInitial()) {
    baseUrl = AppConfig.baseUrl; // Use centralized config

    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> notifications =
            List<Map<String, dynamic>>.from(data);

        // Sort by date descending if not already
        notifications.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['notification_created_at'] ?? '') ??
              DateTime.now();
          final bDate =
              DateTime.tryParse(b['notification_created_at'] ?? '') ??
              DateTime.now();
          return bDate.compareTo(aDate);
        });

        final int unreadCount = notifications
            .where((n) => n['notification_is_read'] == false)
            .length;
        emit(NotificationsLoaded(notifications, unreadCount));
      } else {
        emit(
          NotificationsError(
            'Failed to load notifications: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      try {
        final headers = await _getHeaders();
        await http.put(
          Uri.parse('$baseUrl/api/notifications/${event.notificationId}/read'),
          headers: headers,
        );

        // Optimistic update
        final updatedNotifications = currentState.notifications.map((n) {
          if (n['notification_id'] == event.notificationId) {
            return {...n, 'notification_is_read': true};
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications
            .where((n) => n['notification_is_read'] == false)
            .length;

        emit(NotificationsLoaded(updatedNotifications, unreadCount));
      } catch (e) {
        // Revert or show error? For now just keep state
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      try {
        final headers = await _getHeaders();
        await http.put(
          Uri.parse('$baseUrl/api/notifications/read-all'),
          headers: headers,
        );

        // Optimistic update
        final updatedNotifications = currentState.notifications.map((n) {
          return {...n, 'notification_is_read': true};
        }).toList();

        emit(NotificationsLoaded(updatedNotifications, 0));
      } catch (e) {
        // Revert or show error? For now just keep state
      }
    }
  }
}
