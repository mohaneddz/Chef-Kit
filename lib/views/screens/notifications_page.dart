import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../common/constants.dart';
import '../../blocs/notifications/notifications_bloc.dart';
import '../../blocs/notifications/notifications_state.dart';
import '../../blocs/notifications/notifications_event.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'follow':
        return Icons.person_add;
      case 'like':
        return Icons.favorite;
      case 'new_recipe':
        return Icons.restaurant_menu;
      case 'chef_trending':
        return Icons.whatshot;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'follow':
        return AppColors.success1;
      case 'like':
        return AppColors.orange;
      case 'new_recipe':
        return AppColors.red600;
      case 'chef_trending':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.notificationsTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationsBloc>().add(const MarkAllNotificationsAsRead());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;
            
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noNotifications,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['notification_is_read'] as bool? ?? false;
    final type = notification['notification_type'] as String? ?? 'general';
    final title = notification['notification_title'] as String? ?? 'Notification';
    final message = notification['notification_message'] as String? ?? '';
    final time = _getTimeAgo(notification['notification_created_at']);
    final id = notification['notification_id'] as String;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          context.read<NotificationsBloc>().add(MarkNotificationAsRead(id));
        }
        // Handle navigation based on type if needed
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.red600.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.grey[200]! : AppColors.red600.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(type),
                color: isRead ? Colors.grey[500] : _getColorForType(type),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.red600,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
