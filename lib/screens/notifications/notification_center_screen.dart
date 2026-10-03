import 'package:flutter/material.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../live_response/live_response_screen.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final notifications = state.notifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tactical Broadcast Alerts'),
        actions: [
          TextButton(
            onPressed: () {
              state.markAllNotificationsAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked as read.')),
              );
            },
            child: const Text(
              'MARK ALL READ',
              style: TextStyle(
                color: AppTheme.pulseCyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  'No notifications received yet.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        if (notif.incidentId != null) {
                          final inc = state.incidents.firstWhere(
                            (i) => i.id == notif.incidentId,
                            orElse: () => state.incidents.first,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveResponseScreen(incident: inc),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: notif.isRead ? AppTheme.surface : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: notif.isRead
                                ? AppTheme.surfaceBorder
                                : notif.priority.color.withValues(alpha: 0.5),
                            width: notif.isRead ? 1.0 : 1.5,
                          ),
                        ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notif.priority.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(notif.priority.icon, size: 18, color: notif.priority.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        notif.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                          fontWeight: notif.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notif.timeAgo,
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                },
              ),
      ),
    );
  }
}
