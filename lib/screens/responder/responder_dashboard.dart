import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../models/responder.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/role_switch_banner.dart';
import 'new_assignment_screen.dart';
import '../live_response/live_response_screen.dart';
import '../history/incident_history_screen.dart';
import '../notifications/notification_center_screen.dart';

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({super.key});

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final activeInc = state.activeIncident;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medical_services_rounded, color: AppTheme.emergencyRed, size: 20),
            SizedBox(width: 8),
            Text('RESPONDER PORTAL'),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (state.unreadNotificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.emergencyRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IncidentHistoryScreen()),
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
                    // Duty Status Toggle Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: state.responderDutyStatus == ResponderAvailability.available
                                  ? AppTheme.successGreen.withValues(alpha: 0.15)
                                  : AppTheme.warningAmber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.radio_button_checked,
                              color: state.responderDutyStatus == ResponderAvailability.available
                                  ? AppTheme.successGreen
                                  : AppTheme.warningAmber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'UNIT MED-01 STATUS',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  state.responderDutyStatus.label.toUpperCase(),
                                  style: TextStyle(
                                    color: state.responderDutyStatus == ResponderAvailability.available
                                        ? AppTheme.successGreen
                                        : AppTheme.warningAmber,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Duty switch dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ResponderAvailability>(
                                value: state.responderDutyStatus,
                                dropdownColor: AppTheme.surface,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: ResponderAvailability.values.map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    state.setResponderDuty(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Active Urgent Dispatch Card if activeIncident is present
                    if (activeInc != null && activeInc.status != IncidentStatus.resolved) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.emergencyRed,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emergencyRed.withValues(alpha: 0.2),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emergencyRed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'DISPATCH ORDER ASSIGNED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  activeInc.status.label,
                                  style: const TextStyle(
                                    color: AppTheme.pulseCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${activeInc.category.label}: ${activeInc.locationName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeInc.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Dual Action Buttons: Review/Accept or Go Live
                            Row(
                              children: [
                                if (activeInc.status == IncidentStatus.assigned) ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                                      label: const Text('VIEW DISPATCH'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.emergencyRed,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => NewAssignmentScreen(incident: activeInc),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.navigation_rounded, size: 16),
                                      label: const Text('CONTINUE TRACKING'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.pulseCyan,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => LiveResponseScreen(incident: activeInc),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Performance & Readiness Stats (Wrapped cleanly to prevent RenderFlex overflow)
                    const Text(
                      'UNIT METRICS (TODAY)',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildStatCard(
                              title: 'Avg. Response Time',
                              value: '2.4 min',
                              subtitle: '-35s vs campus target',
                              icon: Icons.timer_outlined,
                              color: AppTheme.pulseCyan,
                              width: cardWidth,
                            ),
                            _buildStatCard(
                              title: 'Incidents Cleared',
                              value: '6',
                              subtitle: '100% resolution rate',
                              icon: Icons.verified_rounded,
                              color: AppTheme.successGreen,
                              width: cardWidth,
                            ),
                            _buildStatCard(
                              title: 'Active Units Online',
                              value: '5 Teams',
                              subtitle: 'Full campus coverage',
                              icon: Icons.hub_rounded,
                              color: AppTheme.warningAmber,
                              width: cardWidth,
                            ),
                            _buildStatCard(
                              title: 'Readiness Score',
                              value: '98%',
                              subtitle: 'All AED & Trauma gear ready',
                              icon: Icons.speed_rounded,
                              color: AppTheme.emergencyRed,
                              width: cardWidth,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Campus Incident Log
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CAMPUS ACTIVE & RECENT LOGS',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const IncidentHistoryScreen()),
                            );
                          },
                          child: const Text(
                            'HISTORY',
                            style: TextStyle(
                              color: AppTheme.pulseCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...state.incidents.map((inc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IncidentCard(
                          incident: inc,
                          showTrackButton: inc.status != IncidentStatus.resolved,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LiveResponseScreen(incident: inc),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

