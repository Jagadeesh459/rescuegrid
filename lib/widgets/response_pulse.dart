import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';

class ResponsePulse extends StatefulWidget {
  final IncidentStatus currentStatus;
  final IncidentSeverity? severity;
  final int? etaMinutes;
  final double? distanceKm;
  final int? matchScore;
  final bool compact;

  const ResponsePulse({
    super.key,
    required this.currentStatus,
    this.severity,
    this.etaMinutes,
    this.distanceKm,
    this.matchScore,
    this.compact = false,
  });

  @override
  State<ResponsePulse> createState() => _ResponsePulseState();
}

class _ResponsePulseState extends State<ResponsePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  final List<IncidentStatus> _stages = [
    IncidentStatus.reported,
    IncidentStatus.assessed,
    IncidentStatus.assigned,
    IncidentStatus.accepted,
    IncidentStatus.enRoute,
    IncidentStatus.arrived,
    IncidentStatus.resolved,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStageColor(IncidentStatus status, bool isActive, bool isPast) {
    if (status == IncidentStatus.resolved && (isActive || isPast)) {
      return AppTheme.successGreen;
    }
    if (isActive) {
      return widget.severity == IncidentSeverity.critical
          ? AppTheme.emergencyRed
          : AppTheme.pulseCyan;
    }
    if (isPast) {
      return AppTheme.pulseCyan.withValues(alpha: 0.8);
    }
    return AppTheme.surfaceBorder;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexOf(widget.currentStatus);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.currentStatus == IncidentStatus.resolved
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.pulseCyan.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.currentStatus == IncidentStatus.resolved
                ? AppTheme.successGreen.withValues(alpha: 0.08)
                : AppTheme.pulseCyan.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.currentStatus == IncidentStatus.resolved
                                ? AppTheme.successGreen
                                : AppTheme.pulseCyan,
                            boxShadow: [
                              BoxShadow(
                                color: (widget.currentStatus == IncidentStatus.resolved
                                        ? AppTheme.successGreen
                                        : AppTheme.pulseCyan)
                                    .withValues(alpha: _glowAnimation.value),
                                blurRadius: 8 * _glowAnimation.value,
                                spreadRadius: 2 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'RESPONSE PULSE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.pulseCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Text(
                  'STAGE ${currentIndex + 1}/7',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Stage Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              children: [
                Icon(
                  _getStageIcon(widget.currentStatus),
                  size: 18,
                  color: widget.currentStatus == IncidentStatus.resolved
                      ? AppTheme.successGreen
                      : (widget.severity == IncidentSeverity.critical
                          ? AppTheme.emergencyRed
                          : AppTheme.pulseCyan),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT STATUS',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.currentStatus.label,
                        style: TextStyle(
                          color: widget.currentStatus == IncidentStatus.resolved
                              ? AppTheme.successGreen
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.currentStatus != IncidentStatus.resolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppTheme.emergencyRed,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scrollable / Adaptive Horizontal Step Tracker (Zero overflow guaranteed!)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_stages.length, (index) {
                final stage = _stages[index];
                final isPast = index < currentIndex;
                final isActive = index == currentIndex;
                final color = _getStageColor(stage, isActive, isPast);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step Item
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? color.withValues(alpha: 0.18)
                            : (isPast
                                ? AppTheme.surfaceLight
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? color
                              : (isPast
                                  ? color.withValues(alpha: 0.4)
                                  : AppTheme.surfaceBorder),
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPast || isActive ? color : AppTheme.surfaceLight,
                            ),
                            child: Center(
                              child: isPast
                                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: isActive
                                            ? Colors.white
                                            : AppTheme.textMuted,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stage.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive
                                  ? AppTheme.textPrimary
                                  : (isPast
                                      ? AppTheme.textSecondary
                                      : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < _stages.length - 1)
                      Container(
                        width: 14,
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: isPast
                            ? AppTheme.pulseCyan.withValues(alpha: 0.8)
                            : AppTheme.surfaceBorder,
                      ),
                  ],
                );
              }),
            ),
          ),

          // Responsive Metrics Row (Wrapped so it NEVER overflows!)
          if (!widget.compact &&
              (widget.etaMinutes != null ||
                  widget.distanceKm != null ||
                  widget.matchScore != null)) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.etaMinutes != null)
                  _buildMetricPill(
                    icon: Icons.timer_outlined,
                    label: 'EST. ARRIVAL',
                    value: '${widget.etaMinutes} min',
                    color: AppTheme.emergencyRed,
                  ),
                if (widget.distanceKm != null)
                  _buildMetricPill(
                    icon: Icons.route_rounded,
                    label: 'DISTANCE',
                    value: '${widget.distanceKm} km',
                    color: AppTheme.pulseCyan,
                  ),
                if (widget.matchScore != null)
                  _buildMetricPill(
                    icon: Icons.bolt_rounded,
                    label: 'MATCH SCORE',
                    value: '${widget.matchScore}%',
                    color: AppTheme.warningAmber,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStageIcon(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.reported:
        return Icons.campaign_rounded;
      case IncidentStatus.assessed:
        return Icons.analytics_outlined;
      case IncidentStatus.assigned:
        return Icons.hub_rounded;
      case IncidentStatus.accepted:
        return Icons.thumb_up_alt_rounded;
      case IncidentStatus.enRoute:
        return Icons.directions_car_filled_rounded;
      case IncidentStatus.arrived:
        return Icons.location_on_rounded;
      case IncidentStatus.resolved:
        return Icons.verified_rounded;
    }
  }
}
