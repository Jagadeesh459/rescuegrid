import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../models/responder.dart';
import '../../state/rescue_scope.dart';
import '../../state/rescue_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/rescue_map_placeholder.dart';
import '../../widgets/role_switch_banner.dart';
import '../live_response/live_response_screen.dart';
import 'responder_management_screen.dart';
import '../notifications/notification_center_screen.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  String _selectedFilter = 'ALL';
  final List<String> _filters = ['ALL', 'CRITICAL', 'ACTIVE', 'RESOLVED'];

  void _showManualOverrideModal(BuildContext context, Incident incident, RescueGridState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_road_rounded, color: AppTheme.warningAmber),
                  SizedBox(width: 8),
                  Text(
                    'MANUAL DISPATCH OVERRIDE',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Reassign incident ${incident.id} to any unit on the campus grid.',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),

              ...state.responders.map((r) {
                final isCurrent = incident.assignedResponderId == r.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      state.manualOverrideAssign(incident.id, r);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.warningAmber,
                          content: Text('Manual override: ${incident.id} routed to ${r.name}!'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.surfaceLight : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? AppTheme.pulseCyan : AppTheme.surfaceBorder,
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCurrent ? Icons.check_circle_rounded : Icons.radio_button_off,
                            color: isCurrent ? AppTheme.pulseCyan : AppTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${r.callSign} • ${r.locationName} • ETA: ${r.etaMinutes}m',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: r.availability == ResponderAvailability.available
                                  ? AppTheme.successGreen.withValues(alpha: 0.15)
                                  : AppTheme.warningAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              r.availability.label,
                              style: TextStyle(
                                color: r.availability == ResponderAvailability.available
                                    ? AppTheme.successGreen
                                    : AppTheme.warningAmber,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final allIncidents = state.incidents;

    final activeCount = allIncidents.where((i) => i.status != IncidentStatus.resolved).length;
    final criticalCount = allIncidents.where((i) => i.severity == IncidentSeverity.critical && i.status != IncidentStatus.resolved).length;
    final respondersOnline = state.responders.where((r) => r.availability != ResponderAvailability.offline).length;
    final resolvedCount = allIncidents.where((i) => i.status == IncidentStatus.resolved).length;

    final filteredIncidents = allIncidents.where((inc) {
      if (_selectedFilter == 'CRITICAL') {
        return inc.severity == IncidentSeverity.critical;
      }
      if (_selectedFilter == 'ACTIVE') {
        return inc.status != IncidentStatus.resolved;
      }
      if (_selectedFilter == 'RESOLVED') {
        return inc.status == IncidentStatus.resolved;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppTheme.warningAmber, size: 22),
            SizedBox(width: 8),
            Text('COMMAND CENTER HQ'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'Manage Responders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResponderManagementScreen()),
              );
            },
          ),
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RoleSwitchBanner(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System KPI Overview (Wrapped layout with zero RenderFlex overflow)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildKpiCard(
                              title: 'ACTIVE INCIDENTS',
                              value: '$activeCount',
                              color: activeCount > 0 ? AppTheme.emergencyRed : AppTheme.successGreen,
                              icon: Icons.crisis_alert_rounded,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'CRITICAL ALERTS',
                              value: '$criticalCount',
                              color: criticalCount > 0 ? AppTheme.emergencyRed : AppTheme.textMuted,
                              icon: Icons.warning_rounded,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'RESPONDERS READY',
                              value: '$respondersOnline',
                              color: AppTheme.pulseCyan,
                              icon: Icons.shield_rounded,
                              width: cardWidth,
                            ),
                            _buildKpiCard(
                              title: 'TOTAL RESOLVED',
                              value: '$resolvedCount',
                              color: AppTheme.successGreen,
                              icon: Icons.check_circle_rounded,
                              width: cardWidth,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Map Module (Tactical Sector Map Placeholder)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CAMPUS TACTICAL MAP SECTOR',
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
                              MaterialPageRoute(builder: (_) => const ResponderManagementScreen()),
                            );
                          },
                          child: const Text(
                            'UNITS LIST',
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

                    const RescueMapPlaceholder(
                      incidentLocation: 'Sector Central HQ Grid',
                      responderLocation: '5 Units Patrol Coverage',
                      responderCallSign: 'HQ-CMD',
                      etaMinutes: 2,
                      distanceKm: 0.4,
                      statusText: 'SECTOR ARMED',
                      height: 190,
                    ),
                    const SizedBox(height: 20),

                    // Live Incident Stream Header & Filter Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LIVE INCIDENT STREAM',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${filteredIncidents.length} Records',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Filter chips row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _selectedFilter = filter),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (filter == 'CRITICAL'
                                          ? AppTheme.emergencyRed
                                          : AppTheme.pulseCyan)
                                      : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : AppTheme.surfaceBorder,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Incident Cards with Command Override Action
                    ...filteredIncidents.map((inc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            IncidentCard(
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
                            if (inc.status != IncidentStatus.resolved)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 4),
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.swap_calls_rounded, size: 14),
                                  label: const Text('MANUAL UNIT REASSIGNMENT'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.warningAmber,
                                    side: BorderSide(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () => _showManualOverrideModal(context, inc, state),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
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
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

