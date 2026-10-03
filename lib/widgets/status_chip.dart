import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final IncidentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case IncidentStatus.reported:
        color = AppTheme.warningAmber;
        break;
      case IncidentStatus.assessed:
        color = AppTheme.infoBlue;
        break;
      case IncidentStatus.assigned:
      case IncidentStatus.accepted:
      case IncidentStatus.enRoute:
        color = AppTheme.pulseCyan;
        break;
      case IncidentStatus.arrived:
        color = const Color(0xFFA855F7);
        break;
      case IncidentStatus.resolved:
        color = AppTheme.successGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

