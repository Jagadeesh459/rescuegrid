class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final String title;
  final String description;
  final String stage; // reported, assessed, assigned, accepted, enRoute, arrived, resolved, backup
  final bool isHighlight;

  const TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.stage,
    this.isHighlight = false,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

