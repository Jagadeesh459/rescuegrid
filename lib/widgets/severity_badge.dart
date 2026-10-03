import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';

class SeverityBadge extends StatelessWidget {
  final IncidentSeverity severity;
  final bool isLarge;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (severity) {
      case IncidentSeverity.critical:
        bg = AppTheme.emergencyRed.withValues(alpha: 0.16);
        border = AppTheme.emergencyRed.withValues(alpha: 0.8);
        text = AppTheme.emergencyRed;
        break;
      case IncidentSeverity.high:
        bg = const Color(0xFFF97316).withValues(alpha: 0.16);
        border = const Color(0xFFF97316).withValues(alpha: 0.8);
        text = const Color(0xFFF97316);
        break;
      case IncidentSeverity.medium:
        bg = AppTheme.warningAmber.withValues(alpha: 0.16);
        border = AppTheme.warningAmber.withValues(alpha: 0.8);
        text = AppTheme.warningAmber;
        break;
      case IncidentSeverity.low:
        bg = AppTheme.infoBlue.withValues(alpha: 0.16);
        border = AppTheme.infoBlue.withValues(alpha: 0.8);
        text = AppTheme.infoBlue;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(color: border, width: isLarge ? 1.5 : 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isLarge ? 7 : 5,
            height: isLarge ? 7 : 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: text,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            severity.label,
            style: TextStyle(
              color: text,
              fontSize: isLarge ? 12 : 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

