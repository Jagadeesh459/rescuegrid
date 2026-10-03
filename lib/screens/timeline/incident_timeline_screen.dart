import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../state/rescue_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/timeline_widget.dart';
import '../../widgets/role_switch_banner.dart';
import '../admin/command_center_screen.dart';

class IncidentTimelineScreen extends StatelessWidget {
  final Incident incident;

  const IncidentTimelineScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    // Find current updated version of the incident if available
    final currentIncident = state.incidents.firstWhere(
      (i) => i.id == incident.id,
      orElse: () => incident,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Incident Timeline Audit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tactical incident log exported.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RoleSwitchBanner(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(currentIncident.category.icon, color: AppTheme.pulseCyan, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${currentIncident.category.label} (${currentIncident.id})',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${currentIncident.locationName} • ${currentIncident.landmark}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              SeverityBadge(severity: currentIncident.severity),
                              StatusChip(status: currentIncident.status),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Reporter: ${currentIncident.reporterName}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Debrief Note if resolved
                    if (currentIncident.resolutionSummary != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_rounded, color: AppTheme.successGreen, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'OFFICIAL RESOLUTION LOG',
                                  style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentIncident.resolutionSummary!,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Section Title
                    const Text(
                      'EVENT SEQUENCE (LIVE LOG)',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Vertical Timeline Widget
                    TimelineWidget(events: currentIncident.timeline),
                    const SizedBox(height: 24),

                    // Command Center quick jump button
                    PrimaryButton(
                      text: 'VIEW IN COMMAND CENTER HQ',
                      icon: Icons.admin_panel_settings_rounded,
                      isSecondary: true,
                      onPressed: () {
                        state.switchRole(UserRole.admin);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const CommandCenterScreen()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
