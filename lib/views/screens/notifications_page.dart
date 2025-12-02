import 'package:flutter/material.dart';
import '../../common/constants.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Recipe Posted!',
      'message': 'Chef Gordon posted a new Beef Wellington recipe',
      'time': '5 min ago',
      'icon': Icons.restaurant_menu,
      'color': AppColors.red600,
      'isRead': false,
    },
    {
      'title': 'Recipe Liked',
      'message': 'Sarah liked your Mahjouba recipe',
      'time': '1 hour ago',
      'icon': Icons.favorite,
      'color': AppColors.orange,
      'isRead': false,
    },
    {
      'title': 'New Follower',
      'message': 'Chef Jamie started following you',
      'time': '2 hours ago',
      'icon': Icons.person_add,
      'color': AppColors.success1,
      'isRead': false,
    },
    {
      'title': 'Comment on Recipe',
      'message': 'Mike commented on your Couscous recipe: "Looks delicious!"',
      'time': '3 hours ago',
      'icon': Icons.chat_bubble,
      'color': AppColors.red600,
      'isRead': true,
    },
    {
      'title': 'Weekly Challenge',
      'message': 'New weekly cooking challenge is now available!',
      'time': '5 hours ago',
      'icon': Icons.emoji_events,
      'color': AppColors.orange,
      'isRead': true,
    },
    {
      'title': 'Recipe Saved',
      'message': 'Your Tajine recipe was saved by 15 people this week',
      'time': '1 day ago',
      'icon': Icons.bookmark,
      'color': AppColors.red600,
      'isRead': true,
    },
    {
      'title': 'Trending Recipe',
      'message': 'Your Chorba recipe is trending! 🔥',
      'time': '1 day ago',
      'icon': Icons.trending_up,
      'color': AppColors.success1,
      'isRead': true,
    },
    {
      'title': 'New Achievement',
      'message': 'Congratulations! You unlocked "Master Chef" badge',
      'time': '2 days ago',
      'icon': Icons.military_tech,
      'color': AppColors.orange,
      'isRead': true,
    },
    {
      'title': 'Recipe of the Day',
      'message': 'Your Barkoukes was featured as Recipe of the Day!',
      'time': '3 days ago',
      'icon': Icons.star,
      'color': AppColors.red600,
      'isRead': true,
    },
    {
      'title': 'Ingredient Alert',
      'message': 'Paprika is running low in your inventory',
      'time': '3 days ago',
      'icon': Icons.notifications_active,
      'color': AppColors.orange,
      'isRead': true,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

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
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: () {},
              child: Text(
                'Mark all read',
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
      body: _notifications.isEmpty
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
                    'No notifications yet',
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
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildNotificationCard(index);
              },
            ),
    );
  }

  Widget _buildNotificationCard(int index) {
    final notification = _notifications[index];
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
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
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
