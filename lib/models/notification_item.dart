import 'package:flutter/material.dart';

enum NotificationPriority {
  critical(Color(0xFFEF4444), Icons.error_rounded),
  warning(Color(0xFFF59E0B), Icons.warning_rounded),
  info(Color(0xFF06B6D4), Icons.info_rounded),
  success(Color(0xFF10B981), Icons.check_circle_rounded);

  final Color color;
  final IconData icon;
  const NotificationPriority(this.color, this.icon);
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationPriority priority;
  final String? incidentId;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.priority,
    this.incidentId,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationPriority? priority,
    String? incidentId,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      incidentId: incidentId ?? this.incidentId,
      isRead: isRead ?? this.isRead,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

