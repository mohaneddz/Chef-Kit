import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_state.dart';
import 'package:chefkit/views/screens/notifications_page.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool centerTitle;
  final List<Widget>? additionalActions;

  const TopNavBar({
    Key? key,
    required this.title,
    required this.subtitle,
    this.centerTitle = false,
    this.additionalActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: centerTitle
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'LeagueSpartan',
              ),
            ),
          ],
        ),
      ),
      centerTitle: centerTitle,
      actions: [
        ...(additionalActions ?? []),
        Padding(
          padding: const EdgeInsets.only(right: 25.0, top: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Color(0xFF3A3A3A)
                      : Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoaded &&
                          state.unreadCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
