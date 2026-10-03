import 'package:flutter/material.dart';
import '../models/responder.dart';
import '../theme/app_theme.dart';

class ResponderCard extends StatelessWidget {
  final Responder responder;
  final bool isSelected;
  final VoidCallback? onSelect;
  final String? actionLabel;

  const ResponderCard({
    super.key,
    required this.responder,
    this.isSelected = false,
    this.onSelect,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color availColor;
    switch (responder.availability) {
      case ResponderAvailability.available:
        availColor = AppTheme.successGreen;
        break;
      case ResponderAvailability.busy:
        availColor = AppTheme.warningAmber;
        break;
      case ResponderAvailability.offline:
        availColor = AppTheme.textMuted;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.pulseCyan : AppTheme.surfaceBorder,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.pulseCyan.withValues(alpha: 0.15),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTypeIcon(responder.type),
                        size: 20,
                        color: AppTheme.pulseCyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  responder.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  responder.callSign,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: availColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                responder.availability.label,
                                style: TextStyle(
                                  color: availColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• Load: ${responder.workload}',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Match Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: responder.matchScore >= 85
                            ? AppTheme.pulseCyan.withValues(alpha: 0.16)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: responder.matchScore >= 85
                              ? AppTheme.pulseCyan.withValues(alpha: 0.6)
                              : AppTheme.surfaceBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'MATCH',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${responder.matchScore}%',
                            style: TextStyle(
                              color: responder.matchScore >= 85
                                  ? AppTheme.pulseCyan
                                  : AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Skills tags (Wrap handles zero overflow across screen widths)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: responder.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Responsive bottom info & action
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_outlined, size: 13, color: AppTheme.pulseCyan),
                        const SizedBox(width: 4),
                        Text(
                          '${responder.distanceKm} km',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined, size: 13, color: AppTheme.emergencyRed),
                        const SizedBox(width: 4),
                        Text(
                          '${responder.etaMinutes}m ETA',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (actionLabel != null && onSelect != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.pulseCyan
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.pulseCyan : AppTheme.surfaceBorder,
                          ),
                        ),
                        child: Text(
                          actionLabel!,
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.pulseCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(ResponderType type) {
    switch (type) {
      case ResponderType.medical:
        return Icons.medical_services_rounded;
      case ResponderType.security:
        return Icons.shield_rounded;
      case ResponderType.fire:
        return Icons.local_fire_department_rounded;
      case ResponderType.rapid:
        return Icons.directions_run_rounded;
    }
  }
}

