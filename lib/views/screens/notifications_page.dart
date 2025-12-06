import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../common/constants.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notification data
  List<Map<String, dynamic>> _getNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.notificationNewRecipeTitle,
        'message': l10n.notificationNewRecipeMessage,
        'time': l10n.timeMinAgo(5),
        'icon': Icons.restaurant_menu,
        'color': AppColors.red600,
        'isRead': false,
      },
      {
        'title': l10n.notificationRecipeLikedTitle,
        'message': l10n.notificationRecipeLikedMessage,
        'time': l10n.timeHourAgo(1),
        'icon': Icons.favorite,
        'color': AppColors.orange,
        'isRead': false,
      },
      {
        'title': l10n.notificationNewFollowerTitle,
        'message': l10n.notificationNewFollowerMessage,
        'time': l10n.timeHoursAgo(2),
        'icon': Icons.person_add,
        'color': AppColors.success1,
        'isRead': false,
      },
      {
        'title': l10n.notificationCommentTitle,
        'message': l10n.notificationCommentMessage,
        'time': l10n.timeHoursAgo(3),
        'icon': Icons.chat_bubble,
        'color': AppColors.red600,
        'isRead': true,
      },
      {
        'title': l10n.notificationChallengeTitle,
        'message': l10n.notificationChallengeMessage,
        'time': l10n.timeHoursAgo(5),
        'icon': Icons.emoji_events,
        'color': AppColors.orange,
        'isRead': true,
      },
      {
        'title': l10n.notificationSavedTitle,
        'message': l10n.notificationSavedMessage,
        'time': l10n.timeDayAgo(1),
        'icon': Icons.bookmark,
        'color': AppColors.red600,
        'isRead': true,
      },
      {
        'title': l10n.notificationTrendingTitle,
        'message': l10n.notificationTrendingMessage,
        'time': l10n.timeDayAgo(1),
        'icon': Icons.trending_up,
        'color': AppColors.success1,
        'isRead': true,
      },
      {
        'title': l10n.notificationAchievementTitle,
        'message': l10n.notificationAchievementMessage,
        'time': l10n.timeDaysAgo(2),
        'icon': Icons.military_tech,
        'color': AppColors.orange,
        'isRead': true,
      },
      {
        'title': l10n.notificationRecipeDayTitle,
        'message': l10n.notificationRecipeDayMessage,
        'time': l10n.timeDaysAgo(3),
        'icon': Icons.star,
        'color': AppColors.red600,
        'isRead': true,
      },
      {
        'title': l10n.notificationIngredientTitle,
        'message': l10n.notificationIngredientMessage,
        'time': l10n.timeDaysAgo(3),
        'icon': Icons.notifications_active,
        'color': AppColors.orange,
        'isRead': true,
      },
    ];
  }

  int _getUnreadCount(List<Map<String, dynamic>> notifications) =>
      notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    final notifications = _getNotifications(context);
    final unreadCount = _getUnreadCount(notifications);

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
          if (unreadCount > 0)
            TextButton(
              onPressed: () {},
              child: Text(
                AppLocalizations.of(context)!.markAllRead,
                style: TextStyle(
                  color: AppColors.red600,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
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
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;

    return Container(
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
              notification['icon'],
              color: isRead ? Colors.grey[500] : notification['color'],
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
                        notification['title'],
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
                        decoration: BoxDecoration(
                          color: AppColors.red600,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
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
                  notification['time'],
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
    );
  }
}
