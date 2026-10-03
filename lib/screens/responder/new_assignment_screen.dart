import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/severity_badge.dart';
import '../live_response/live_response_screen.dart';
import 'escalation_screen.dart';

class NewAssignmentScreen extends StatelessWidget {
  final Incident incident;

  const NewAssignmentScreen({super.key, required this.incident});

  void _accept(BuildContext context) {
    final state = RescueScope.of(context);
    state.acceptAssignment();
    state.setEnRoute();

    final active = state.activeIncident ?? incident;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveResponseScreen(incident: active),
      ),
    );
  }

  void _decline(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EscalationScreen(incident: incident),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Response Order'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Dispatch Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.emergencyRed, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.crisis_alert_rounded, color: AppTheme.emergencyRed, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'URGENT DISPATCH ALERT',
                      style: TextStyle(
                        color: AppTheme.emergencyRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Auto-matched by Command Intelligence algorithm for Unit MED-01',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Specs Grid
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(incident.category.icon, color: AppTheme.pulseCyan, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      incident.category.label.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                SeverityBadge(severity: incident.severity, isLarge: true),
                              ],
                            ),
                            const Divider(),
                            _buildInfoTile('LOCATION', incident.locationName, Icons.location_on_outlined),
                            const SizedBox(height: 10),
                            _buildInfoTile('LANDMARK', incident.landmark, Icons.near_me_outlined),
                            const SizedBox(height: 10),
                            _buildInfoTile('CASUALTIES', '${incident.peopleAffected} Person(s) Affected', Icons.people_outline),
                            const SizedBox(height: 10),
                            _buildInfoTile('DETAILS', incident.description, Icons.notes_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metrics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard('DISTANCE', '0.3 km', Icons.route_rounded, AppTheme.pulseCyan),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricCard('EST. ETA', '2 MIN', Icons.timer_outlined, AppTheme.emergencyRed),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricCard('MATCH', '96%', Icons.bolt_rounded, AppTheme.warningAmber),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons: ACCEPT & DECLINE
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      text: 'DECLINE',
                      isOutline: true,
                      onPressed: () => _decline(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'ACCEPT DISPATCH',
                      icon: Icons.check_circle_rounded,
                      isDanger: true,
                      onPressed: () => _accept(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

